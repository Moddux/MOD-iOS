#!/usr/bin/env python3
import streamlit as st
import sqlite3, pandas as pd
from pathlib import Path
st.set_page_config(page_title="MOD-IOS Dashboard", layout="wide")
st.title("MOD-IOS Forensic Dashboard")
base = Path(st.text_input("Session directory", "./reports"))
if base.exists():
    db = list(base.glob("*/session.sqlite"))
    if db:
        conn = sqlite3.connect(str(db[0]))
        st.sidebar.subheader("Tables")
        tables = pd.read_sql("SELECT name FROM sqlite_master WHERE type='table';", conn)
        table = st.sidebar.selectbox("Table", tables['name'])
        df = pd.read_sql(f"SELECT * FROM {table} LIMIT 100;", conn)
        st.write(df)
        conn.close()
    else:
        st.warning("No session.sqlite found.")
else:
    st.error("Directory not found.")
