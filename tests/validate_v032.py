from pathlib import Path
import sys
r=Path(sys.argv[1])
assert (r/'docs/VISUAL_SYSTEM.md').exists()
assert '--terrain' in (r/'app/style.css').read_text()
assert len(list((r/'app/locations').glob('*.html'))) >= 14
for p in (r/'app').rglob('*.html'):
 assert 'visual-ribbon' in p.read_text(),p
print('v0.3.2 visual checks OK')
