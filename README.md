# VCuida — home em HTML/CSS

Recriação da home de <https://vcuida.com.br/> (hoje feita em Elementor) em HTML e CSS
escritos à mão, para que alterações sejam feitas direto no código.

Sem build, sem dependência, sem JavaScript. É só abrir o `index.html`.

## Estrutura

```
index.html                 a página inteira, uma <section> por bloco
assets/css/fonts.css       @font-face de Kanit e Montserrat (arquivos locais)
assets/css/base.css        reset, tokens de cor/tipografia, .container
assets/css/sections.css    o estilo de cada seção, na ordem da página
assets/fonts/              Kanit (latin + latin-ext) e Montserrat (subsetados)
assets/img/                as imagens do site
```

`sections.css` está dividido por banners (`/* ===== 03-planos-cards ===== */`) na mesma
ordem das seções do `index.html`. Para mexer em um bloco, ache o banner correspondente.

## Onde alterar as coisas mais pedidas

| O que | Onde |
|---|---|
| Preços dos planos | `index.html`, seção `planos-cards` |
| Textos e títulos | `index.html` — o texto está no HTML, não em CSS |
| Link do WhatsApp | `index.html`, buscar por `wa.me` (aparece 4x) |
| Cores da marca | `assets/css/base.css`, bloco `:root` |
| Um card de benefício | `index.html`, seção `benefits`, cada card é um `<article>` |
| Espaçamento de uma seção | `assets/css/sections.css`, no banner da seção |

Os breakpoints são os mesmos do Elementor e só existem dois:
`@media (max-width: 1024px)` e `@media (max-width: 767px)`.

## Preview no ar

A **v2** está publicada em GitHub Pages para o cliente ver:

**<https://willy-azevedo.github.io/vcuida-site/>**

- Repositório: <https://github.com/willy-azevedo/vcuida-site> (público)
- Branch `main`: o projeto inteiro — v1 na raiz, v2 em `v2/`
- Branch `gh-pages`: só a v2, servida na raiz do Pages

Para atualizar o preview depois de mexer na v2:

```bash
./publicar-preview.sh
```

O script monta o branch `gh-pages` num worktree temporário, copia `v2/` para a raiz
e injeta `<meta name="robots" content="noindex, nofollow">` mais um `robots.txt` com
`Disallow: /`. **Esses dois só existem na cópia do Pages**, nunca em `v2/index.html` —
assim não há risco de subir um `noindex` junto com a página quando ela for para o
WordPress. O preview não é indexado pelo Google, mas quem tiver o link acessa: são os
preços novos e um redesign ainda não lançado, então trate o link como interno.

## Como visualizar

```bash
python3 -m http.server 4173 --directory /Users/willyazevedo/Projetos/vcuida-testes
```

Depois abra <http://localhost:4173>. Servidor é necessário por causa das fontes
(`file://` bloqueia o carregamento delas).

## Fidelidade — como foi verificada

Não foi no olho. Para cada breakpoint mediu-se o topo e a altura das 7 seções no site
no ar e neste código, com o mesmo script:

| viewport | site no ar | este código | resultado |
|---|---|---|---|
| 1440px | 2950px de altura | 2950px | as 7 seções batem |
| 1024px | 3050px | 3050px | as 7 seções batem |
| 390px  | 5091px | 5091px | as 7 seções batem |

A comparação foi feita forçando a fonte de fallback neste código, para isolar a única
diferença real entre os dois — explicada logo abaixo.

## A fonte Montserrat está quebrada no site no ar

No WordPress atual, os `@font-face` de "Montserrat Custom" apontam para URLs em `http://`:

```
http://vcuida.com.br/wp-content/uploads/2023/12/Montserrat-Medium.ttf
```

Como o site é servido em `https://`, o navegador bloqueia por mixed content. Verificado
no console do site no ar: os pesos 400, 500 e 600 ficam com `status: "error"`, e
`document.fonts.check('500 15px "Montserrat Custom"')` devolve `false`.

Resultado: **todo o texto de corpo do site hoje renderiza em Arial**, não em Montserrat.
Os arquivos existem e respondem normalmente em `https://` — é só o protocolo errado na
declaração.

Este código usa o Montserrat de verdade. Por isso alguns parágrafos quebram em uma linha
a mais do que no site no ar (Montserrat é mais largo que Arial nesse corpo), e a página
fica ~48px mais alta no desktop. Isso é o layout **correto**, não um desvio.

Se por algum motivo for preciso reproduzir o render quebrado, troque em
`assets/css/base.css`:

```css
--ff-body: Arial, Helvetica, sans-serif;
```

## Publicar no WordPress

A página não usa nada dinâmico, então há dois caminhos:

1. **Template de página em child theme** — criar um child theme de `hello-elementor`,
   colar o conteúdo do `<body>` em `page-home.php`, enfileirar os três CSS com
   `wp_enqueue_style` e mandar os assets para `wp-content/themes/<child>/assets/`.
   Mantém o WordPress no controle da URL, do SEO e do restante do site.

2. **HTML estático** — servir o arquivo direto pelo Nginx na VPS. Mais rápido, mas tira
   a home do WordPress; só vale se as outras páginas também saírem de lá.

Em qualquer um dos dois, conferir antes: a URL canônica, as meta tags (já estão no
`<head>` deste arquivo) e os redirects existentes.

## Fora do escopo

Só a home. As páginas `/saibamais/` e a de política de privacidade continuam no Elementor.
