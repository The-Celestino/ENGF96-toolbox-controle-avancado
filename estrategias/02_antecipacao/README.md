# Controle por antecipação

[Abrir no Colab](https://colab.research.google.com/drive/132PqVwWt00uGhxk0T4wMzUwh8kETtNNf) · [Notebook no repositório](toolbox.ipynb)

Quando a alimentação muda, podemos medir essa mudança e agir na válvula **junto com a perturbação**, sem esperar que apareça um erro na saída. Esse é o diferencial da antecipação (*feedforward*). O PI continua presente para corrigir efeitos que o modelo não previu.

[Notebook](toolbox.ipynb) · [Voltar à toolbox](../../README.md)

## O que o exemplo mostra

Uma queda na alimentação de gás tende a diminuir a vazão no compressor. A válvula de reciclo pode aumentar a recirculação e contrariar esse efeito. O notebook compara **só PI** com **PI + antecipação** usando o mesmo PI nas duas alternativas. Os três controles permitem alterar a intensidade da queda, o atraso da informação e a diferença entre o ganho real e o ganho esperado da perturbação.

![Compressor e linha de reciclo](assets/processo.png)

*Recorte original da Figura 2, página 2, da referência de Yang et al.; crédito bibliográfico completo em Referências.*

## Quando faz sentido usar

- Existe uma perturbação relevante que pode ser medida ou estimada a tempo.
- Há uma ação manipulada capaz de compensar o efeito da perturbação.
- Conhecemos os dois caminhos até a saída: ação → saída e perturbação → saída.
- A compensação calculada é realizável e a ação cabe nos limites do atuador.

Uma medida atrasada reduz a vantagem: a antecipação só age depois que a informação chega. Ela não substitui a realimentação quando há perturbações não medidas, erro de modelo ou mudança de operação.

## O modelo publicado e as escalas adotadas

A referência principal é um artigo brasileiro de autores da **Universidade Federal de Santa Catarina**, apresentado no **CBA 2018**. O modelo completo do compressor inclui não linearidades, estimador de vazão e operação perto da região de surge. O notebook utiliza apenas os dois canais lineares locais publicados na seção 4:

$$G_d(s)=\frac{0,3092s+0,08813}{s^2+0,672s+0,1764}\quad\text{(equação 18)}$$
$$G_u(s)=\frac{0,3211s+0,1927}{s^2+0,6s+0,16}\quad\text{(equação 19)}.$$

Os coeficientes foram transcritos exatamente. $G_d$ liga a variação da alimentação à vazão no compressor; $G_u$ liga a variação da válvula de reciclo à mesma vazão. Ambos têm ganho positivo. As entradas e a saída do laboratório representam **desvios normalizados em torno de um ponto de operação**. O tempo usa **u.t. (unidade de tempo do modelo)**. O artigo mostra kg/s, abertura e minutos em diferentes gráficos, mas a conversão dimensional desses canais não é explicitada de modo suficiente para atribuir a cada coeficiente uma calibração física. Por isso, o laboratório não apresenta o eixo como kg/s, porcentagem real de abertura ou segundos.

A sequência de degraus e os ruídos são experimentos **simulados aqui**, não dados de campo reproduzidos do artigo. O ponto de referência no laboratório é zero desvio.

## Identificação e validação

1. Aplicamos um degrau de $+0,2$ à válvula em 2 u.t. e geramos a resposta do canal completo $G_u$.
2. Somamos ruído gaussiano à saída, com desvio padrão $0,004$ na escala normalizada e semente fixa.
3. Ajustamos por mínimos quadrados o modelo reduzido $\widehat G_u=K/(\tau s+1)$, usando somente os dados desse ensaio.
4. Fazemos outro ensaio: entrada $+0,15$ em 3 u.t. e $-0,10$ a partir de 18 u.t. O novo ruído tem outra semente.
5. Prevemos a saída com **os mesmos parâmetros**, sem reajustar com os dados de validação. O gráfico e o RMSE mostram a qualidade da previsão.

Essa primeira ordem é uma aproximação para o PI. O canal original de segunda ordem continua sendo a planta da simulação; a discrepância entre os dois não é removida artificialmente.

## Sintonia IMC e construção da antecipação

Para o canal reduzido, sem atraso de transporte identificado:

$$K_c=\frac{\tau}{K\lambda},\qquad T_i=\tau,\qquad C(s)=K_c\left(1+\frac{1}{T_i s}\right).$$

O laboratório escolhe $\lambda=4$ u.t. e usa o ganho e a constante de tempo **estimados**. A função `sintonizar_imc` mostra o cálculo. Nenhum PI utiliza Ziegler–Nichols, ajuste manual de ganhos ou outra regra.

A antecipação dinâmica usa os canais publicados completos:

$$F(s)=-\frac{G_d(s)}{G_u(s)},\qquad u=u_{PI}+F(s)d_{medido}.$$

O sinal negativo segue o balanço: se a alimentação cai, a válvula deve atuar no sentido contrário. Aqui a razão é própria e estável, portanto pode ser simulada causalmente. Com modelos exatos e informação instantânea, $G_d+G_uF=0$. No painel acrescentamos um pequeno ruído à medição da alimentação; assim, a compensação nominal não aparece como uma linha artificialmente perfeita.

Para simular, o código monta as conexões de malha fechada por funções de transferência. Com $S=1/(1+G_uC)$, a saída é $y=S G_{d,real}d+S G_u F d_{medido}$. Essa escrita evita esconder o controlador num motor longo.

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
| [SciPy](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.least_squares.html) | Ajustar ganho e constante de tempo | `least_squares` |
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
