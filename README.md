# Perfect Cut

Skill do Claude Code que corta brutos de gravação conferindo com o roteiro. Ela tira os erros, as tomadas
repetidas, a conversa com a equipe e **todo** silêncio entre as palavras, e entrega um vídeo por anúncio, na ordem
do roteiro e na resolução original.

## Instalar

```bash
git clone https://github.com/dankeeps/perfect-cut.git ~/perfect-cut && ~/perfect-cut/install.sh
```

Precisa de Python 3.10 ou mais novo e do ffmpeg (`brew install ffmpeg`). Na primeira transcrição, o modelo do
Whisper (large-v3-turbo, ~1,6 GB) é baixado para `~/.cache/perfect-cut`.

## Usar

No Claude Code, mande a pasta dos brutos e os roteiros e peça `/perfect-cut` ou "corta esses brutos".

## Como funciona

| etapa | script | o que faz |
|---|---|---|
| 1 | `preparar.py` | transcreve cada trecho de fala sozinho, para as tomadas repetidas aparecerem |
| 2 | (Claude) | lê a transcrição contra o roteiro e escreve o `plano.json` com o que fica |
| 3 | `cortar.py` | renderiza: VAD Silero + energia do áudio, sem nenhuma pausa, emendas de 4 ms |
| 4 | `conferir.py` | pausas que sobraram, sincronia A/V, re-transcrição comparada e escuta dos trechos suspeitos |

O detalhe de cada decisão está no [SKILL.md](SKILL.md).
