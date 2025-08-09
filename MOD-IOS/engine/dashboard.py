# MOD-IOS/engine/dashboard.py
import os
import re
import json
import time
import shutil
import plistlib
import sqlite3
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Optional

import streamlit as st

# ---------- Constants ----------
BASE_DIR = Path("MOD-IOS")
ENGINE_DIR = BASE_DIR / "engine"
TARGET_DIR = BASE_DIR / "target_"
DECRYPT_SUFFIX = "__decrypted"

UUID_RE = re.compile(r"^[A-Fa-f0-9]{25,64}$")  # UDID/UUID-ish folder names vary by length

# ---------- Helpers ----------
def ensure_dirs() -> None:
    ENGINE_DIR.mkdir(parents=True, exist_ok=True)
    TARGET_DIR.mkdir(parents=True, exist_ok=True)

def is_uuid_folder(p: Path) -> bool:
    return p.is_dir() and UUID_RE.match(p.name) is not None

def find_candidates() -> Tuple[List[Path], List[Path]]:
    """
    Returns (backup_dirs, loose_files) under TARGET_DIR
    """
    bdirs, lfiles = [], []
    for child in sorted(TARGET_DIR.iterdir()):
        if child.is_dir():
            if is_uuid_folder(child):
                bdirs.append(child)
            else:
                # Allow non-UUID directories as selectable too
                bdirs.append(child)
        else:
            if child.suffix.lower() in {".db", ".sqlite", ".sqlite3", ".plist", ".wal"} or child.name.lower() in {
                "manifest.db", "manifest.plist", "index.plist"
            }:
                lfiles.append(child)
    return bdirs, lfiles

def load_plist_safe(p: Path) -> Optional[dict]:
    try:
        with p.open("rb") as fh:
            return plistlib.load(fh)
    except Exception:
        # try biplist if available (binary/older formats)
        try:
            import biplist  # type: ignore
            return biplist.readPlist(p.as_posix())
        except Exception:
            return None

def read_manifest_info(backup_dir: Path) -> Dict:
    info = {"encrypted": None, "device_name": None, "ios_version": None}
    manifest_plist = backup_dir / "Manifest.plist"
    info_plist = backup_dir / "Info.plist"
    if manifest_plist.exists():
        m = load_plist_safe(manifest_plist)
        if isinstance(m, dict):
            # Keys differ across iOS versions
            enc = m.get("IsEncrypted")
            if enc is None:
                # Newer backups may indicate under "BackupKeyBag"/"WasPasscodeSet"
                enc = True if m.get("BackupKeyBag") else m.get("WasPasscodeSet")
            info["encrypted"] = bool(enc) if enc is not None else None
    if info_plist.exists():
        i = load_plist_safe(info_plist)
        if isinstance(i, dict):
            info["device_name"] = i.get("Device Name") or i.get("Display Name")
            info["ios_version"] = i.get("Product Version")
    return info

def has_decrypted_dir(backup_dir: Path) -> Path:
    out = backup_dir.parent / f"{backup_dir.name}{DECRYPT_SUFFIX}"
    return out if out.exists() and out.is_dir() else Path()

def decrypt_backup(backup_dir: Path, password: str, out_dir: Path) -> Tuple[bool, str]:
    """
    Uses the external CLI 'iphone_backup_decrypt' if available.
    Returns (ok, message).
    """
    cmd = shutil.which("iphone_backup_decrypt")
    if not cmd:
        return False, "iphone_backup_decrypt is not installed. Install with: pip install iphone_backup_decrypt"

    out_dir.mkdir(parents=True, exist_ok=True)

    # Typical usage:
    # iphone_backup_decrypt -i <backup_dir> -o <out_dir> -p <password>
    proc = subprocess.Popen(
        [cmd, "-i", backup_dir.as_posix(), "-o", out_dir.as_posix(), "-p", password],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )
    log_lines = []
    # Stream logs to UI
    placeholder = st.empty()
    with placeholder.container():
        st.write("Starting decryption…")
        log_area = st.empty()
        prog = st.progress(0)
    step = 0
    for line in proc.stdout:
        log_lines.append(line.rstrip())
        step = min(100, step + 1)
        with placeholder.container():
            log_area.code("\n".join(log_lines[-30:]))
            prog.progress(step)
    proc.wait()
    ok = proc.returncode == 0
    if ok:
        return True, f"Decryption completed → {out_dir}"
    else:
        return False, "Decryption failed. Check password and backup integrity."

