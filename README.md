# Native Nations Atlas · v0.1.0

A mobile-first, community-respectful atlas of Native American / American Indian / Alaska Native nations and communities, with future extensions for Indigenous peoples across the Americas subject to distinct local naming and governance.

## Scope
Nations and sovereignty; homelands, land and treaties; living villages and public visitor guidance; museums; public events; languages and dialects; publicly shared spiritual traditions; arts, adornment, music, foodways, ecology, historical sources and contemporary community initiatives.

## Source and cultural safeguards
- Tribal government and community-authored sources take priority; clearly mark external sources.
- Distinguish historical and present-day geographies; never infer exact boundaries from generalized maps.
- Respect public/private boundaries for ceremonies, sacred places, oral knowledge and personal data.
- Use community-preferred names, and provide a correction and removal process.
- No scraped copyrighted media, unlicensed audio, or unverified event dates.
- Track record-level source URL, publisher, access date, evidence status, permissions and last review.

## Deploy
On a Mac with git and GitHub CLI (`gh`) installed and authenticated, unzip this package and run `bash bin/deploy.sh`. Optionally set `ATLAS_REPO=owner/repository` and `ATLAS_DEST=/path/to/checkout`. The script creates a **public** GitHub repository if it does not exist; set `ATLAS_VISIBILITY=private` for private. Existing working trees with changes are not overwritten; deploy refuses to proceed. Existing tags are not replaced. Release publication requires `gh` authentication.

## Local preview
Open `app/index.html` in a browser. No backend required.

## Roadmap
v0.2: nation records, source ledger, verified links; v0.3: public event feeds and museums; v0.4: languages and culturally reviewed exhibits; v0.5: map with appropriate geographic precision and permissions.
