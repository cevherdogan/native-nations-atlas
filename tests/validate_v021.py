import pathlib,sys,json
r=pathlib.Path(sys.argv[1]); h=(r/'app/index.html').read_text(); d=json.loads((r/'data/atlas.json').read_text()); assert d['version']=='0.2.1'; assert len(d['regions'])==9; assert len(d['modules'])==13; assert 'prefers-reduced-motion' in h and 'palettes=' in h and 'liquid' in h; assert (r/'legacy/v0.2.0/app/index.html').exists(); print('v0.2.1 visual validation OK')