def quick_fs_inventory(root: Path, max_items: int = 2000) -> Dict[str, int]:
    counts = {"files": 0, "dirs": 0, "db": 0, "plist": 0, "images": 0, "media": 0, "wal": 0}
    ex_db = {".db", ".sqlite", ".sqlite3"}
    ex_plist = {".plist"}
    ex_img = {".jpg", ".jpeg", ".png", ".heic", ".gif", ".tiff", ".bmp"}
    ex_media = {".mp4", ".mov", ".m4a", ".caf", ".aac", ".wav", ".mp3"}

    walked = 0
    for dirpath, dirnames, filenames in os.walk(root):
        counts["dirs"] += 1
        for fn in filenames:
            walked += 1
            if walked > max_items:
                break
            f = fn.lower()
            counts["files"] += 1
            suffix = Path(f).suffix
            if suffix in ex_db:
                counts["db"] += 1
            if suffix in ex_plist:
                counts["plist"] += 1
            if suffix in ex_img:
                counts["images"] += 1
            if suffix in ex_media:
                counts["media"] += 1
            if suffix == ".wal":
                counts["wal"] += 1
        if walked > max_items:
            break
    return counts

def read_sqlite_head(db_path: Path, limit: int = 10) -> Dict[str, List[str]]:
    info = {"tables": []}
    try:
        con = sqlite3.connect(db_path.as_posix())
        cur = con.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;")
        info["tables"] = [r[0] for r in cur.fetchall()]
        con.close()
    except Exception:
        pass
    return info

def label_for_path(p: Path) -> str:
    if p.is_dir():
        return f"[DIR] {p.name}"
    else:
        return f"[FILE] {p.name}"

