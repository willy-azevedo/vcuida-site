# VCuida — v2 (ajustes pedidos pelo cliente)

Segunda versão da home, com as alterações do PPTX **"ajuste pagina VCuida"**.
Duplicata independente da v1: tem o próprio `index.html` e a própria pasta `assets/`.
A v1, em `../index.html`, **não foi tocada**.

Sem build e sem dependência. Todo o JavaScript da página é inline: o menu do mobile
e as animações de entrada (ver as seções abaixo).

## O que mudou em relação à v1

### Entrou
- **Header** no topo: logo com "Cuidando de você.", menu O que é / Planos / Contato
  e botão "Acesso Portal RH" (gradiente magenta→azul).
- **Seção "O que é"** (`id="o-que-e"`): grade de 6 cards à esquerda e bloco de texto
  institucional à direita.

### Mudou
- **Hero**: o H1 virou "Saúde para quem faz a sua empresa acontecer" (saiu "mais acessível"),
  entrou o subtítulo "Telemedicina, consultas online e muito mais em um clique.", o logo saiu
  (foi para o header) e o fundo virou um gradiente em CSS, não mais a imagem `Novo-Projeto-27.webp`.
- **Subtítulo dos planos**: duas linhas, citando opção individual ou família para até 3 dependentes.
- **Cards de plano**: reformulados por completo — ordem, preços, cores, lista de features e botão.
  Ver a tabela abaixo.
- **"Clique aqui e saiba mais"**: passou a apontar para o mesmo WhatsApp do "CONTRATE AGORA",
  conforme a anotação em vermelho do cliente no PPTX.
- **Rodapé**: quatro blocos — logo VCuida, "Contrate agora", "Suporte ao beneficiário"
  e "um produto / Vallora". Recebeu `id="contato"`, alvo do menu.

### Saiu
- A seção **"Facilidades e Benefícios"** inteira (a grade de 10 ícones). Quatro dos itens
  migraram para a nova grade de 6 cards da seção "O que é".

### Continua igual
- (nada — o botão flutuante "Acessar área logada" foi removido a pedido da cliente,
  ver "Pedidos da cliente" abaixo)

## Pedidos da cliente (Camila, WhatsApp)

1. **"Acesso Portal RH" passou a apontar para `https://portalplugin.nexusaa.com.br/`**
   (era `webapp.vcuida.com.br`). Conferido: a URL responde 200, sem redirecionamento.
2. **O botão flutuante "Acessar área logada" saiu.** Isso reverte a decisão anterior de
   manter os dois botões de acesso. Junto com ele saíram os 74px que o rodapé reservava
   no mobile só para o botão fixo não cobrir o link da política de privacidade.
3. **O header ficou fixo** (`position: sticky`, não `fixed`: sticky continua ocupando
   espaço no fluxo, então o hero não precisa de compensação e nada pula quando o header
   aparece). `z-index: 300` para vencer o hero, a faixa de planos e os cards, que já
   disputam camada entre si. As âncoras do menu ganharam
   `scroll-margin-top: var(--h-header)` — sem isso o header fixo taparia o topo da seção
   de destino. O token vale 83px no desktop, 79px até 1024 e 61px no mobile.

## Planos: o antes e o depois

| | v1 | v2 |
|---|---|---|
| ordem | TOTAL, MENTAL, ESSENCIAL | MENTAL, ESSENCIAL, TOTAL |
| MENTAL | R$ 11,90 | **R$ 7,90** |
| ESSENCIAL | R$ 7,90 | **R$ 11,90** |
| TOTAL | R$ 16,90 | R$ 16,90 |
| cor do cabeçalho | gradiente / creme / lilás | `#70C1AC` / `#CC0099` / `#00B0F0` |
| descrição | um parágrafo | lista de features com check |
| botão | verde `#61CE70` | roxo `#7030A0`, no pé do card |

Os três cards têm a mesma altura e os botões alinhados na mesma linha, mesmo com listas
de tamanhos diferentes.

## Menu mobile

Abaixo de 767px o menu deixa de ser uma segunda linha de links e vira um hambúrguer:

- **Header de 102px → 61px.** Uma linha só: logo · botão do portal · hambúrguer.
- **O rótulo do botão encurta** de "Acesso Portal RH" (161px) para "Portal RH" (105px).
  O texto completo fica no `aria-label`, então o leitor de tela continua ouvindo o nome
  inteiro nas duas larguras. A troca é só um `<span>` escondido no breakpoint.
- **O painel abre por cima do hero**, em `position: absolute`, sem empurrar a página.
- Fecha ao escolher um item, ao tocar fora e com `Esc`; o botão devolve o foco.
- `aria-expanded` e `aria-controls` no botão, com o rótulo alternando entre
  "Abrir menu" e "Fechar menu".

