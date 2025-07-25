#!/usr/bin/env python3
import sqlite3
import pandas as pd
from collections import defaultdict
from pathlib import Path

DB_PATH = Path.home() / "MOD-IOS/DB/meta_analysis.db"
REPORTS_DIR = Path.home() / "MOD-IOS/REPORTS"
REPORTS_DIR.mkdir(parents=True, exist_ok=True)

def connect_db():
    return sqlite3.connect(DB_PATH)

def fetch_metadata(conn):
    return pd.read_sql_query("SELECT filename, field, value FROM metadata", conn)

def analyze_field_consistency(df):
    report = []
    total_files = df['filename'].nunique()
    presence = df.groupby('field')['filename'].nunique()
    for field, count in presence.items():
        if count < total_files:
            report.append({
                'field': field,
                'present_in': count,
                'missing_from': total_files - count
            })
    return pd.DataFrame(report)

def detect_differences(df):
    diff = defaultdict(set)
    for _, row in df.iterrows():
        diff[row['field']].add(row['value'])
    inconsistent = {k: v for k, v in diff.items() if len(v) > 1}
    return pd.DataFrame([(k, list(v)) for k, v in inconsistent.items()], columns=["Field", "Values"])

def save_report(df, filename):
    out_path = REPORTS_DIR / filename
    df.to_csv(out_path, index=False)
    print(f"[✓] Saved: {out_path}")

def main():
    conn = connect_db()
    df = fetch_metadata(conn)
    save_report(analyze_field_consistency(df), "inconsistent_field_presence.csv")
    save_report(detect_differences(df), "conflicting_field_values.csv")
    print("[✓] Done. Reports in ~/MOD-IOS/REPORTS")

if __name__ == "__main__":
    main()
