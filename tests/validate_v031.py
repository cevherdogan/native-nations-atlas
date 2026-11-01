import pathlib,json,sys
p=pathlib.Path(sys.argv[1]); data=json.loads((p/'data/usa_locations.json').read_text()); assert len(data['locations'])==14
for item in data['locations']:
 f=p/'app/locations'/(item['id']+'.html'); assert f.exists(); assert item['name'] in f.read_text()
assert (p/'app/locations/index.html').exists()
assert 'locations/index.html' in (p/'app/index.html').read_text()
print('v0.3.1 validated: 14 location pages')
