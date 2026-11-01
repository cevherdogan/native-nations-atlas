from pathlib import Path
import sys,json
root=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).resolve().parents[1]
loc=root/'app/locations'
usa=(loc/'index.html').read_text()
assert 'href="new-york.html"' in usa and 'href="pennsylvania.html"' in usa
assert 'href="ny-corning.html"' not in usa and 'href="pa-lancaster.html"' not in usa
ny=(loc/'new-york.html').read_text();pa=(loc/'pennsylvania.html').read_text()
for r in json.loads((root/'data/usa_locations.json').read_text())['locations']:
 k=r['id'];parent=r['parent']
 if k.startswith('ny-'):assert parent=='new-york' and f'href="{k}.html"' in ny
 if k.startswith('pa-'):assert parent=='pennsylvania' and f'href="{k}.html"' in pa
 if k.startswith(('ny-','pa-')):assert 'Terrain & watershed orientation' in (loc/(k+'.html')).read_text()
print('v0.3.3 navigation and geographic context validation OK')
