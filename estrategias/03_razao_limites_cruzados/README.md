# Razão e limites cruzados

[Abrir no Colab](https://colab.research.google.com/drive/1e6rVoVLpmtAASvUmJ_kE-cIBIlpE6GFa) · [Notebook no repositório](toolbox.ipynb)

**O ponto principal:** combinar pedidos não garante que as duas vazões cheguem juntas. A razão define quanto uma deve acompanhar a outra; os limites cruzados usam o que foi medido para coordenar a ordem dos movimentos.

## Usar a toolbox

Abra [toolbox.ipynb](toolbox.ipynb) no Colab e execute de cima para baixo. São três momentos: explorar o `min`/`max` com números pequenos, identificar e validar os modelos, e comparar as duas estratégias no painel.

| Controle do painel | O que muda | O que observar |
|---|---|---|
| Demanda | Tamanho do pedido de combustível entre 40 e 140 s | A diferença entre pedir junto e esperar a outra vazão |
| Razão-alvo | Proporção entre os fluxos normalizados | Mais ar pedido para o mesmo combustível |
| Ruído σ | Desvio-padrão do ruído nas duas medições | Seletores reagindo a leituras imperfeitas |

O painel recalcula quando você solta o controle deslizante. A curva da razão mostra o diferencial diretamente; a segunda mostra a sequência dos fluxos com limites cruzados.

## O processo e o recorte do artigo

![O forno e suas zonas](assets/processo.png)

O caso de origem é um forno de reaquecimento industrial. Aqui o recorte são duas malhas da mesma zona: gás GFIC441 e ar AFIC441. Usam-se os modelos médios de **subida de 2004**, publicados na Tabela 2, pp. 73–74, de [1].

| Malha | K ((mil Nm³/h)/ponto percentual) | τ (s) | θ (s) | Faixa de abertura ensaiada |
|---|---:|---:|---:|---|
| Gás | 0,25 | 4,78 | 1 | 10–50% |
| Ar | 0,51 | 7,16 | 2 | 10–60% |

Para cada canal:

```math
\Delta Q(s)=\frac{K e^{-\theta s}}{\tau s+1}\Delta m(s).
```

`m` é a abertura da válvula em pontos percentuais; `Q` é vazão em mil Nm³/h. Os modelos são locais e descrevem **variações**, sem fornecer os interceptos das curvas de vazão absoluta. O notebook não calcula temperatura, química de combustão, eficiência ou emissões do forno.

Na identificação, aplicar um degrau de 5 pontos percentuais ao redor de um ponto de operação e reservar duas outras sequências para escolha e validação final. Os dados são gerados pelos modelos publicados com ruído gaussiano adicionado; não são os registros industriais do artigo.

No painel, ambos os canais são normalizados pelo respectivo ganho estático, deixando ganho nominal igual a 1. A escala de comando é comum. Assim, compara-se a proporção **entre fluxos normalizados de demonstração**, sem inferir uma razão estequiométrica a partir dos ganhos das válvulas. A demanda, a razão de 1,10, os instantes de mudança e o ruído são escolhas de ensaio da toolbox.

## A regra, sem esconder o essencial

Para demanda `D` expressa na escala do combustível e razão desejada `R`:

```math
r_g=\min(D,Q_a/R),\qquad r_a=\max(RD,RQ_g).
```

Na subida, o pedido de combustível depende do ar já medido. Na descida, o pedido de ar considera o combustível ainda presente. O teste de comparação usa `r_g=D` e `r_a=RD`, com as mesmas plantas, sintonias e realizações de ruído.

O artigo de origem descreve uma arquitetura industrial de **duplo limite cruzado**. Este notebook implementa o **limite cruzado simples** para isolar a lógica de prioridade. Não se reproduzem todos os blocos e margens do sistema original. Sem cruzamento, a diferença de dinâmica já produz uma razão transitória diferente da razão solicitada.

## Identificação e validação

Excitar separadamente as malhas de gás e ar com um degrau de 5 pontos percentuais e adicionar ruído gaussiano à medição. Os dados são gerados pelos modelos publicados; não são os registros industriais do artigo. A comparação entre candidatos ocorre separadamente para cada canal.

Salvar três ensaios separados como CSV em `dados_ensaio/`, com colunas `tempo`, `entrada` e `saida`. Entrada e saída são desvios em relação ao ponto de operação; manter as unidades do canal e do tempo. Os arquivos são `ajuste_<canal>.csv`, `escolha_<canal>.csv` e `validacao_<canal>.csv`; nesta estratégia, os canais são `gas`, `ar`.

| Modelo candidato | Estrutura | Parâmetros livres |
|---|---|---:|
| P1D | Um polo real e atraso | 3: ganho, uma constante de tempo e atraso |
| P2D | Dois polos reais e atraso | 4: ganho, duas constantes de tempo e atraso |
| P3D | Três polos reais e atraso | 5: ganho, três constantes de tempo e atraso |

```math
\hat{G}_n(s)=\frac{K e^{-\theta s}}{\prod_{i=1}^{n}(\tau_i s+1)},\qquad n=1,2,3.
```

1. **Ajustar:** estimar cada candidato por mínimos quadrados no primeiro ensaio. As constantes de tempo são positivas, garantindo polos reais estáveis; o atraso é estimado e fica não negativo. Os parâmetros publicados geram a planta, mas não são impostos ao ajuste.
2. **Escolher com parcimônia:** prever o segundo ensaio sem reajustar. Selecionar o modelo de menor ordem cujo FIT fique até **1 ponto percentual abaixo do melhor FIT**. Mais parâmetros só se justificam quando a melhora de previsão superar essa tolerância.
3. **Validar:** usar o terceiro ensaio apenas para avaliar o modelo escolhido, com entrada e ruído diferentes. Não reajustar parâmetros nem selecionar novamente com esses dados.

```math
FIT=100\left(1-\frac{\|y-\hat{y}\|_2}{\|y-\overline y\|_2}\right),\qquad
RMSE=\sqrt{\frac{1}{N}\sum_{k=1}^{N}(y_k-\hat{y}_k)^2}.
```

O FIT compara o erro com a variação medida: pode ser negativo e não significa probabilidade de acerto. O RMSE conserva a unidade da saída. Ambos dependem do ensaio e do ruído; uma curva próxima dos pontos de ajuste, sozinha, não comprova qualidade de previsão.

**Antes do PI-IMC, explicitar a redução:** manter o ganho e o atraso do candidato escolhido e usar `τeq = soma(τi)`.

```math
\tau_{eq}=\sum_{i=1}^{n}\tau_i,\qquad
\hat{G}_{eq}(s)=\frac{K e^{-\theta s}}{\tau_{eq}s+1}.
```

Essa aproximação preserva o ganho estático e o primeiro momento, mas não toda a dinâmica de P2D/P3D. A planta publicada permanece na simulação. O experimento de comparação usa a mesma planta e o mesmo tempo IMC para os PIs derivados dos três candidatos; o painel principal usa a seleção automática por parcimônia.

## Sintonia IMC

Reduzir cada candidato selecionado por `τeq = soma(τi)` e sintonizar os dois PIs por IMC:

```math
K_c=\frac{\tau_{eq}}{K(\lambda+\theta)},\qquad T_i=\tau_{eq}.
```

O ganho, o atraso e `τeq` vêm do modelo selecionado de cada canal. Para passar à escala normalizada, dividir o ganho estimado pelo ganho publicado usado na normalização. Adotar `λ=8 s` nas duas malhas. Na comparação das ordens, manter a mesma planta e o mesmo `λ`; no painel de razão, manter os mesmos PIs nas alternativas de pedidos juntos e limites cruzados.

O motor aplica o PI em passos de 0,05 s, limita o comando ao intervalo 0–1 e interrompe a acumulação integral quando ela empurra o comando para fora da faixa. Cada planta publicada de primeira ordem com atraso é atualizada pela solução exata da parte de primeira ordem com entrada constante no intervalo; os atrasos nominais usam uma fila de amostras. A ordem escolhida para a identificação não substitui esses modelos publicados.

## Quando aplicar e quais limites considerar

Razão é útil quando importa a proporção entre correntes, como mistura ou alimentação coordenada. Limites cruzados acrescentam prioridade quando um desequilíbrio numa direção é mais indesejável que na outra. Unidades, calibrações e escalas precisam ser compatíveis antes de comparar ou multiplicar sinais.

O seletor limita **referências**, não a vazão real instantaneamente. Atrasos, resposta do PI, saturação, ruído e falhas de medição podem causar violações. A lógica aqui é didática e não representa uma função instrumentada de segurança. A condição inicial, as margens operacionais e o procedimento de partida de uma instalação exigem projeto próprio.

## Bibliotecas

| Biblioteca | Uso no notebook |
|---|---|
| NumPy | Vetores, ruído e atualização dos modelos |
| SciPy (`least_squares`) | Ajuste dos três candidatos por mínimos quadrados |
| Matplotlib | Curvas de validação e comparação |
| ipywidgets | Controles deslizantes e atualização do painel |
| IPython | Exibição dos controles |

Essas bibliotecas estão disponíveis no ambiente padrão do Colab. Não é necessário MATLAB nem conexão com uma planta.

## Materiais de apoio

- [Curso de Sistemas de Controle — LASC/UFSC](https://lasc.ufsc.br/curso-de-sistemas-de-controle/): página institucional das notas e videoaulas.
- [Controladores PID I — LASC/UFSC](https://www.youtube.com/watch?v=KW4IGc9pgR0) e [PID II](https://www.youtube.com/watch?v=MZpidTSxtKI): revisão das ações proporcional e integral; não são aulas específicas de limites cruzados.
- [Controle de um sistema de mistura — UnB](https://www.ene.unb.br/estognetti/files/controle_razao_tca_2012_2.pdf): diagramas de razão e efeito de escalas/ruído.
- [Materiais de aula](materiais_aula/): arquivos fornecidos na disciplina, mantidos como material de consulta. Não são dependências deste notebook; sua autoria e origem ficam nas referências dessa pasta.

## Referências

1. **Teixeira, B. O. S.; Jota, F. G.; Teixeira, M. H.** Modelagem, controle e otimização do processo dos fornos de reaquecimento de placas. *SBA: Controle & Automação*, 18(1), 67–93, 2007. Autores vinculados à UFMG e à Usiminas. [Artigo e DOI](https://doi.org/10.1590/S0103-17592007000100006). Modelos: Tabela 2, pp. 73–74. Imagem: recorte original da Figura 2, p. 71. Arquitetura industrial: seção 2 e Figura 3. O artigo utiliza síntese direta nas malhas de vazão; a toolbox aplica IMC às estimativas dos ensaios simulados.
2. **Rivera, D. E.; Morari, M.; Skogestad, S.** Internal model control. 4. PID controller design. *Industrial & Engineering Chemistry Process Design and Development*, 25(1), 252–265, 1986. [DOI](https://doi.org/10.1021/i200032a041).
3. **Stockler, E. — UnB.** Controle de um sistema de mistura. Material didático institucional, 2012. [PDF](https://www.ene.unb.br/estognetti/files/controle_razao_tca_2012_2.pdf).
4. **LASC — UFSC.** Curso de Sistemas de Controle; videoaulas Controladores PID I e II. [Página institucional](https://lasc.ufsc.br/curso-de-sistemas-de-controle/).

Os modelos e o caso vêm de [1]; as escolhas de ensaio e a implementação didática são desta toolbox.


Referência da correlação PI utilizada: [APMonitor/BYU — Proportional Integral Control, seção IMC FOPDT Tuning Correlations](https://www.apmonitor.com/pdc/index.php/Main/ProportionalIntegralControl). O artigo brasileiro acima fornece a planta; esta fonte explicita a regra IMC de primeira ordem com atraso.

Referências da identificação: [estruturas de modelos de processo — MathWorks](https://www.mathworks.com/help/ident/ref/idproc.html), [definição de FIT](https://www.mathworks.com/help/ident/ref/compare.html) e [validação de modelos](https://www.mathworks.com/help/ident/ug/validating-models-after-estimation.html). O código Python realiza o ajuste por mínimos quadrados; não utiliza MATLAB.

Para usar ensaios próprios, definir `usar_ensaio_externo=True`. Fornecer os três CSVs por canal em desvios do ponto de operação, começando em equilíbrio com entrada zero, na unidade de tempo e nas escalas desta planta. A família implementada é restrita a ganhos positivos e polos reais estáveis. O ajuste assume entrada mantida entre amostras; atrasos fracionários usam interpolação. Dados com outras dinâmicas exigem outras estruturas e revisão da sintonia.