# ---------- UI ----------
def main():
    ensure_dirs()
    st.set_page_config(page_title="MOD-IOS Dashboard", layout="wide")
    st.title("MOD-IOS • iOS Backup Dashboard")

    with st.sidebar:
        st.markdown("### Settings")
        if st.button("Rescan target_"):
            st.session_state["_rescan"] = True
        password = st.text_input("Backup password (for encrypted backups)", type="password")
        st.caption("If the backup is encrypted, the password is required for decryption.")

    backup_dirs, loose_files = find_candidates()

    st.markdown("#### Select Backup or File")
    options = []
    index_map = []
    for d in backup_dirs:
        options.append(label_for_path(d))
        index_map.append(d)
    for f in loose_files:
        options.append(label_for_path(f))
        index_map.append(f)

    if not options:
        st.warning(f"No backups or files found in {TARGET_DIR}. Place backups under this folder.")
        st.stop()

    selected = st.selectbox("Available items in target_", options, index=0)
    sel_path = index_map[options.index(selected)]

    # ---------- Cards Row ----------
    c1, c2, c3 = st.columns([1.2, 1, 1])
    with c1:
        st.markdown("#### Backup Status")
        if sel_path.is_dir():
            meta = read_manifest_info(sel_path)
            enc = meta["encrypted"]
            enc_str = "Unknown"
            if enc is True:
                enc_str = "Encrypted"
            elif enc is False:
                enc_str = "Not Encrypted"
            st.write(f"**Selected:** {sel_path.name}")
            st.write(f"**Encryption:** {enc_str}")
            st.write(f"**Device:** {meta.get('device_name') or '—'}")
            st.write(f"**iOS:** {meta.get('ios_version') or '—'}")
            dec_dir = has_decrypted_dir(sel_path)
            if dec_dir:
                st.success(f"Decrypted view exists: {dec_dir.name}")
            else:
                st.info("No decrypted output found.")
        else:
            st.write(f"**Selected file:** {sel_path.name}")
            st.write(f"Size:** {sel_path.stat().st_size} bytes")

    with c2:
        st.markdown("#### Actions")
        if sel_path.is_dir():
            dec_dir = has_decrypted_dir(sel_path)
            encrypted_flag = read_manifest_info(sel_path).get("encrypted")
            if encrypted_flag is True and not dec_dir:
                if st.button("Decrypt backup → target_/UUID__decrypted"):
                    if not password:
                        st.error("Enter backup password in sidebar.")
                    else:
                        out_dir = sel_path.parent / f"{sel_path.name}{DECRYPT_SUFFIX}"
                        ok, msg = decrypt_backup(sel_path, password, out_dir)
                        if ok:
                            st.success(msg)
                            st.toast("Decryption finished", icon="✅")
                        else:
                            st.error(msg)
            elif encrypted_flag is False:
                st.info("Backup is not encrypted; decryption not required.")
            elif dec_dir:
                st.success("Already decrypted.")
        else:
            # Loose file actions
            if sel_path.suffix.lower() in {".db", ".sqlite", ".sqlite3"}:
                if st.button("Inspect SQLite (tables)"):
                    info = read_sqlite_head(sel_path)
                    st.code(json.dumps(info, indent=2))
            elif sel_path.suffix.lower() == ".plist":
                if st.button("Open Plist"):
                    d = load_plist_safe(sel_path)
                    if d is None:
                        st.error("Failed to parse plist (may be encrypted).")
                    else:
                        st.code(json.dumps(d, indent=2))

    with c3:
        st.markdown("#### Decode / Inventory")
        # Allow decoding on decrypted or plaintext backups
        scan_root = None
        if sel_path.is_dir():
            dec_dir = has_decrypted_dir(sel_path)
            scan_root = dec_dir if dec_dir else sel_path
        else:
            scan_root = None

        if scan_root:
            if st.button("Quick Inventory (files, db, plist, media)"):
                with st.spinner("Scanning…"):
                    counts = quick_fs_inventory(scan_root)
                    st.json(counts)
        else:
            st.caption("Select a backup folder (or decrypt first) to enable inventory.")

    st.markdown("---")
    st.markdown("### Explorer / Details")

    if sel_path.is_dir():
        dec_dir = has_decrypted_dir(sel_path)
        root = dec_dir if dec_dir else sel_path

        cols = st.columns(4)
        with cols[0]:
            st.markdown("**Core Files**")
            for name in ["Manifest.db", "Manifest.plist", "Info.plist", "Status.plist", "Index.plist"]:
                p = root / name
                if p.exists():
                    if st.button(f"View {name}"):
                        if p.suffix.lower() == ".plist":
                            data = load_plist_safe(p)
                            if data is None:
                                st.error(f"{name} could not be parsed (possibly encrypted).")
                            else:
                                st.code(json.dumps(data, indent=2))
                        elif p.suffix.lower() in {".db", ".sqlite", ".sqlite3"}:
                            st.write(read_sqlite_head(p))
                else:
                    st.caption(f"{name}: —")

        with cols[1]:
            st.markdown("**SQLite Sniff (top-level)**")
            dbs = sorted([p for p in root.iterdir() if p.is_file() and p.suffix.lower() in {".db", ".sqlite", ".sqlite3"}])
            if dbs:
                choice = st.selectbox("Select DB", [p.name for p in dbs], key="db_select_top")
                sel_db = root / choice
                if st.button("List tables", key="list_tables_btn"):
                    st.json(read_sqlite_head(sel_db))
            else:
                st.caption("No DB files at root.")

        with cols[2]:
            st.markdown("**Plist Sniff (top-level)**")
            pl = sorted([p for p in root.iterdir() if p.is_file() and p.suffix.lower() == ".plist"])
            if pl:
                choice = st.selectbox("Select Plist", [p.name for p in pl], key="plist_select_top")
                sel_pl = root / choice
                if st.button("Open plist", key="open_plist_btn"):
                    d = load_plist_safe(sel_pl)
                    if d is None:
                        st.error("Failed to parse (binary/encrypted?). Try biplist or ensure decrypted.")
                    else:
                        st.code(json.dumps(d, indent=2))
            else:
                st.caption("No plist files at root.")

        with cols[3]:
            st.markdown("**Quick Paths**")
            common = [
                "Library/SMS/sms.db",
                "Library/CallHistoryDB/CallHistory.storedata",
                "Library/Preferences/com.apple.cellularusage.plist",
                "Library/Preferences/com.apple.MobileSMS.plist",
                "Library/Maps/History.mapsdata",
                "Library/Preferences/com.apple.iTunesStore.plist",
                "Library/Health/healthdb.sqlite",
                "Library/Caches/locationd/consolidated.db",
                "Library/Caches/locationd/Cache.sqlite",
            ]
            for rel in common:
                p = root / rel
                if p.exists():
                    if p.suffix.lower() == ".plist":
                        if st.button(f"Open {rel}"):
                            d = load_plist_safe(p)
                            st.code(json.dumps(d, indent=2) if d else "Unable to parse.")
                    elif p.suffix.lower() in {".db", ".sqlite", ".sqlite3"}:
                        if st.button(f"Tables {rel}"):
                            st.json(read_sqlite_head(p))
                else:
                    st.caption(f"{rel}: —")

    else:
        # Single-file view is handled above in actions
        st.info("Select a backup folder for full decode view.")

    st.markdown("---")
    st.markdown("### Module Stubs (cards)")
    cc1, cc2, cc3, cc4 = st.columns(4)
    with cc1:
        st.info("Messages Parser\n\n• iMessage/WhatsApp merge\n• Attachments map\n• Emotion/intent NLP\n\n[Pending]")
    with cc2:
        st.info("Locations & Timeline\n\n• KnowledgeC clusters\n• KML export\n• Significant locations\n\n[Pending]")
    with cc3:
        st.info("Media & EXIF\n\n• Photos/HEIC EXIF\n• Face/scene tags\n• Camera roll mapping\n\n[Pending]")
    with cc4:
        st.info("Accounts & Keychain\n\n• Account plists\n• Token hygiene\n• Keychain (if available)\n\n[Pending]")

    st.markdown("### Notes")
    st.caption(
        "• Place backups under MOD-IOS/target_/ as UDID/UUID folders. "
        "Encrypted backups require the correct password; decrypted data is written to '<UUID>__decrypted'. "
        "Loose files (e.g., Manifest.db, Manifest.plist, *wal) are selectable for quick inspection."
    )

if __name__ == "__main__":
    main()