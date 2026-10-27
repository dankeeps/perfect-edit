---
name: perfect-edit
description: Perfect Edit — corte + edição dinâmica de anúncio e VSL vertical, do jeito que o Daniel aprovou. Parte 1 (Perfect Cut) corta brutos conferindo com o roteiro, tira erros, tomadas repetidas, conversa com a equipe e TODO silêncio. Parte 2 edita no Atlas (Octo Edição) no modelo Puro DR: B-roll na palavra certa alternando tela cheia, dividida e expert recortado no canto, B-rolls científicos (partículas, moléculas, células) nas falas de hormônio, legenda branca logo abaixo do pescoço em cada take, P&B e efeitos sonoros, trilha no volume certo. Parte 3 tem as montagens especiais: clone lado a lado, depoimentos de outra versão, juntar lead + VSL. Use quando pedirem "corta e edita", "edição dinâmica", "perfect edit", "/perfect-edit", "coloca B-roll", "edita a lead/VSL", ou mandarem brutos com roteiro para virar anúncio pronto. Só cortar: Parte 1. Só ajustar uma edição pronta no Atlas: Parte 2.
---

# Perfect Edit

```
PE=~/.claude/skills/perfect-edit
PYC=$PE/.venv/bin/python                  # corte (faster-whisper + VAD)
PYA=~/"Octo Edição/Atlas"/.venv/bin/python # edição (Atlas)
L=~/"Octo Edição/Atlas"/lib; E="$PYA $L/estudio.py"; ED=$PE/scripts/edicao; SC=$PE/scripts/corte
```
Instalação na máquina nova: `./install.sh` (cria a .venv do corte, clona o Atlas do GitHub e prepara a .venv dele).
Chaves da Apify (TikTok) e da OpenRouter (Gemini, que estuda os B-rolls) ficam no ⚙ Configurações do Atlas.

---

## Parte 1 — Corte (Perfect Cut)

Padrão: **terminou uma palavra, já entra a outra.** De cada frase fica a última tomada boa. Um arquivo por anúncio,
na ordem do roteiro, resolução original.

1. **Material**: roteiros (anote nome, marcações `[Pessoa / cena]`, "não precisa gravar", "usar do outro vídeo") e brutos.
   Pasta do Google Drive para desktop → **copie** os brutos para o trabalho antes. Confirme pela fala que o bruto é
   daquele anúncio (nome de pasta engana).
2. **Transcrever em blocos** (em segundo plano): `$PYC $SC/preparar.py "<brutos>" --trabalho "<trab>" --prompt "termos"`.
   Em blocos, as tomadas repetidas aparecem (numa passada só, o Whisper as engole).
3. **Ler `transcricao.txt` inteiro contra o roteiro** e decidir: última tomada, sai conversa com a equipe e alucinação
   (`Tchau`, `Obrigado`, o prompt), fica palavra diferente mas certa e nome trocado de propósito (avisar no fim).
   Palavra esticada `⟨≥1s⟩` → `$PYC $SC/conferir.py <trab> fonte CHAVE:ini:fim` (segundos). Diálogo gravado por
   personagem → intercale as partes (a mesma chave pode repetir no plano). "Usar do outro vídeo" → a parte vem da chave do
   outro anúncio.
4. **plano.json** (`keep` por índices ou `{"t":[a,b]}`, `fora` por tempo) e `$PYC $SC/cortar.py <trab> NOME` — um primeiro.
5. **Três rodadas de revisão, sempre**: (1) leitura + escuta dos duvidosos antes do plano; (2) `conferir.py pausas` (meta 0
   ≥ 0,2 s, A/V ≤ 2 quadros) e `conferir.py texto`; (3) ouvir com `janela` cada `delete`, `insert` > 1 palavra e palavra
   deformada — **insert de frase inteira = retomada escondida** → `fora`, renderizar de novo, repetir 2 e 3.
   Fala corrida longa (VSL): `repeticoes.py arquivo` (janela de 4 s, whisper-cli) pega repetição sem pausa.

---

## Parte 2 — Edição dinâmica no Atlas (Puro DR)

Projeto por anúncio a partir do vídeo cortado:
```
$E novo --nome "<nome>" --video "<cortado.mp4>" --estilo puro-dr --expert "<Expert>" --oferta "<Oferta>"
$PYA $ED/puro_dr.py integral "<nome>" && $E rascunho "<nome>"     # rascunho = fala com tempo no edicao.py
$E preparar "<nome>"                                              # recorte do expert (canto/dividida), em 2º plano
```

### B-roll: de onde vem
1. Biblioteca primeiro: `$PYA $ED/puro_dr.py biblioteca "<nome>"` (só clipes estudados, disponíveis, da pasta Expert ›
   Oferta). **Clipe usado num anúncio não volta em outro** (`puro_dr.py reservar` na escolha).
2. Faltou → TikTok: `/usr/bin/python3 $L/tiktok.py buscar "<nome>" "<rótulo>" "termo en-US" "termo" --n 12 --regiao US`
   (o Gemini estuda só os novos; texto queimado o vídeo todo = excluído). ~15–25% saem limpos: prefira termos
   "cinematic / aesthetic / raw / no text". Não rode duas buscas grandes ao mesmo tempo (a Apify estoura 900 s).
3. Antes de usar, **olhe os quadros** (`motor.py <versão> preview t1 t2…`, juntando numa folha): a ficha erra.

