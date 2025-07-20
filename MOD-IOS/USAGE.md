# USAGE.md

## Purpose
Official CLI reference for cli/meta-ios.sh.

---

## Command Syntax
```bash
./cli/meta-ios.sh --input <path_to_backup> [--module <module_name>]
```

## Flags
- `--input <path>`   Required: path to the iOS backup directory.
- `--module <name>`  Optional: run only that module.
- `-h, --help`       Show help.

---

## Examples

1. Run all modules:
   ```bash
   ./cli/meta-ios.sh --input /data/ios_backup_xyz
   ```

2. Run only exif_audit:
   ```bash
   ./cli/meta-ios.sh --input /data/ios_backup_xyz --module exif_audit
   ```
