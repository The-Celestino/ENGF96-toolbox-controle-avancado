# Controle em cascata

[Abrir no Colab](https://colab.research.google.com/drive/1NXIlPniygCnQuvOYHTX7nrvKJKcmN1B3)

## Teoria

O PI externo controla a saída principal `y` e fornece a referência de `x`. O PI interno controla `x` e atua sobre a planta. A cascata permite corrigir perturbações percebidas por `x` antes que elas cheguem a `y`.

Aplicar quando a variável intermediária responder mais rápido e medir uma perturbação relevante. Sintonizar e fechar primeiro a malha interna; projetar a externa considerando essa malha fechada.

![Diagrama de controle em cascata](assets/processo.png)

Diagrama: Bojorge, UFF, slide 11 [2].

## Modelo

Equações 20–21 de [1], p. 6:

```math
G_2(s)=\frac{3e^{-3s}}{13{,}3s+1},\qquad
G_1(s)=\frac{10(1-5s)e^{-5s}}{(30s+1)^3(10s+1)^2}.
```

`G₂` representa a etapa rápida; `G₁`, a lenta. O zero no semiplano direito de `G₁` produz resposta inversa. Tempo em segundos; sinais em desvios normalizados (u.a.). O caso utiliza PI-IMC e atrasos fixos.

## Identificação e IMC

Identificar a etapa rápida pelo canal `rapida`, conforme o [procedimento de identificação](../../README.md#identificação). O ensaio usa degrau de 0,2 u.a. e ruído com desvio-padrão de 0,015 u.a.

Para a aproximação de primeira ordem com atraso:

```math
K_c=\frac{\tau_{eq}}{K(\lambda+\theta)},\qquad
T_i=\tau_{eq},\qquad C(s)=K_c\left(1+\frac{1}{T_i s}\right).
```

O painel varia λ interno de 10 a 60 s; λ externo é 120 s. Maior λ deixa a correção mais lenta.

O modelo externo é obtido por primeiros momentos:

```math
m_2=\frac{T_i}{3K_c},\qquad K_{ext}=10,\quad
\tau_{ext}=112+m_2,\quad \theta_{ext}=8.
```

A malha simples usa `K=30`, `τ=128,3 s` e `θ=8 s`. A planta permanece completa; Padé de ordem 3 aproxima os atrasos para fechar as funções de transferência.

## Experimento

- Comparar `x` e `y` com a perturbação entre as etapas.
- Aumentar λ interno e observar a perda de rapidez.
- Transferir a perturbação para a saída principal e comparar o benefício.

O erro acumulado é a integral do módulo de `y`, em u.a.·s. O caso é linear, sem saturação.

## Bibliotecas

`control`: modelos e malhas; `NumPy`: sinais e ruído; `SciPy`: identificação; `Matplotlib`: gráficos; `ipywidgets`: painéis.

## Materiais de apoio

- [Controle em Cascata — UFF](https://www.professores.uff.br/ninoska/wp-content/uploads/sites/57/2017/11/Aula-25-Controle-Cascata2017_2sem17.pdf).
- [PID I](https://www.youtube.com/watch?v=KW4IGc9pgR0) e [PID II](https://www.youtube.com/watch?v=MZpidTSxtKI) — [LASC/UFSC](https://lasc.ufsc.br/curso-de-sistemas-de-controle/).
- [MATLAB e Simulink](materiais_aula/).

## Referências

1. Franklin, T. S.; Santos, T. L. M.; Araújo, J. M. (2020). *Critério de estabilidade simplificado para sistemas lineares em cascata com atraso variável: uma abordagem via preditor de Smith Filtrado*. CBA. [Artigo](https://ojs.sba.org.br/index.php/cba/article/view/1258). Modelos: eqs. 20–21.
2. Bojorge, N. (2017). *Controle em Cascata*. UFF. [PDF](https://www.professores.uff.br/ninoska/wp-content/uploads/sites/57/2017/11/Aula-25-Controle-Cascata2017_2sem17.pdf). Diagrama: slide 11.
3. [Referências de identificação e IMC](../../README.md#referências).
