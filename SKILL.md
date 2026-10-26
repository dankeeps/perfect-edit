---
name: perfect-cut
description: Perfect Cut — corta brutos de gravação (anúncio, criativo, VSL, talking head) conferindo com o roteiro. Tira erros, tomadas repetidas, conversa com a equipe, alucinação do Whisper e TODO silêncio entre as palavras (terminou uma palavra, já entra a outra), e entrega um arquivo por anúncio na ordem do roteiro, com resolução original. Use quando pedirem para "cortar o bruto", "tirar os erros", "tirar o silêncio", "jump cut", "deixar só a fala", "corte perfeito", "/perfect-cut", ou mandarem uma pasta de brutos (ou um link do Drive) com os roteiros. Não é para edição completa (B-roll, letreiro, legenda, SFX).
---

# Perfect Cut

Padrão de qualidade: **terminou uma palavra, já entra a outra, sem nenhum instante sem fala.** Barulho sem ninguém
falando também sai. De cada frase fica a **última tomada boa**. Um arquivo por anúncio, na ordem do roteiro, com a
resolução, a proporção e o fps do bruto.

```
PC=~/.claude/skills/perfect-cut; PY=$PC/.venv/bin/python; SK=$PC/scripts
```
(instalação: `./install.sh` no repositório; cria a `.venv` com faster-whisper e o VAD Silero)

## 1. Juntar o material

- **Roteiros**: colados no chat ou num doc. Anote por anúncio o nome, as marcações `[Pessoa / cena]`, os trechos
  "não precisa gravar" e os "usar do outro vídeo".
- **Brutos**: `ls -R` na pasta e `ffprobe` (duração, largura×altura). Cada subpasta costuma ser um anúncio, e os
  arquivos `IMG_xxxx` não dizem nada; o nome certo vem do roteiro. **Não confie no nome da pasta**: confirme pela
  transcrição que a fala bate com o roteiro daquele anúncio.
- Pasta do Google Drive para desktop (`~/Library/CloudStorage/GoogleDrive-*`) → **copie** os brutos para o trabalho
  antes (arquivo só na nuvem trava o ffmpeg). Os originais não são mexidos nem renomeados.

## 2. Transcrever em blocos (em segundo plano, ~40 s por bruto)

```
$PY $SK/preparar.py "<pasta dos brutos>" --trabalho "<trabalho>" --prompt "termos da oferta, nomes próprios"
```
Por que em blocos: **numa passada só o Whisper engole tomadas repetidas**. Ele estica uma palavra por cima de
2 a 4 s e some com a retomada. Transcrevendo cada trecho de fala sozinho, as repetições aparecem.
O `--prompt` melhora a grafia, mas vira alucinação em trecho de ruído (o dump marca `«ALUCINAÇÃO?»`).

## 3. Ler a transcrição inteira e decidir o que fica

`<trabalho>/transcricao.txt`:
```
######## K03_IMG_2935  (526 palavras | 720x1280 vertical | 179s | 30fps | áudio com ruído de fundo, piso -49 dB)
@42.2  130:Mas 131:como 132:que 133:um 134:cara ...
```
Cada linha é um bloco de fala (começa no tempo). `NN:palavra` é o índice usado no plano. `⟨2.3s⟩` = palavra esticada.

Regras (sempre comparando com o roteiro):
- **Retomada**: frase ou pedaço repetido → fica **a última tomada**; sai tudo desde o ponto em que ela recomeça.
  Sinais: palavra com `...`, bloco que termina no meio da frase, a mesma frase de novo logo depois.
- **Retomada no meio da frase**: fica o começo da primeira + a retomada a partir do ponto em que ela recomeça
  (`[38,42]` + `[53,67]`). Cuidado com palavra dobrada na emenda ("como" + "Como o Leandro" → corte antes do primeiro).
- **Sai**: conversa com a equipe ("seria bom que o bagulho andasse, né?"), falso começo, frase atropelada e
  alucinação (`Tchau, tchau`, `Obrigado`, o próprio prompt no começo do bruto). Nunca deixe alucinação dentro de
  uma faixa: parta a faixa em volta dela.
- **Fica**: palavra diferente do roteiro mas certa ("pra" em vez de "para", nome de aluno trocado de propósito).
  Só sai tropeço, repetição e fala fora do roteiro. Nome trocado → avisar no fim.