### O que entra e onde (feedback do Daniel)
- **Científicos** (moléculas, células, DNA, neurônios, corpo/hormônio brilhando) em toda fala de hormônio, enzima,
  metabolismo. Termos que renderam: "hormone molecules 3d", "cells 3d animation", "dna glowing particles", "neurons firing
  cinematic", "human body hologram", "endocrine system 3d", "thyroid 3d animation", "blood vessels 3d animation".
- **Gancho** com B-roll literal na palavra mais visual (ex.: "barriga dura e redonda" → um barrigudo de verdade).
- **Densidade**: criativo dinâmico ~10–12 B-rolls/min ("pode colocar bem mais"); misture cheia, dividida e **canto
  (expert recortado do fundo)** — pelo menos 40% fora da cheia.
- **Sem B-roll** em interação entre duas pessoas (diálogo, clone): só o vídeo e a legenda.
- **Tela dividida** só com clipe em que o assunto aparece inteiro na metade de cima; se cortar rosto/corpo, use `crop=[x,y,w,h]`
  no `E.broll` ou troque por cheia. Clipe horizontal só na dividida.
- **Final de VSL (oferta, bônus, garantias)**: sem B-roll de pessoas — só ilustrações (relógio, cronômetro, 3D, objetos),
  motions e letreiros. Casal/detox "estragam a vibe".
- **Troca de cor/take** no meio da fala → cubra a emenda com um B-roll cheio (ex.: fósforo acendendo em "sair do ar").
- P&B (`E.pb`) nas falas de dor ("nada aconteceu", "efeito rebote").

### Montar e conferir
- `edicao.py`: `E.broll("cheia"|"dividida"|"canto", "<âncora>", ate="<âncora>", broll="ID", ini=s, crop=[...])`. Âncoras de
  2–3 palavras (contar ocorrência pega a errada em silêncio). O cursor só anda pra frente.
- `$E plano "<nome>" --forcar` até sumir toda linha `regra:` (cheia 1,2–3,5 s, dividida 2–5, canto 3–6; respiro 1,5 s,
  direto só dividida→cheia e cheia→cheia, máx. 3 seguidas). `plano --forcar` **zera sfx_extras e posição de legenda**:
  guarde e recoloque (ou edite o plano.json direto se o Daniel mexeu no editor).
- `$PYA $L/motor.py <versão> cabecas` → recorte do canto/dividida.
- **Legenda**: branca, **logo abaixo do pescoço em cada take**: `$PYA $ED/legenda_por_take.py "<nome>" --abaixo -0.01`
  (mede os ombros a cada 0,5 s; a altura única erra quando um take é close e o outro corpo inteiro). Onde houver imagem
  importante (quadro com antes/depois), baixe a legenda daquele trecho (`lg["y"]` no plano).
- Zoom num trecho (ex.: quadro com fotos): `P["zoom"]` com pontos `[t, z, "suave"]` e `P["ancora"]=[x, y]`.
- **Trilha**: `$PYA $ED/trilha.py musica.wav "<nome>" --abaixo 19 --nome trilha.wav` (volumes aprovados no docstring).
  Só instrumental (teste com Whisper). Criativo curto: sem música. VSL: baixa, principalmente no começo.
- **SFX** saem pelas regras do modelo; extras (`sfx_extras` no plano: impacto na abertura, whoosh na troca de cena, sub-boom,
  glitch no P&B, riser antes da virada) para dar ritmo à lead.
- Render: `$E render "<nome>"` (um de cada vez — dois juntos derrubam o render). Confira duração, LUFS (−14) e quadros.
- Entrega na timeline: Atlas no ar (porta 4123) → `http://localhost:4123/editor?p=<nome>&v=A`.

---

## Parte 3 — Montagens especiais

- **Clone lado a lado** (mesma pessoa em dois papéis, tripé): `python3 $ED/clone_lado_a_lado.py plano_clone.json` — quem
  não fala já faz a ação desde o 1º quadro; confira o volume de cada parte (tempos trocados = parte muda). Depois a cena
  vai na frente do resto cortado (`concat`) e o conjunto vira o projeto no Atlas.
- **Espelhar um trecho** (quadro escrito ao contrário, antes/depois invertido):
  `ffmpeg -i in.mp4 -filter_complex "[0:v]split[a][b];[b]hflip[f];[a][f]overlay=enable='between(t,T0,T1)'[v]" -map "[v]" -map 0:a -c:a copy out.mp4`
  e recrie o projeto (as âncoras por palavra mantêm a edição).
- **Juntar lead + VSL**: mesmo formato → `ffmpeg -f concat -safe 0 -i lista.txt -c copy -movflags +faststart saida.mp4`.
- **Depoimentos de outra versão** (V0): `python3 $ED/inserir_depoimentos.py plano_dep.json` — depoimento com áudio entra
  depois da frase-gancho e empurra o vídeo; imagem (antes/depois) entra por cima da fala, sem áudio. Imprime a minutagem
  para mandar ao Daniel. Confira transcrevendo só cada trecho inserido.

## Entrega
Um arquivo por anúncio em `~/Downloads/<lote>/`, com o nome do roteiro. Resposta curta: o que foi feito, o que foi
conferido (pausas, texto, quadros, volume) e os avisos (nome trocado, fala não gravada, clipe que não existia limpo).