**Por que tem JavaScript aqui.** Um `<details>/<summary>` ou o truque do checkbox dariam
o mesmo visual sem script, mas nenhum dos dois fecha o painel quando a pessoa escolhe um
item — o menu ficaria aberto por cima do conteúdo depois do clique. São 20 linhas inline,
sem dependência e sem requisição extra. O resto da página continua sem script.

## Animações de entrada

Cada bloco marcado com `data-anim` nasce 22px abaixo e transparente, e sobe ao entrar na
tela. São 14 no total: título, subtítulo e mockup do hero (escalonados em 100ms), a grade
e o texto da 2ª dobra, o título e o subtítulo dos planos, os três cards (escalonados em
120ms), o CTA e os dois blocos do rodapé.

Só `opacity` e `transform`, que o navegador compõe sem recalcular layout — a altura da
página é a mesma com e sem animação (2977px no desktop).

**Três travas, e cada uma existe por um motivo:**

1. **Sem JavaScript, nada some.** A regra que esconde depende de `.js-anim` no `<html>`,
   colocada por um script no `<head>` antes da primeira pintura. Sem script, a classe não
   entra e a página aparece inteira.
2. **`prefers-reduced-motion: reduce` desliga tudo.** Não é enfeite: movimento de entrada
   dispara enjoo em quem tem distúrbio vestibular.
3. **Nada de `IntersectionObserver`.** O padrão comum — esconder no CSS e revelar no
   callback do observer — tem um modo de falha ruim: se o observer não dispara, a página
   fica em branco. E ele não dispara quando o documento não está sendo desenhado (foi
   exatamente o que aconteceu ao testar com o painel oculto: zero de 14 revelados). Aqui a
   revelação é um teste de posição no evento de scroll, acelerado por tempo e não por
   `requestAnimationFrame` — que também só roda quando há pintura. O pior caso passa a ser
   o elemento aparecer sem animação, nunca não aparecer.

Dois detalhes que custaram bug antes de ficarem certos:

- O teste é só `topo < limite`, sem checar se o elemento **continua** na tela. Num salto de
  rolagem — o menu leva para `#planos` — as seções do meio passam entre duas medições, e
  exigir que ainda estivessem visíveis as deixava escondidas para sempre.
- No fim da página o desconto de 10% da dobra sai. Com ele, quem está nos últimos pixels
  nunca cruzaria o limite, porque a rolagem acaba antes.

Para tirar a animação de um bloco, apague o `data-anim` dele no `index.html`. Para mudar
duração ou distância, o bloco fica no fim do `assets/css/base.css`.

## Âncoras: a chegada tem de estar pronta

Clicar em "Planos" levava a uma cena montando na frente de quem chegou. A primeira
tentativa de correção preparava os `[data-anim]` **descendentes da seção-alvo** — e isso
só resolveu metade, porque o que preenche a tela na chegada não é o que está dentro do alvo:

- `#planos` é a `<section class="plans-head">` e contém só o título e o subtítulo. Os **três
  cards de preço** vivem na seção irmã `.planos-cards`, puxada 240px para cima por
  `margin-top: -240px` — eles aterrissam na tela sem serem descendentes do alvo.
- `#contato` é o rodapé, mas a rolagem bate no fim do documento **529px antes** de alcançá-lo,
  deixando o bloco de CTA na tela.

Medido antes da correção: ao parar a rolagem em `#planos`, os cards ainda estavam deslocados
9 / 14 / 19px e só assentavam 500ms depois, a 254–313px do topo da tela.

A função passou a preparar **o que vai estar na tela quando a rolagem parar**, e não o que
está dentro do alvo. Isso exige três coisas que não são óbvias:

1. `Math.min(topo, scrollHeight - alturaTela)` — onde o navegador realmente para, que nem
   sempre é onde o alvo está (caso do `#contato`).
2. Descontar o `scroll-margin-top`: com header fixo o navegador para 83px acima do topo da
   seção, então a faixa logo acima também aterrissa na tela.
3. Varrer todos os `[data-anim]`, não só os pendentes — um elemento já revelado pode estar
   no meio da transição de 650ms e também precisa ser travado.

Verificado: **zero elementos com `opacity < 1` ou deslocados** no instante da chegada, nas
três âncoras, em desktop e mobile.

### Três defeitos vizinhos, encontrados junto

- **Os cards de plano e o botão do CTA não animavam: estalavam.** Eles declaram o próprio
  `transition` em `sections.css`, com a mesma especificidade do `[data-anim]` de `base.css` —
  e como `sections.css` carrega depois, ganhava e apagava a transição de entrada. Agora
  `opacity` entra na lista de cada um. No card do desktop só `opacity`: `transform` já está
  lá por causa do lift, e repetir faria a última declaração vencer, trocando os 500ms
  lineares do hover pelos 650ms da entrada.
