import json, pathlib, sys
r=pathlib.Path(sys.argv[1]); d=json.loads((r/'data/atlas.json').read_text()); assert d['version']=='0.2.0';assert len(d['regions'])==9;assert len(d['modules'])>=12;assert d['nations']==[];html=(r/'app/index.html').read_text();assert 'Pan-American' in html and 'Arctic' in html;assert (r/'legacy/v0.1.0/app/index.html').exists();print('v0.2.0 validation OK')
