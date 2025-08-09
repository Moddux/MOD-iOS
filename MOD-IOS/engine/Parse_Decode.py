# Re-import libraries and reconnect after state reset
import sqlite3
import pandas as pd
import plistlib
from datetime import datetime
import json

# Reconnect to the database
db_path = "/mnt/data/Manifest.db"
conn = sqlite3.connect(db_path)
# List all tables in the database
tables_query = "SELECT name FROM sqlite_master WHERE type='table';"
tables = pd.read_sql_query(tables_query, conn)
tables?# Define specific domains of interest # type: ignore
target_domains = ['message', 'sms', 'imessage', 'chat',
                  'photo', 'image', 'camera', 'media',
                  'itunes', 'appstore', 'store', 'app', 'download']

# Build LIKE filters for these domains
domain_filters = " OR ".join([f"LOWER(domain) LIKE '%{kw}%'" for kw in target_domains])

# Query matching records from Files table
domain_filtered_query = f"""
SELECT fileID, domain, relativePath, flags
FROM Files
WHERE {domain_filters}
"""
domain_filtered_df = pd.read_sql_query(domain_filtered_query, conn)

import ace_tools as tools; tools.display_dataframe_to_user(name="Filtered by Specific Domains", dataframe=domain_filtered_df)
# Re-define helper functions
def convert_plist_timestamps(data):
    if isinstance(data, dict):
        return {k: convert_plist_timestamps(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [convert_plist_timestamps(v) for v in data]
    elif isinstance(data, (int, float)) and 946684800 < data < 4102444800:
        try:
            return datetime.utcfromtimestamp(data).isoformat() + "Z"
        except:
            return data
    return data

def safe_serialize(obj):
    if isinstance(obj, bytes):
        return obj.hex()
    if isinstance(obj, (plistlib.UID,)):
        return str(obj)
    if isinstance(obj, dict):
        return {k: safe_serialize(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [safe_serialize(v) for v in obj]
    return obj

def build_like_clause(keywords):
    return " OR ".join([f"LOWER(domain) LIKE '%{kw}%'" for kw in keywords])

def fetch_and_decode_category(keywords):
    clause = build_like_clause(keywords)
    query = f"""
    SELECT fileID, domain, relativePath, flags, file
    FROM Files
    WHERE {clause}
    """
    df = pd.read_sql_query(query, conn)

    decoded = []
    for _, row in df.iterrows():
        try:
            plist_data = plistlib.loads(row['file'])
            plist_data = convert_plist_timestamps(plist_data)
            result = safe_serialize(plist_data)
        except Exception as e:
            result = f"Failed to decode: {e}"
        decoded.append({
            'fileID': row['fileID'],
            'domain': row['domain'],
            'relativePath': row['relativePath'],
            'flags': row['flags'],
            'decoded': result
        })
    return pd.DataFrame(decoded)

# Define keyword sets for each category
location_keywords = ['location', 'gps', 'maps', 'position', 'corelocation']
contact_keywords = ['contact', 'addressbook']
call_keywords = ['call', 'phone', 'telephony', 'voicemail']
app_keywords = ['whatsapp', 'facebook', 'instagram', 'tiktok', 'snapchat', 'messenger', 'app']

# Fetch and decode all four categories
location_df = fetch_and_decode_category(location_keywords)
contacts_df = fetch_and_decode_category(contact_keywords)
calls_df = fetch_and_decode_category(call_keywords)
apps_df = fetch_and_decode_category(app_keywords)

# Export all categories to separate JSON files
paths = {}
for name, df in [('location', location_df), ('contacts', contacts_df), 
                 ('calls', calls_df), ('apps', apps_df)]:
    path = f"/mnt/data/decoded_{name}.json"
    df.to_json(path, orient='records', indent=2)
    paths[name] = path

paths# Export summaries to both CSV and JSON formats
export_files = {}

# Define export function
def export_summary(df, name):
    csv_path = f"/mnt/data/{name}.csv"
    json_path = f"/mnt/data/{name}.json"
    df.to_csv(csv_path, index=False)
    df.to_json(json_path, orient="records", indent=2)
    return {"csv": csv_path, "json": json_path}

# Perform export for all summaries
export_files["significant_locations"] = export_summary(significant_summary, "summary_significant_locations")
export_files["crash_reports"] = export_summary(crash_summary, "summary_crash_reports")
export_files["app_activity"] = export_summary(app_summary, "summary_app_removed_downloaded")
export_files["ip_addresses"] = export_summary(ip_summary, "summary_ip_network")

export_files# Load the previously exported JSON files
significant_df = pd.read_json("/mnt/data/decoded_significant_locations.json")
crash_df = pd.read_json("/mnt/data/decoded_crash_reports.json")
app_df = pd.read_json("/mnt/data/decoded_app_removed_or_downloaded.json")
ip_df = pd.read_json("/mnt/data/decoded_ip_addresses.json")

# Helper to flatten and extract meaningful fields
def extract_values_from_dict(records, keys_of_interest):
    extracted = []
    for record in records:
        row = {
            'fileID': record.get('fileID'),
            'domain': record.get('domain'),
            'relativePath': record.get('relativePath')
        }
        decoded = record.get('decoded')
        if isinstance(decoded, dict):
            for key in keys_of_interest:
                val = decoded.get(key)
                if val:
                    row[key] = val
        extracted.append(row)
    return pd.DataFrame(extracted)

# Extract summaries from each dataset
significant_summary = extract_values_from_dict(significant_df.to_dict(orient='records'), ['latitude', 'longitude', 'timestamp', 'location', 'visit', 'region'])
crash_summary = extract_values_from_dict(crash_df.to_dict(orient='records'), ['crashTime', 'process', 'reason', 'uuid'])
app_summary = extract_values_from_dict(app_df.to_dict(orient='records'), ['downloadDate', 'redownloadDate', 'appIdentifier', 'uninstallDate'])
ip_summary = extract_values_from_dict(ip_df.to_dict(orient='records'), ['ip_address', 'IPAddress', 'dhcp_lease', 'router', 'subnet', 'ssid'])

# Display summaries to user
import ace_tools as tools
tools.display_dataframe_to_user(name="Significant Locations Summary", dataframe=significant_summary)
tools.display_dataframe_to_user(name="Crash Reports Summary", dataframe=crash_summary)
tools.display_dataframe_to_user(name="App Removed or Downloaded Summary", dataframe=app_summary)
tools.display_dataframe_to_user(name="IP Address / Network Summary", dataframe=ip_summary)import plistlib

# Extract the selected BLOBs from the rows at iloc[2:3] and iloc[1:3]
selected_blobs = orphaned_files_df.iloc[1:3]['file']

# Attempt to decode each BLOB using plistlib
decoded_plists = []
for blob in selected_blobs:
    try:
        plist_data = plistlib.loads(blob)
        decoded_plists.append(plist_data)
    except Exception as e:
        decoded_plists.append(f"Failed to decode: {e}")

decoded_plists# Check what fields are present in the summary datasets
summary_columns = {
    "significant_locations": significant_df.columns.tolist(),
    "crash_reports": crash_df.columns.tolist(),
    "ip_addresses": ip_df.columns.tolist()
}

summary_columns# Define narrower focus on just Messages and Photos
narrow_domains = ['message', 'sms', 'imessage', 'chat', 'photo', 'image', 'camera']

# Build LIKE filters for narrower domain scope
narrow_filters = " OR ".join([f"LOWER(domain) LIKE '%{kw}%'" for kw in narrow_domains])

# Query matching files
narrow_filtered_query = f"""
SELECT fileID, domain, relativePath, flags, file
FROM Files
WHERE {narrow_filters}
"""
narrow_filtered_df = pd.read_sql_query(narrow_filtered_query, conn)
# Define narrower focus on just Messages and Photos
narrow_domains = ['message', 'sms', 'imessage', 'chat', 'photo', 'image', 'camera']

# Build LIKE filters for narrower domain scope
narrow_filters = " OR ".join([f"LOWER(domain) LIKE '%{kw}%'" for kw in narrow_domains])

# Query matching files
narrow_filtered_query = f"""
SELECT fileID, domain, relativePath, flags, file
FROM Files
WHERE {narrow_filters}
"""
narrow_filtered_df = pd.read_sql_query(narrow_filtered_query, conn)

# Decode blobs
decoded_narrow_entries = []
for _, row in narrow_filtered_df.iterrows():
    try:
        plist_data = plistlib.loads(row['file'])
        plist_data = convert_plist_timestamps(plist_data)
        decoded = safe_serialize(plist_data)
    except Exception as e:
        decoded = f"Failed to decode: {e}"
    decoded_narrow_entries.append({
        'fileID': row['fileID'],
        'domain': row['domain'],
        'relativePath': row['relativePath'],
        'flags': row['flags'],
        'decoded': decoded
    })

# Export to JSON
decoded_narrow_df = pd.DataFrame(decoded_narrow_entries)
json_narrow_path = "/mnt/data/decoded_messages_photos.json"
decoded_narrow_df.to_json(json_narrow_path, orient='records', indent=2)

json_narrow_path
# Decode blobs
decoded_narrow_entries = []
for _, row in narrow_filtered_df.iterrows():
    try:
        plist_data = plistlib.loads(row['file'])
        plist_data = convert_plist_timestamps(plist_data)
        decoded = safe_serialize(plist_data)
    except Exception as e:
        decoded = f"Failed to decode: {e}"
    decoded_narrow_entries.append({
        'fileID': row['fileID'],
        'domain': row['domain'],
        'relativePath': row['relativePath'],
        'flags': row['flags'],
        'decoded': decoded
    })

# Export to JSON
decoded_narrow_df = pd.DataFrame(decoded_narrow_entries)
json_narrow_path = "/mnt/data/decoded_messages_photos.json"
decoded_narrow_df.to_json(json_narrow_path, orient='records', indent=2)

json_narrow_path# Load the previously exported JSON files
significant_df = pd.read_json("/mnt/data/decoded_significant_locations.json")
crash_df = pd.read_json("/mnt/data/decoded_crash_reports.json")
app_df = pd.read_json("/mnt/data/decoded_app_removed_or_downloaded.json")
ip_df = pd.read_json("/mnt/data/decoded_ip_addresses.json")

# Helper to flatten and extract meaningful fields
def extract_values_from_dict(records, keys_of_interest):
    extracted = []
    for record in records:
        row = {
            'fileID': record.get('fileID'),
            'domain': record.get('domain'),
            'relativePath': record.get('relativePath')
        }
        decoded = record.get('decoded')
        if isinstance(decoded, dict):
            for key in keys_of_interest:
                val = decoded.get(key)
                if val:
                    row[key] = val
        extracted.append(row)
    return pd.DataFrame(extracted)

# Extract summaries from each dataset
significant_summary = extract_values_from_dict(significant_df.to_dict(orient='records'), ['latitude', 'longitude', 'timestamp', 'location', 'visit', 'region'])
crash_summary = extract_values_from_dict(crash_df.to_dict(orient='records'), ['crashTime', 'process', 'reason', 'uuid'])
app_summary = extract_values_from_dict(app_df.to_dict(orient='records'), ['downloadDate', 'redownloadDate', 'appIdentifier', 'uninstallDate'])
ip_summary = extract_values_from_dict(ip_df.to_dict(orient='records'), ['ip_address', 'IPAddress', 'dhcp_lease', 'router', 'subnet', 'ssid'])

# Display summaries to user
import ace_tools as tools
tools.display_dataframe_to_user(name="Significant Locations Summary", dataframe=significant_summary)
tools.display_dataframe_to_user(name="Crash Reports Summary", dataframe=crash_summary)
tools.display_dataframe_to_user(name="App Removed or Downloaded Summary", dataframe=app_summary)
tools.display_dataframe_to_user(name="IP Address / Network Summary", dataframe=ip_summary)# Define new keyword sets for the requested categories
significant_location_keywords = ['significantlocation', 'visits', 'locationd', 'corelocation', 'mobility']
crash_report_keywords = ['crash', 'crashreport', 'diagnostic', 'panic']
removed_app_keywords = ['uninstall', 'remove', 'deleted', 'appstate', 'download', 'redownload']
ip_address_keywords = ['ipaddress', 'network', 'wifi', 'dhcp', 'tcp', 'connection']

# Helper to run queries and decode
def process_category(category_name, keywords):
    clause = build_like_clause(keywords)
    query = f"""
    SELECT fileID, domain, relativePath, flags, file
    FROM Files
    WHERE {clause}
    """
    df = pd.read_sql_query(query, conn)

    decoded = []
    for _, row in df.iterrows():
        try:
            plist_data = plistlib.loads(row['file'])
            plist_data = convert_plist_timestamps(plist_data)
            result = safe_serialize(plist_data)
        except Exception as e:
            result = f"Failed to decode: {e}"
        decoded.append({
            'fileID': row['fileID'],
            'domain': row['domain'],
            'relativePath': row['relativePath'],
            'flags': row['flags'],
            'decoded': result
        })
    output_df = pd.DataFrame(decoded)
    path = f"/mnt/data/decoded_{category_name}.json"
    output_df.to_json(path, orient='records', indent=2)
    return path

# Process each requested category
export_paths = {
    "significant_locations": process_category("significant_locations", significant_location_keywords),
    "crash_reports": process_category("crash_reports", crash_report_keywords),
    "app_removed_or_downloaded": process_category("app_removed_or_downloaded", removed_app_keywords),
    "ip_addresses": process_category("ip_addresses", ip_address_keywords)
}

export_paths # type: ignore