- **O atraso do escalonamento vazava para o hover.** `.plano--total[data-anim]` é mais
  específico que `.plano`, e o `transition-delay` vale para a lista inteira: o lift do
  terceiro card só começava 240ms depois do ponteiro chegar. O atributo `data-anim` agora é
  removido 1200ms após a entrada — depois disso ele não serve mais para nada.
- **`Esc` com o menu fechado jogava a página ao topo.** O handler chamava `burger.focus()`
  sem verificar se havia algo aberto: quem estivesse navegando por teclado no meio do
  conteúdo perdia 2900px de posição e o foco. Agora ele sai cedo se o menu já está fechado.

Em movimento reduzido o `transition: none` saiu: naquele modo não existe entrada para cortar,
e ele atingia também as transições de interação — o card teleportava 30px sob o cursor em vez
de simplesmente não se mexer. O lift agora é suprimido de propósito nesse modo, e a sombra
continua dando o retorno de hover.

## Rolagem horizontal fantasma (corrigido)

Os pontinhos decorativos da seção de planos ficam de propósito fora do container e chegavam
a `x=1339` numa tela de 390px. O `html, body { overflow-x: hidden }` herdado da v1 escondia
isso, mas o `<body>` continuava sendo um contêiner de rolagem de 1339px — e **um contêiner
com overflow escondido ainda pode ser rolado por programa**. Na prática: ao focar o botão do
menu, o navegador rolava o body 155px e a página inteira saía do lugar.

A correção é `overflow: hidden` na própria `.plans-head`, que é full-bleed — o corte cai
exatamente na borda da tela, igual ao que já se via, e o `body.scrollWidth` volta a ser
igual ao `clientWidth`. Vale para os três breakpoints.

**E o `overflow-x` do `html, body` virou `clip`.** Isso não é preciosismo: `overflow-x: hidden`
transforma o elemento num contêiner de rolagem, e um contêiner de rolagem **quebra
`position: sticky` em qualquer descendente**. O header estava declarado `sticky`, o
`getComputedStyle` devolvia `sticky`, e ele descia junto com a página assim mesmo — medido,
`headerTop: -1200` com a página em 1200. `overflow-x: clip` corta igual sem criar contêiner
de rolagem, e o sticky passa a funcionar. Com a origem do estouro já resolvida na
`.plans-head`, o `clip` ficou só como rede de segurança.

## Estrutura

```
index.html                 a página inteira, uma <section> por bloco
assets/css/fonts.css       @font-face de Kanit e Montserrat
assets/css/base.css        reset + tokens (inclui os tokens novos da v2)
assets/css/sections.css    estilo por seção, na ordem da página
assets/fonts/              Kanit e Montserrat subsetados
assets/img/                imagens (inclui logo-vcuida-tagline.webp, novo)
```

## Tokens novos (em `assets/css/base.css`)

```
--c-header-band    #F2F2F2   faixa do header
--c-teal           #70C1AC   card MENTAL e checks das features
--c-plan-essencial #CC0099   card ESSENCIAL
--c-plan-total     #00B0F0   card TOTAL
--c-purple         #7030A0   botão CONTRATE AGORA
--c-purple-dark    #5B2483   hover do CONTRATE AGORA
--c-price          #595959   "A partir de", "R$" e o valor
--c-card-line      #EFE9F2   borda da grade de cards
--g-portal         gradiente do botão "Acesso Portal RH"
--hero-crimson / --hero-blue / --hero-orange / --hero-navy
                             os quatro cantos do gradiente do hero
```

## Passe de design sobre o mockup

O PPTX do cliente é um paste-up feito no PowerPoint, não um design. A primeira montagem
reproduziu as medidas dele ao pé da letra e o resultado ficou pesado. Esta versão manteve
o **conteúdo e a estrutura** que o cliente pediu e refez as **proporções**:

| o que | antes | agora |
|---|---|---|
| altura do header | 162px | **83px** |
| logo do header | 210px, com a tagline em 7px (ilegível) | **140px**, recortado na marca |
| fundo do header | faixa `#F2F2F2` | branco + fio de 1px |
| vão H1 → subtítulo (hero) | 120px | **24px** |
| H1 entre 1024 e 768px | 52px, chegava a 4 linhas | **40px**, 2 linhas |
| 2ª dobra: grade vs. texto | 729 vs. 402 (∆327) | **681 vs. 526** (∆155) |
| emenda "O que é" → planos | 170px de cinza vazio | **90px** |
| vão lista → botão nos cards | 292 / 262 / 40px | **126 / 111 / 40px** |
| eixo esquerdo da página | 100 / 110 / 132px | **110px** em tudo |
| altura dos 4 botões | 38 / 38 / 42 / 64px, pesos 500 e 600 | **36 / 36 / 42 / 64px**, todos 600 |