- **Palavra esticada `⟨≥1s⟩`**: ouvir o trecho sozinho: `$PY $SK/conferir.py <trab> fonte CHAVE:ini:fim`
  (**segundos**, não índices). Retomada escondida → `fora` ou faixa por tempo.
- **Bruto sem fala**: `conferir.py <trab> quadro CHAVE:seg` e olhe a imagem antes de decidir.
- **Vários arquivos num anúncio**: um arquivo só, na ordem do roteiro. **Diálogo gravado por personagem** →
  intercale as partes na ordem das falas (a mesma chave pode aparecer várias vezes no plano).
- **"Não precisa gravar, usar do outro vídeo"** → a parte vem da chave do outro anúncio, no ponto do roteiro.
  Comece na palavra que o roteiro pede (ex.: pular "Eu vou te explicar aqui no quadro" se o roteiro começa em "Você precisa").
- Fala do roteiro que não foi gravada → corte o que existe e avise.

## 4. Plano e render

`<trabalho>/plano.json` (exemplo completo em `plano.exemplo.json`):
```json
{"saida": "~/Downloads/cortados",
 "cortes": {
  "K01": [{"key": "K01_IMG_2953", "keep": [[0,11]]},
          {"key": "K01_IMG_2954", "keep": [[0,7]]},
          {"key": "K01_IMG_2953", "keep": [[12,28],[33,50]]}],
  "K03": [{"key": "K03_IMG_2935", "keep": [[2,118],[130,176]], "fora": [[129.2,132.2]]}]
 }}
```
- `keep` = faixas de índices (inclusive) ou `{"t":[ini,fim]}`. `fora` = trechos por tempo que saem mesmo dentro de um keep.
- `manter` (por parte) = trechos por tempo que o corte de energia não pode picar (fala rápida embolada).
- `"formato": {"<nome>": {"w":1080,"h":1920,"fps":30}}` no topo = anúncio que junta câmeras diferentes (escala e
  iguala o fps). Mantenha a proporção de como o vídeo aparece (4K vertical → 1080×1920).

```
$PY $SK/cortar.py <trabalho> K04          # renderize UM primeiro e confira
$PY $SK/cortar.py <trabalho>              # depois os outros (em segundo plano)
```
O que o `cortar` faz (números calibrados, não mexa sem motivo): VAD Silero com dois limiares + palavras (tira pausa
≥ 150 ms, deixa 1 quadro de cada lado); energia (tira trecho abaixo do limiar por ≥ 120 ms, que pega o respiro de
0,3 s que o VAD guarda como fala); em bruto com ruído (piso > −50 dB) protege o miolo das palavras; cortes no grade
de quadros, fade de 4 ms em cada emenda, H.264 CRF 16, AAC 192k.

## 5. Revisar: três rodadas, sempre

1. **Antes do plano**: transcrição lida inteira contra o roteiro e todo trecho duvidoso ouvido sozinho (`fonte`).
2. **Máquina, depois do render**:
   ```
   $PY $SK/conferir.py <trabalho> pausas     # meta: 0 pausas ≥ 0,2 s e A/V com no máx. 1–2 quadros de diferença
   $PY $SK/conferir.py <trabalho> texto      # re-transcreve a saída e compara com o que devia ficar
   ```
3. **Ouvido, nos pontos suspeitos**: todo `delete`, todo `insert` de mais de uma palavra e toda palavra deformada →
   `conferir.py <trab> janela NOME:ini:fim`. **`insert`/`replace` que vira frase inteira = retomada escondida que a
   primeira passada não pegou** (ex.: "E isso funciona tão bem por três motivos" duas vezes). Ache o tempo no bruto
   com `fonte`, ponha em `fora`, renderize de novo e repita as rodadas 2 e 3 só nesse anúncio.

Diferença de grafia ("pro"/"para o", "8"/"oito") é normal. Pausa de 0,2 a 0,4 s numa emenda entre frases também.

Opcional, para fala muito corrida: `repeticoes.py arquivo.mp4` (janela curta de 4 s; precisa do whisper-cli e do
modelo ggml em `~/whisper-models/`).

## 6. Entregar

- Um `.mp4` por anúncio com o nome do roteiro, na pasta pedida (padrão `~/Downloads/cortados`).
- Resposta curta: quantos foram cortados, o que foi conferido (pausas zeradas, % de texto batendo, A/V) e os
  avisos: anúncio sem bruto, fala não gravada, arquivos juntados ou intercalados, take reaproveitado de outro
  anúncio, nome trocado, clipe mudo deixado de fora.
