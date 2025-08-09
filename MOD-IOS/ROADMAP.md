# ROADMAP.md

## Phase 1: Core (✓)
- [x] Scaffold & Docker
- [x] meta-ios.sh entrypoint
- [x] EXIF, FFprobe, MediaInfo, Foremost, FLS

## Phase 2: Parsing & Storage (In Progress)
- [x] meta_parser.py ingestion
- [x] SQLite schema
- [ ] Parse_Decode.py integration into dashboard modules

## Phase 3: Reporting & GUI (In Progress)
- [x] Streamlit dashboard (basic version exists at engine/dashboard.py)
- [ ] Enhanced dashboard with Parse_Decode integration
- [ ] HTML/PDF report
- [ ] GPS map

## Phase 4: Advanced Modules
- [ ] SMS & contacts DB analysis
- [ ] Plist parsing
- [ ] Malware scan

## Phase 5: Polishing
- [ ] Error handling
- [ ] Central config
- [ ] Publish Docker image

## Phase 6: Parse_Decode Integration Plan (NEW)
- [ ] Refactor Parse_Decode.py for dashboard integration
- [ ] Create modular cards for dashboard
- [ ] Implement stubs for Parse_Decode functionality
- [ ] Add data visualization components
- [ ] Create export functionality

---

## Parse_Decode.py Integration Implementation Plan

### Overview
The Parse_Decode.py module needs to be refactored and integrated into the Streamlit dashboard as modular components. This will provide forensic analysts with interactive tools to parse and decode iOS backup data.

### Integration Architecture

#### 1. Dashboard Module Structure
```
engine/
├── dashboard.py (main Streamlit app)
├── modules/
│   ├── __init__.py
│   ├── parse_decode_module.py
│   ├── data_cards.py
│   └── visualization.py
├── stubs/
│   ├── parse_decode_stub.py
│   └── data_loader.py
└── cards/
    ├── location_card.py
    ├── messages_card.py
    ├── contacts_card.py
    ├── crash_card.py
    └── app_activity_card.py
```

#### 2. Parse_Decode.py Refactoring Requirements

**Current Issues:**
- Hard-coded database paths
- No modular structure
- No Streamlit integration
- Missing error handling

**Refactoring Plan:**
- Extract core parsing functions into reusable modules
- Add configuration management
- Implement data validation
- Add Streamlit-compatible output formats

#### 3. Dashboard Integration Components

**Main Dashboard Sections:**
1. **File Explorer Card**: Navigate iOS backup structure
2. **Location Analytics Card**: GPS and significant locations
3. **Messages Card**: SMS/iMessage analysis
4. **Contacts Card**: Address book parsing
5. **App Activity Card**: Installed/removed apps
6. **Crash Reports Card**: System crash analysis
7. **Network Card**: IP addresses and network data

#### 4. Implementation Steps

**Week 1: Foundation**
- [ ] Refactor Parse_Decode.py into modular functions
- [ ] Create data loader stub for Streamlit compatibility
- [ ] Implement basic card structure

**Week 2: Core Features**
- [ ] Integrate location parsing into dashboard
- [ ] Add messages parsing with search/filter
- [ ] Implement contacts visualization

**Week 3: Advanced Features**
- [ ] Add crash report analysis
- [ ] Implement app activity timeline
- [ ] Create export functionality (CSV/JSON/PDF)

**Week 4: Polish & Testing**
- [ ] Add error handling and validation
- [ ] Implement caching for performance
- [ ] Create comprehensive test suite

#### 5. Technical Specifications

**Data Flow:**
```
iOS Backup → Parse_Decode Module → Streamlit Dashboard → User Interface
```

**Key Functions to Implement:**
- `load_backup_data(backup_path)` - Load iOS backup
- `parse_location_data()` - Extract GPS/location data
- `parse_messages()` - Extract SMS/iMessage data
- `parse_contacts()` - Extract address book
- `parse_crash_reports()` - Extract crash data
- `parse_app_activity()` - Extract app install/remove data

**Streamlit Components:**
- `st.file_uploader()` - Backup file selection
- `st.sidebar` - Navigation and filters
- `st.dataframe()` - Tabular data display
- `st.map()` - Location visualization
- `st.plotly_chart()` - Interactive charts
- `st.download_button()` - Export functionality

#### 6. Dependencies & Requirements

**Python Packages:**
- streamlit
- pandas
- sqlite3
- plistlib
- json
- datetime
- pathlib
- plotly (for charts)
- folium (for maps)

**System Requirements:**
- Python 3.8+
- iOS backup files (Manifest.db)
- 2GB RAM minimum
- 1GB disk space for processed data

#### 7. Testing Strategy

**Unit Tests:**
- Test individual parsing functions
- Test data validation
- Test error handling

**Integration Tests:**
- Test dashboard workflow
- Test data export functionality
- Test performance with large datasets

**User Acceptance Tests:**
- Test with real iOS backups
- Validate forensic accuracy
- Test user interface usability

#### 8. Deployment Plan

**Development Environment:**
- Local development with sample data
- Docker containerization
- GitHub Actions CI/CD

**Production Deployment:**
- Docker image optimization
- Performance monitoring
- User documentation
- Video tutorials

### Success Metrics
- [ ] Successfully parse 95%+ of iOS backup data
- [ ] Dashboard load time < 5 seconds for 1GB backups
- [ ] Zero data loss during processing
- [ ] User satisfaction score > 4.5/5