Também corrigidos, todos medidos: no mobile os cards subiam 240px contra uma faixa de 210px
e comiam o respiro do subtítulo; o botão flutuante (na época ainda existia) cobria o link
da política de privacidade
no fim da página; o preço (Kanit 600) pesava mais que o H1 (Kanit 200) e voltou a 500; os
gutters laterais a 1024px usavam cinco valores diferentes e passaram a usar 40px.

O único desvio deliberado do mockup é o **header branco no lugar da faixa cinza** — encostada
no gradiente do hero, a faixa suja a transição. É reversível em uma linha
(`.site-header { background-color: var(--c-header-band) }`).

### Segunda volta de revisão

A primeira rodada de correções tinha um vício sistemático: quase tudo foi aplicado só na
regra base, sem descer para `@media (max-width: 1024px)` e `@media (max-width: 767px)`.
Oito dos doze achados da segunda volta eram regressões dessa natureza. Corrigidos:

| o que | estava | ficou |
|---|---|---|
| H1 em 767px | `7.1vw` = **54,5px**, maior que os 52px do desktop | `min(7.1vw, 40px)` |
| emenda "O que é" → planos | 92 / 112 / 102px (crescia ao encolher a tela) | **92 / 82 / 62px** |
| botão do header | 36 / 35 / 34px, corpo 14 / 15 / 14 | **36px e 14px nos três** |
| medida do parágrafo da 2ª dobra | 37 caracteres no desktop, **80** no tablet | teto de 640px → 45–75 |
| H2 "Escolha seu plano" a 1024 | 40px, empatado com o H1 do hero | **32px** |
| largura dos cards a 768px | 215 / 217 / 225px (grade torta) | **219px nos três** |
| botão do card a 768px | quebrava em 2 linhas, virava bloco de 56px | **169×42, uma linha** |
| divisor dos planos a 768px | 700px fixos, estourava a coluna | `min(700px, 100%)` |

Duas decisões de desenho nessa volta:

**A lista de features voltou a alinhar no topo.** Na primeira volta eu tinha dividido a
folga dos cards em dois pontos para matar um vazio de 292px — só que isso fez as três
listas começarem em alturas diferentes (126px de escada). Cartão de preço é lido na
horizontal: sem linha comum não dá para comparar os planos. O vazio acima do botão é o
preço de os três cards terem a mesma altura, e é o que o mockup do cliente desenha.

**O rodapé passou a distribuir os quatro blocos.** Com quatro células iguais os vãos
saíam 95 / 167 / 74px e o selo Vallora parava 75px antes do eixo direito da página.
Com `repeat(4, auto)` + `space-between` são três vãos de 137px e o selo fecha em 1330,
no mesmo eixo do resto.

Também saíram 20px mortos entre o botão do CTA e o rodapé (herança de um widget vazio do
Elementor) e oito tokens sem nenhum uso no `base.css`.

## Gradiente do hero

Reproduzido em CSS (duas camadas, comentadas em `sections.css`) em vez de imagem, para
ficar editável. Conferido contra o mockup do cliente amostrando os quatro cantos:

| canto | mockup | esta página |
|---|---|---|
| superior esquerdo | `#940039` | `#940039` |
| superior direito | `#003D8B` | `#013D8B` |
| inferior esquerdo | `#D76300` | `#D76300` |
| inferior direito | `#15205E` | `#14215F` |

Desvio máximo de 1/255 por canal.

## Como visualizar

```bash
python3 -m http.server 4173 --directory /Users/willyazevedo/Projetos/vcuida-testes
```

- v1: <http://localhost:4173/>
- v2: <http://localhost:4173/v2/>

## Pontos para validar com o cliente

1. **Textos corrigidos.** O PPTX trazia "os melhores medicos" e "psicólogos e nutricionitas";
   a página está com "médicos" e "nutricionistas".
2. **"atende a sua equipe"** — está literal como no PPTX. Pela norma culta seria "atende à sua equipe".
3. **"Vcuida"** no texto "Quer saber mais sobre a Vcuida" — grafia herdada do site atual,
   diferente do "VCuida" usado no resto da página.
4. **"Politica de privacidade"** sem acento — mantido como está no site no ar.
5. **Header não é fixo** no scroll; o mockup não indica. Se for para fixar, o hero precisa de
   `padding-top` compensando a altura do header.
6. **Logo do header não é clicável.** Se for para levar à home, é envolver em `<a>`.
7. **Quebra de linha do H1**: aqui quebra em "…faz a / sua empresa acontecer"; no mockup,
   renderizado em outra fonte, quebrava depois de "sua".
8. **Telefone (48) 99136-4002** no rodapé é o mesmo número que os botões de WhatsApp já usavam;
   agora ficou visível.
