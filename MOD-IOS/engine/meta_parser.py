#!/usr/bin/env python3
import argparse, sqlite3, pandas as pd, json, sys
from pathlib import Path
def main():
    p=argparse.ArgumentParser();
    p.add_argument('--session',required=True); args=p.parse_args()
    sess=Path(args.session); db=sess/'session.sqlite'
    conn=sqlite3.connect(db)
    # exif
    for f in sess.glob('exif_audit/*.json'):
        df=pd.read_json(f); df.to_sql('exif',conn,if_exists='append',index=False)
    # ffprobe
    for f in sess.glob('ffprobe/*.json'):
        df=pd.read_json(f); df.to_sql('ffprobe',conn,if_exists='append',index=False)
    # timeline
    for f in sess.glob('fs_timeline/*_timeline.csv'):
        df=pd.read_csv(f); df.to_sql('timeline',conn,if_exists='append',index=False)
    conn.close()
if __name__=='__main__':
    main()
