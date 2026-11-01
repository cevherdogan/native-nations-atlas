import json,pathlib,sys
p=pathlib.Path(sys.argv[1]);d=json.loads((p/'data/resources.json').read_text());assert len(d['records'])==22
for r in d['records']:assert (p/'app/resources'/ (r['slug']+'.html')).exists()
assert (p/'legacy/v0.2.1/app/index.html').exists()
print('v0.3.0 structural validation OK')
