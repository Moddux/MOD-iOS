#!/usr/bin/env python3
import argparse, sqlite3, pandas as pd
from pathlib import Path
def detect(session: Path, out: Path):
    db = session / 'session.sqlite'
    if not db.exists(): return
    conn = sqlite3.connect(str(db))
    df = pd.read_sql("SELECT * FROM fs_timeline", conn)
    if 'mtime' in df.columns and 'crtime' in df.columns:
        ann = df[df['mtime'] < df['crtime']]
        out.mkdir(parents=True, exist_ok=True)
        ann.to_csv(out / 'time_anomalies.csv', index=False)
    conn.close()
def main():
    p = argparse.ArgumentParser()
    p.add_argument('--session', required=True)
    args = p.parse_args()
    session = Path(args.session)
    detect(session, session / 'anomalies')
if __name__ == '__main__':
    main()
