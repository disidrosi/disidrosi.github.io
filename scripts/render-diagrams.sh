#!/usr/bin/env bash
# Render every .mmd file under content/ to a sibling .svg using mermaid-cli.
# Usage: npm run render:diagrams
#
# Authoring workflow: write your diagram source as `foo.mmd` next to a post's
# index.md, then run this script. Reference the generated `foo.svg` from the
# post with standard markdown image syntax: ![caption](foo.svg "title").
set -euo pipefail

config="mermaid-config.json"

while IFS= read -r -d '' mmd; do
  svg="${mmd%.mmd}.svg"
  if [[ -f "$svg" && "$svg" -nt "$mmd" ]]; then
    continue
  fi
  echo "Rendering $mmd → $svg"
  npx mmdc -i "$mmd" -o "$svg" -c "$config" -b transparent
done < <(find content -type f -name '*.mmd' -print0)
