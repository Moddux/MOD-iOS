u""
Parse_Decode Integration Module
Provides iOS backup parsing and decoding functionality
"""

import sqlite3
import pandas as pd
import plistlib
import json
from datetime import datetime
from pathlib import Path
import hashlib

class IOSBackupParser:
    """Enhanced iOS backup parser with Streamlit integration"""
    
    def __init__(self, backup_path):
        self.backup_path = Path(backup_path)
        self.manifest_db = self.backup_path / "Manifest.db"
        self.conn = None
        
    def connect(self):
        """Connect to Manifest.db"""
        if self.manifest_db.exists():
            self.conn = sqlite3.connect(str(self.manifest_db))
            return True
        return False
    
    def get_backup_info(self):
        """Get basic backup information"""
        info = {
            'path': str(self.backup_path),
            'manifest_exists': self.manifest_db.exists(),
            'size_mb': sum(f.stat().st_size for f in self.backup_path.rglob('*') if f.is_file()) / (1024*1024)
        }
        
        # Try to get device info from Info.plist
        info_plist = self.backup_path / "Info.plist"
        if info_plist.exists():
            try:
                with open(info_plist, 'rb') as f:
                    plist_data = plistlib.load(f)
                    info.update({
                        'device_name': plist_data.get('Device Name', 'Unknown'),
                        'ios_version': plist_data.get('Product Version', 'Unknown'),
                        'serial_number': plist_data.get('Serial Number', 'Unknown'),
                        'backup_date': plist_data.get('Last Backup Date', 'Unknown')
                    })
            except:
                pass
                
        return info
    
    def list_tables(self):
        """List all tables in Manifest.db"""
        if not self.conn:
            return []
        
        query = "SELECT name FROM sqlite_master WHERE type='table';"
        df = pd.read_sql_query(query, self.conn)
        return df['name'].tolist()
    
    def get_files_by_domain(self, domain_keywords):
        """Get files filtered by domain keywords"""
        if not self.conn:
            return pd.DataFrame()
        
        domain_filters = " OR ".join([f"LOWER(domain) LIKE '%{kw}%'" for kw in domain_keywords])
        query = f"""
        SELECT fileID, domain, relativePath, flags
        FROM Files
        WHERE {domain_filters}
        LIMIT 1000
        """
        return pd.read_sql_query(query, self.conn)
    
    def decode_plist_blob(self, blob_data):
        """Decode plist blob data"""
        try:
            plist_data = plistlib.loads(blob_data)
            return self._convert_plist_timestamps(plist_data)
        except Exception as e:
            return {"error": str(e)}
    
    def _convert_plist_timestamps(self, data):
        """Convert plist timestamps to readable format"""
        if isinstance(data, dict):
            return {k: self._convert_plist_timestamps(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [self._convert_plist_timestamps(v) for v in data]
        elif isinstance(data, (int, float)) and 946684800 < data < 4102444800:
            try:
                return datetime.utcfromtimestamp(data).isoformat() + "Z"
            except:
                return data
        return data
    
    def get_messages(self):
        """Extract message-related files"""
        keywords = ['message', 'sms', 'imessage', 'chat']
        return self.get_files_by_domain(keywords)
    
    def get_photos(self):
        """Extract photo-related files"""
        keywords = ['photo', 'image', 'camera', 'media']
        return self.get_files_by_domain(keywords)
    
    def get_locations(self):
        """Extract location-related files"""
        keywords = ['location', 'gps', 'maps', 'position', 'corelocation']
        return self.get_files_by_domain(keywords)
    
    def get_contacts(self):
        """Extract contact-related files"""
        keywords = ['contact', 'addressbook']
        return self.get_files_by_domain(keywords)
    
    def get_crash_reports(self):
        """Extract crash report files"""
        keywords = ['crash', 'crashreport', 'diagnostic', 'panic']
        return self.get_files_by_domain(keywords)
    
    def get_app_activity(self):
        """Extract app activity files"""
        keywords = ['app', 'install', 'uninstall', 'download', 'store']
        return self.get_files_by_domain(keywords)
    
    def get_file_inventory(self):
        """Get complete file inventory"""
        if not self.conn:
            return pd.DataFrame()
        
        query = """
        SELECT fileID, domain, relativePath, flags, file
        FROM Files
        ORDER BY domain, relativePath
        """
        return pd.read_sql_query(query, self.conn)
    
    def close(self):
        """Close database connection"""
        if self.conn:
            self.conn.close()
