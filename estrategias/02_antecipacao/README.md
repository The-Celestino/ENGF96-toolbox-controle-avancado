# Controle por antecipação

[Abrir no Colab](https://colab.research.google.com/drive/132PqVwWt00uGhxk0T4wMzUwh8kETtNNf) · [Notebook no repositório](toolbox.ipynb)

Quando a alimentação muda, é possível medir essa mudança e agir na válvula **junto com a perturbação**, sem esperar que apareça um erro na saída. Esse é o diferencial da antecipação (*feedforward*). O PI continua presente para corrigir efeitos que o modelo não previu.

[Notebook](toolbox.ipynb) · [Voltar à toolbox](../../README.md)

## O que o exemplo mostra

Uma queda na alimentação de gás tende a diminuir a vazão no compressor. A válvula de reciclo pode aumentar a recirculação e contrariar esse efeito. O notebook compara **só PI** com **PI + antecipação** usando o mesmo PI nas duas alternativas. Os três controles permitem alterar a intensidade da queda, o atraso da informação e a diferença entre o ganho real e o ganho esperado da perturbação.

![Compressor e linha de reciclo](assets/processo.png)

*Recorte original da Figura 2, página 2, da referência de Yang et al.; crédito bibliográfico completo em Referências.*

## Quando faz sentido usar

- Existe uma perturbação relevante que pode ser medida ou estimada a tempo.
- Há uma ação manipulada capaz de compensar o efeito da perturbação.
- São conhecidos os dois caminhos até a saída: ação → saída e perturbação → saída.
- A compensação calculada é realizável e a ação cabe nos limites do atuador.

Uma medida atrasada reduz a vantagem: a antecipação só age depois que a informação chega. Ela não substitui a realimentação quando há perturbações não medidas, erro de modelo ou mudança de operação.

## O modelo publicado e as escalas adotadas

A referência principal é um artigo brasileiro de autores da **Universidade Federal de Santa Catarina**, apresentado no **CBA 2018**. O modelo completo do compressor inclui não linearidades, estimador de vazão e operação perto da região de surge. O notebook utiliza apenas os dois canais lineares locais publicados na seção 4:

```math
G_d(s)=\frac{0,3092s+0,08813}{s^2+0,672s+0,1764}\quad\text{(equação 18)}
```

```math
G_u(s)=\frac{0,3211s+0,1927}{s^2+0,6s+0,16}\quad\text{(equação 19)}.
```

Os coeficientes foram transcritos exatamente. $G_d$ liga a variação da alimentação à vazão no compressor; $G_u$ liga a variação da válvula de reciclo à mesma vazão. Ambos têm ganho positivo. As entradas e a saída do laboratório representam **desvios normalizados em torno de um ponto de operação**. O tempo usa **u.t. (unidade de tempo do modelo)**. O artigo mostra kg/s, abertura e minutos em diferentes gráficos, mas a conversão dimensional desses canais não é explicitada de modo suficiente para atribuir a cada coeficiente uma calibração física. Por isso, o laboratório não apresenta o eixo como kg/s, porcentagem real de abertura ou segundos.

A sequência de degraus e os ruídos são experimentos **simulados aqui**, não dados de campo reproduzidos do artigo. O ponto de referência no laboratório é zero desvio.

## Identificação e validação

Aplicar um pequeno degrau à válvula, manter a alimentação constante e adicionar ruído gaussiano à saída, com desvio-padrão 0,004 na escala normalizada. A resposta é gerada pelo canal completo publicado `Gu`; os dados não são registros de campo. O objetivo do ajuste é obter um modelo simples para o PI, sem modificar a planta nem o compensador por antecipação.

Salvar três ensaios separados como CSV em `dados_ensaio/`, com colunas `tempo`, `entrada` e `saida`. Entrada e saída são desvios em relação ao ponto de operação; manter as unidades do canal e do tempo. Os arquivos são `ajuste_<canal>.csv`, `escolha_<canal>.csv` e `validacao_<canal>.csv`; nesta estratégia, os canais são `acao`.

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

## Sintonia IMC e construção da antecipação

Para o modelo reduzido do candidato escolhido, calcular:

```math
K_c=\frac{\tau_{eq}}{K(\lambda+\theta)},\qquad T_i=\tau_{eq},\qquad
C(s)=K_c\left(1+\frac{1}{T_i s}\right).
```

O padrão é `λ=4 u.t.`. O ganho, o atraso e as constantes de tempo vêm do ajuste; `τeq` é a soma dessas constantes. O atraso estimado de uma aproximação não comprova a existência de um atraso físico no compressor. Comparar os três modelos com o mesmo `λ` e a mesma planta ajuda a distinguir a escolha da estrutura do modelo da escolha de rapidez do PI.

A antecipação dinâmica continua usando **os canais publicados completos**, sem substituir `Gu` e `Gd` pelas aproximações P1D/P2D/P3D:

```math
F(s)=-\frac{G_d(s)}{G_u(s)},\qquad u=u_{PI}+F(s)d_{medido}.
```

O sinal negativo segue o balanço: se a alimentação cai, a válvula deve atuar no sentido contrário. A razão é própria e estável, portanto pode ser simulada causalmente. Com modelos exatos e informação instantânea, `Gd + Gu F = 0`. O painel acrescenta um pequeno ruído à medição da alimentação.

As conexões da malha fechada usam funções de transferência:

```math
S=\frac{1}{1+G_uC},\qquad y=S G_{d,real}d+S G_u F d_{medido}.
```

As alternativas “só PI” e “PI + antecipação” mantêm o mesmo PI. Assim, o diferencial observado no painel vem da informação de perturbação, além da correção por erro.

## Como usar

1. Abra `toolbox.ipynb` no Colab e execute todas as células em ordem.
2. Veja o ajuste ruidoso e depois a previsão no ensaio independente.
3. No painel, use inicialmente queda = 0,2, atraso = 0 e efeito real = 1.
4. Compare quem atua primeiro e o maior desvio de vazão.
5. Aumente somente o atraso: a linha verde marca quando a informação ficou disponível.
6. Volte o atraso para zero e altere o efeito real: 1,3 significa que a alimentação tem efeito 30% maior que o previsto.

Os gráficos atualizam quando o controle é solto. O ruído usa uma semente fixa para comparar as alternativas sob a mesma realização. A curva inferior mostra a **alteração do comando**, não uma abertura absoluta de válvula.

## As bibliotecas

| Biblioteca | Papel no notebook | Funções usadas |
|---|---|---|
| [Python Control](https://python-control.readthedocs.io/en/0.10.2/) | Criar modelos e montar malha fechada | `tf`, `feedback`, `minreal`, `forced_response`, `dcgain` |
| [SciPy](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.least_squares.html) | Ajustar P1D/P2D/P3D e comparar a previsão em ensaios separados | `least_squares` |
| [NumPy](https://numpy.org/doc/stable/) | Criar sinais e ruído reproduzível | `arange`, `interp`, `default_rng` |
| [Matplotlib](https://matplotlib.org/stable/) | Comparar medições e respostas | `subplots`, `plot` |
| [ipywidgets](https://ipywidgets.readthedocs.io/en/stable/) | Alterar os três parâmetros | `FloatSlider`, `interactive_output` |

## Limites do laboratório

- É uma análise linear local. Não calcula a linha de surge, a dinâmica não linear completa, o estimador de vazão ou a proteção do compressor.
- Os modelos publicados não são dados experimentais novos da toolbox. A identificação é didática, feita em respostas simuladas com ruído conhecido.
- Não há saturação ou limite de velocidade da válvula. As ações são desvios normalizados; implementar no equipamento exige checar escalas e limites reais.
- A antecipação utiliza os modelos completos publicados; o modelo reduzido identificado alimenta somente a sintonia IMC. No painel, a diferença de modelo altera o ganho do canal de perturbação, não todos os parâmetros do compressor.
- O ruído do ensaio de identificação é ruído de saída; o ruído da simulação final é ruído da informação de alimentação. Nenhum deles representa distúrbio físico aditivo oculto na planta.

## Materiais de apoio

- [Curso de sistemas de controle — LASC/UFSC](https://lasc.ufsc.br/curso-de-sistemas-de-controle/): revisão em português da realimentação; vídeos [Controlador PID I](https://www.youtube.com/watch?v=KW4IGc9pgR0) e [Controlador PID II](https://www.youtube.com/watch?v=MZpidTSxtKI). Use para revisar o PI antes do laboratório; não são aulas específicas de antecipação.
- [Introdução ao controle antecipatório — Ninoska Bojorge, UFF](https://www.professores.uff.br/ninoska/wp-content/uploads/sites/57/2017/08/Aula_24_Controle_FForward_1sem2015.pdf): aula em português com diagramas e projeto de compensação.
- [Controle de processos — Ricardo Kerschbaumer, IFC](https://professor.luzerna.ifc.edu.br/ricardo-kerschbaumer/wp-content/uploads/sites/43/2020/12/Aula-8-Controle-de-processos.pdf): revisão de realimentação e pré-alimentação.

## Referências

1. **Yang, B. B. P.; Mendes, P. R.; Normey-Rico, J. E.; Branco, A. F.; Vettorazzo, C.** Controle regulatório PI+FeedForward antisurge aplicado a compressores para plataformas de produção de petróleo e gás. **CBA 2018**. [Página e PDF do artigo](https://ojs.sba.org.br/index.php/cba/article/view/812) · [DOI](https://doi.org/10.20906/CBA2022/812). A página foi disponibilizada em 2020 e o DOI contém “2022”, mas o fascículo identifica o trabalho como CBA 2018. Modelo: eqs. 18–20; imagem: Fig. 2, p. 2. A grafia do sobrenome final segue o cadastro de autores da SBA.
2. **Rivera, D. E.; Morari, M.; Skogestad, S.** Internal Model Control. 4. PID Controller Design. *Industrial & Engineering Chemistry Process Design and Development*, 25(1), 252–265, 1986. [DOI](https://doi.org/10.1021/i200032a041). Referência do projeto PI por IMC.

As imagens da referência e os materiais de apoio preservam a autoria original. O código didático desta pasta foi escrito para explorar a estratégia.


Referência da correlação PI utilizada: [APMonitor/BYU — Proportional Integral Control, seção IMC FOPDT Tuning Correlations](https://www.apmonitor.com/pdc/index.php/Main/ProportionalIntegralControl). O artigo brasileiro acima fornece a planta; esta fonte explicita a regra IMC de primeira ordem com atraso.

Referências da identificação: [estruturas de modelos de processo — MathWorks](https://www.mathworks.com/help/ident/ref/idproc.html), [definição de FIT](https://www.mathworks.com/help/ident/ref/compare.html) e [validação de modelos](https://www.mathworks.com/help/ident/ug/validating-models-after-estimation.html). O código Python realiza o ajuste por mínimos quadrados; não utiliza MATLAB.

Para usar ensaios próprios, definir `usar_ensaio_externo=True`. Fornecer os três CSVs por canal em desvios do ponto de operação, começando em equilíbrio com entrada zero, na unidade de tempo e nas escalas desta planta. A família implementada é restrita a ganhos positivos e polos reais estáveis. O ajuste assume entrada mantida entre amostras; atrasos fracionários usam interpolação. Dados com outras dinâmicas exigem outras estruturas e revisão da sintonia.
