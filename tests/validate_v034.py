from pathlib import Path
import sys,json
r=Path(sys.argv[1])
assert (r/'app/index.html').exists()
assert (r/'app/aa-preview.html').exists()
assert (r/'auth/config.example.php').exists()
assert 'not enforced' in (r/'auth/README.md').read_text()
assert not any((r/p).exists() for p in ['auth/config.php','auth/users.json','auth/auth.db'])
print('v0.3.4 AA contract/preview validation OK')
