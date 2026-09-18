#!/usr/bin/env bash
# Publica a v2 no GitHub Pages, na raiz do branch gh-pages.
#
# Por que existe: o Pages é um preview para o cliente ver, não a produção.
# O <meta robots="noindex"> e o robots.txt são injetados AQUI, na cópia, e nunca
# entram em v2/index.html — assim não há risco de subir um noindex para o
# WordPress junto com a página.
#
# Uso:  ./publicar-preview.sh
set -euo pipefail

raiz="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'git -C "$raiz" worktree remove --force "$tmp" 2>/dev/null || true; rm -rf "$tmp"' EXIT

cd "$raiz"

if git show-ref --quiet refs/heads/gh-pages; then
  git worktree add -q "$tmp" gh-pages
  find "$tmp" -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} +
else
  git worktree add -q --orphan -b gh-pages "$tmp"
fi

cp -R v2/. "$tmp"/
rm -f "$tmp/README.md"

# noindex logo depois do <head>, só nesta cópia
python3 - "$tmp/index.html" <<'PY'
import sys, io
p = sys.argv[1]
html = io.open(p, encoding='utf-8').read()
tag = ('<meta name="robots" content="noindex, nofollow">\n'
       '<!-- Injetado por publicar-preview.sh: vale só para o preview do GitHub Pages. -->\n')
assert '<head>' in html and 'name="robots"' not in html
io.open(p, 'w', encoding='utf-8').write(html.replace('<head>', '<head>\n' + tag, 1))
print('noindex injetado')
PY

printf 'User-agent: *\nDisallow: /\n' > "$tmp/robots.txt"
touch "$tmp/.nojekyll"   # sem isso o Jekyll ignora pastas iniciadas por _

cd "$tmp"
git add -A
if git diff --cached --quiet; then
  echo "nada mudou — preview já está atualizado"
  exit 0
fi
git commit -q -m "Preview da v2 — $(git -C "$raiz" rev-parse --short HEAD)"
git push -q -u origin gh-pages
echo "publicado: https://willy-azevedo.github.io/vcuida-site/"
