# Toolbox de controle clássico

Cinco estratégias, **um notebook interativo para cada uma**. A ideia é enxergar o que cada estratégia acrescenta e experimentar essa diferença antes de usar em outro processo.

Os notebooks trazem códigos em português, comentários curtos, ensaios CSV com ruído, comparação P1D/P2D/P3D, escolha com parcimônia, validação final separada e sintonia IMC. A teoria, as bibliotecas, a origem dos modelos e os materiais de apoio ficam no README de cada pasta.

## Por onde começar

| Estratégia | O que ela acrescenta | Material |
|---|---|---|
| 01 — Cascata | Uma medida intermediária e uma malha interna para reagir antes da saída principal | [Pasta e explicação](estrategias/01_controle_cascata/README.md) · [Colab](https://colab.research.google.com/drive/1NXIlPniygCnQuvOYHTX7nrvKJKcmN1B3) |
| 02 — Antecipação (feedforward) | Usa a medida da perturbação para agir antes que apareça erro | [Pasta e explicação](estrategias/02_antecipacao/README.md) · [Colab](https://colab.research.google.com/drive/132PqVwWt00uGhxk0T4wMzUwh8kETtNNf) |
| 03 — Razão e limites cruzados | Coordena duas vazões; os limites cruzados definem qual delas deve mudar primeiro | [Pasta e explicação](estrategias/03_razao_limites_cruzados/README.md) · [Colab](https://colab.research.google.com/drive/1e6rVoVLpmtAASvUmJ_kE-cIBIlpE6GFa) |
| 04 — Faixa dividida (split-range) | Distribui um único comando entre recursos de atuação diferentes | [Pasta e explicação](estrategias/04_split_range/README.md) · [Colab](https://colab.research.google.com/drive/172l9HdNCzOoUF0heMQLK04Rvqr6JDvvt) |
| 05 — Seletivo (override) | Escolhe qual controlador assume o mesmo atuador quando uma restrição pede prioridade | [Pasta e explicação](estrategias/05_controle_seletivo/README.md) · [Colab](https://colab.research.google.com/drive/1vM2Ly36GAoXYpaAFQt31-j3gfqcSdEv6) |

Abra uma pasta, leia o diferencial e use o link **Abrir no Colab**. Execute as células de cima para baixo. Primeiro aparecem o processo, a identificação e sua validação; depois, a sintonia e o painel. Mude um parâmetro por vez e compare as duas situações do gráfico.

[Pasta desta versão no Google Drive](https://drive.google.com/drive/folders/1wLEY7YQ50n-6a33st90eDabJtU6B0zS7).

## Identificar antes de sintonizar

Separar três etapas: **ajustar** P1D/P2D/P3D no primeiro ensaio, **escolher** no segundo e **validar** no terceiro. Os candidatos têm 3, 4 e 5 parâmetros livres, respectivamente, polos reais estáveis e atraso estimado. Escolher o de menor ordem até 1 ponto percentual abaixo do melhor FIT no ensaio de escolha. O ensaio final não participa do ajuste nem da seleção.

Antes do PI-IMC, somar as constantes de tempo do candidato escolhido para obter `τeq`. É uma redução explícita para a sintonia; a simulação mantém a planta publicada. O experimento de comparação das ordens usa a mesma planta e o mesmo tempo IMC, enquanto o painel de cada estratégia usa a seleção automática.

## Organização

Cada pasta de estratégia contém:

- `toolbox.ipynb`: o único notebook do tema, com o experimento interativo;
- `README.md`: teoria, quando aplicar, bibliotecas, artigo brasileiro utilizado e apoio nacional;
- `dados_ensaio/`: CSVs de ajuste, escolha do modelo e validação final, com colunas `tempo`, `entrada`, `saida`;
- `assets/` ou `imagens/`: recortes das figuras originais, com fonte indicada;
- `materiais_aula/`: arquivos fornecidos no acervo da disciplina, preservados para consulta.

Os arquivos de identificação comuns estão em [materiais_comuns](materiais_comuns/). No acervo recebido não havia código específico de faixa dividida; a pasta 04 contém o material de apoio disponível, sem atribuir uma implementação nova ao acervo original.

## Executar fora do Colab

Use Python 3.11 ou posterior com Jupyter Notebook/JupyterLab e os pacotes de [requirements.txt](requirements.txt). A primeira célula de cada notebook instala as dependências necessárias no Colab. O painel usa `ipywidgets` e atualiza quando você solta o controle deslizante.

## Modelos e referências

Os cinco casos usam funções de transferência publicadas por autores brasileiros. As figuras são recortes dos artigos ou de material institucional; cada README identifica o artigo, as equações utilizadas e as adaptações didáticas. Os ensaios de identificação são gerados em simulação, com ruído: não são apresentados como medições experimentais dos artigos.

As simulações representam os modelos e a faixa de operação descritos em cada tema. Os READMEs explicam as simplificações relevantes. Os créditos e os arquivos de terceiros permanecem associados às suas fontes.

Versão 0.9 — identificação por ensaios, parcimônia e comentários impessoais.
