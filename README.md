# Perfect Edit

Skill do Claude Code para levar o bruto até o anúncio pronto, do jeito que o Daniel aprovou:

1. **Corte (Perfect Cut)**: confere com o roteiro, tira erros, tomadas repetidas e todo silêncio.
2. **Edição dinâmica (Atlas / Puro DR)**: B-roll na palavra certa em tela cheia, dividida e com o expert recortado no canto,
   científicos nas falas de hormônio, legenda branca abaixo do pescoço, P&B, efeitos e trilha no volume certo.
3. **Montagens especiais**: clone lado a lado, espelhar trecho, juntar lead + VSL, colocar depoimentos de outra versão.

## Instalar

```bash
git clone https://github.com/dankeeps/perfect-edit.git ~/perfect-edit && ~/perfect-edit/install.sh
```

Precisa de Python 3.10+, ffmpeg e o `gh` logado na conta dankeeps (o Atlas é um repositório privado). Depois, abra o Atlas
e ponha as chaves da Apify e da OpenRouter em ⚙ Configurações.

## Usar

No Claude Code: `/perfect-edit`, ou "corta e edita esses brutos" com a pasta e os roteiros.

O detalhe de cada decisão (e o feedback que virou regra) está no [SKILL.md](SKILL.md).
