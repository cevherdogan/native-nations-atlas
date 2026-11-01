import json,sys,pathlib
root=pathlib.Path(sys.argv[1]); required=['app/index.html','README.md','data/schema.json','docs/CHANGELOG.md','docs/RELEASE_POLICY.md','bin/deploy.sh']
for name in required:
    assert (root/name).is_file(),f'Missing: {name}'
schema=json.loads((root/'data/schema.json').read_text())
assert len(schema['categories'])>=10
html=(root/'app/index.html').read_text()
assert 'Native Nations Atlas' in html and 'viewport' in html
print('Validation passed:',len(required),'files and schema')
