#!/usr/bin/env python3
import yaml, sys
from pathlib import Path

cfg = yaml.safe_load(open(Path(__file__).parent.parent / 'config' / 'config.yaml'))
modules = cfg.get('default', {}).get('modules', [])
for m in modules:
    print(m)
