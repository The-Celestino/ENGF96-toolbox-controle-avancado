# Toolbox de controle clássico

Notebooks de controle clássico em Python.

| Estratégia | Teoria | Código |
|---|---|---|
| 01 — Cascata | [README](estrategias/01_controle_cascata/README.md) | [Colab](https://colab.research.google.com/drive/1NXIlPniygCnQuvOYHTX7nrvKJKcmN1B3) |
| 02 — Antecipação | [README](estrategias/02_antecipacao/README.md) | [Colab](https://colab.research.google.com/drive/132PqVwWt00uGhxk0T4wMzUwh8kETtNNf) |
| 03 — Razão e limites cruzados | [README](estrategias/03_razao_limites_cruzados/README.md) | [Colab](https://colab.research.google.com/drive/1e6rVoVLpmtAASvUmJ_kE-cIBIlpE6GFa) |
| 04 — Faixa dividida | [README](estrategias/04_split_range/README.md) | [Colab](https://colab.research.google.com/drive/172l9HdNCzOoUF0heMQLK04Rvqr6JDvvt) |
| 05 — Seletivo | [README](estrategias/05_controle_seletivo/README.md) | [Colab](https://colab.research.google.com/drive/1vM2Ly36GAoXYpaAFQt31-j3gfqcSdEv6) |

[Pasta no Drive](https://drive.google.com/drive/folders/1wLEY7YQ50n-6a33st90eDabJtU6B0zS7) · [Materiais de identificação](materiais_comuns/)

## Uso

Abrir o Colab e executar as células em ordem. Para execução local, usar Python 3.11 ou posterior e instalar [requirements.txt](requirements.txt).

Cada estratégia contém um notebook, teoria, referências, imagens, ensaios CSV e materiais de apoio.

## Identificação

Os ensaios simulados incluem ruído. Para cada canal:

1. Ajustar P1D, P2D e P3D por mínimos quadrados no primeiro ensaio.
2. No segundo, escolher o modelo de menor ordem até 1 ponto percentual do melhor FIT.
3. Validar no terceiro, sem reajustar parâmetros.

P1D/P2D/P3D têm 1/2/3 polos reais estáveis, atraso estimado e 3/4/5 parâmetros livres. A tolerância de 1 ponto percentual é um critério de seleção, não um teste estatístico.

```math
FIT=100\left(1-\frac{\lVert y-\hat y\rVert_2}{\lVert y-\bar y\rVert_2}\right),\qquad
RMSE=\sqrt{\frac{1}{N}\sum_{k=1}^{N}(y_k-\hat y_k)^2}.
```

FIT pode ser negativo; RMSE tem a unidade da saída. Para PI-IMC, reduzir o modelo mantendo ganho e atraso e usando a soma das constantes de tempo:

```math
\tau_{eq}=\sum_i\tau_i,\qquad
\hat G_{eq}(s)=\frac{K e^{-\theta s}}{\tau_{eq}s+1}.
```

A redução preserva ganho estático e primeiro momento. A simulação usa a planta completa.

Para dados próprios, usar `usar_ensaio_externo=True` e fornecer `ajuste_<canal>.csv`, `escolha_<canal>.csv` e `validacao_<canal>.csv` em `dados_ensaio/`. Colunas: `tempo,entrada,saida`; amostragem uniforme e desvios do ponto de operação, começando em equilíbrio. Manter as unidades do caso. Os candidatos consideram ganhos positivos e polos reais; a entrada é mantida entre amostras e atrasos fracionários usam interpolação.

## Referências

- Rivera, D. E.; Morari, M.; Skogestad, S. (1986). *Internal Model Control. 4. PID Controller Design*. [DOI](https://doi.org/10.1021/i200032a041).
- [PI-IMC para primeira ordem com atraso — APMonitor/BYU](https://www.apmonitor.com/pdc/index.php/Main/ProportionalIntegralControl).
- MathWorks: [modelos de processo](https://www.mathworks.com/help/ident/ref/idproc.html), [FIT](https://www.mathworks.com/help/ident/ref/compare.html) e [validação](https://www.mathworks.com/help/ident/ug/validating-models-after-estimation.html).
