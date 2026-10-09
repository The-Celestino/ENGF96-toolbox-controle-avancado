# Controle seletivo (override)

**Uma bomba, duas prioridades.** A vazão deve seguir uma referência; o reservatório de sucção deve manter nível suficiente. Quando esses objetivos competem, um seletor escolhe qual controlador envia o comando.

[Abrir no Colab](https://colab.research.google.com/drive/1vM2Ly36GAoXYpaAFQt31-j3gfqcSdEv6) · [Notebook no repositório](toolbox.ipynb)

![Módulo de vazão e nível](imagens/processo.png)

Figura 2 do artigo indicado abaixo.

## O que muda nesta estratégia

Dois PI calculam comandos na mesma escala. O seletor **MAX** aplica o maior. Neste processo, aumentar o comando aumenta a vazão de retorno e o nível de sucção: quando o nível cai, seu PI pode assumir e elevar a vazão acima da referência. O sinal de atuação determina MAX ou MIN; não existe uma escolha universal.

Esse arranjo é um caso de controle seletivo entre **saídas de controladores**, chamado override. Selecionar o maior entre sensores é outro uso de seletor, e não é o que este notebook simula. Uma média dos dois comandos não implementa a prioridade imposta pelo MAX.

## Quando aplicar

Use quando uma variável manipulada atende um objetivo habitual, mas outra variável precisa receber prioridade perto de uma restrição. Confirme o sentido da ação, a compatibilidade das escalas e a capacidade do atuador. O controlador que não atua precisa acompanhar o comando aplicado para não acumular integral; o notebook inclui esse rastreamento.

## O artigo e os modelos

**Referência:** SILVA, Gabriel Rodrigues dos Santos; JESUS, Luis Filipe Freitas da Silva de. *Avaliação de estratégia de controle override em um módulo didático de vazão e nível*. CONTECC, Palmas, 2019. Autores do IFBA, Salvador. [PDF original, hospedado pelo Confea](https://www.confea.org.br/midias/uploads-imce/Contecc2019/Experi%C3%AAncia%20Profissional/AVALIA%C3%87%C3%83O%20DE%20ESTRATEGIA%20DE%20CONTROLE%20OVERRIDE%20EM%20UM%20MODULO%20DIDATICO%20DE%20VAZ%C3%83O%20E%20NIVEL.pdf).

O trabalho apresenta uma bancada de dois reservatórios e uma bomba, identificação experimental, sintonia IMC e seleção de alta. Extração da **Tabela 2, página 4**:

| Canal | Função de transferência | Unidade de saída | Tempo |
|---|---|---|---|
| PWM → nível | `0.1693 / (54.813 s + 1)` | cm | s |
| PWM → vazão de retorno | `0.0252 exp(-4.024 s) / (49.756 s + 1)` | L/min | s |

A unidade absoluta e o ponto de operação do PWM não estão especificados. O código usa **variações de comando**, não porcentagem de abertura. A **Tabela 1, página 3**, fornece a sintonia IMC: `Kc=(2τ+θ)/(2Kλ)`, `Ti=τ+θ/2`, com `λ=τ`. A tabela de resultados informa `Ti` em minutos; a implementação usa segundos.

## Identificação e validação

Gerar ensaios separados para os canais PWM → nível e PWM → vazão de retorno, adicionando ruído gaussiano às saídas. Manter os modelos publicados como planta e tratar os CSVs como dados de ensaio para a identificação. Os atrasos dos candidatos são livres no ajuste, inclusive no canal de nível; não os fixar previamente nos valores do artigo.

Salvar três ensaios separados como CSV em `dados_ensaio/`, com colunas `tempo`, `entrada` e `saida`. Entrada e saída são desvios em relação ao ponto de operação; manter as unidades do canal e do tempo. Os arquivos são `ajuste_<canal>.csv`, `escolha_<canal>.csv` e `validacao_<canal>.csv`; nesta estratégia, os canais são `nivel`, `vazao`.

| Modelo candidato | Estrutura | Parâmetros livres |
|---|---|---:|
| P1D | Um polo real e atraso | 3: ganho, uma constante de tempo e atraso |
| P2D | Dois polos reais e atraso | 4: ganho, duas constantes de tempo e atraso |
| P3D | Três polos reais e atraso | 5: ganho, três constantes de tempo e atraso |

```math
\widehat G_n(s)=\frac{K e^{-\theta s}}{\prod_{i=1}^{n}(\tau_i s+1)},\qquad n=1,2,3.
```

1. **Ajustar:** estimar cada candidato por mínimos quadrados no primeiro ensaio. As constantes de tempo são positivas, garantindo polos reais estáveis; o atraso é estimado e fica não negativo. Os parâmetros publicados geram a planta, mas não são impostos ao ajuste.
2. **Escolher com parcimônia:** prever o segundo ensaio sem reajustar. Selecionar o modelo de menor ordem cujo FIT fique até **1 ponto percentual abaixo do melhor FIT**. Mais parâmetros só se justificam quando a melhora de previsão superar essa tolerância.
3. **Validar:** usar o terceiro ensaio apenas para avaliar o modelo escolhido, com entrada e ruído diferentes. Não reajustar parâmetros nem selecionar novamente com esses dados.

```math
FIT=100\left(1-\frac{\|y-\widehat y\|_2}{\|y-\overline y\|_2}\right),\qquad
RMSE=\sqrt{\frac{1}{N}\sum_{k=1}^{N}(y_k-\widehat y_k)^2}.
```

O FIT compara o erro com a variação medida: pode ser negativo e não significa probabilidade de acerto. O RMSE conserva a unidade da saída. Ambos dependem do ensaio e do ruído; uma curva próxima dos pontos de ajuste, sozinha, não comprova qualidade de previsão.

**Antes do PI-IMC, explicitar a redução:** manter o ganho e o atraso do candidato escolhido e usar `τeq = soma(τi)`.

```math
\tau_{eq}=\sum_{i=1}^{n}\tau_i,\qquad
\widehat G_{eq}(s)=\frac{K e^{-\theta s}}{\tau_{eq}s+1}.
```

Essa aproximação preserva o ganho estático e o primeiro momento, mas não toda a dinâmica de P2D/P3D. A planta publicada permanece na simulação. O experimento de comparação usa a mesma planta e o mesmo tempo IMC para os PIs derivados dos três candidatos; o painel principal usa a seleção automática por parcimônia.


## Sintonia IMC

Preservar a variante PI-IMC da Tabela 1 do artigo. Após reduzir o modelo selecionado por `τeq = soma(τi)`, calcular:

```math
K_c=\frac{2\tau_{eq}+\theta}{2K\lambda},\qquad
T_i=\tau_{eq}+\frac{\theta}{2},\qquad \lambda=\tau_{eq}.
```

O ganho, o atraso e as constantes de tempo vêm da identificação. O termo adicional `θ/2` distingue esta correlação da regra usada nos demais temas; manter essa diferença explícita. Para comparar P1D/P2D/P3D, manter a mesma planta e um `λ` comum no experimento de sintonia. O painel seletivo principal usa os modelos escolhidos por parcimônia e o padrão `λ=τeq` de cada canal.

## O que foi adaptado

- Planta: as duas funções de transferência publicadas, com o atraso explícito.
- Dados de identificação: três ensaios CSV **gerados em simulação**, com entradas diferentes, ruído gaussiano e sementes fixas. Ajustar ganho, constantes de tempo e atraso dos candidatos P1D/P2D/P3D; escolher com parcimônia e validar em um terceiro ensaio. Não são dados experimentais do artigo.
- Sintonia: reduzir explicitamente o candidato escolhido antes do PI-IMC; nenhum ajuste usa o ensaio final de validação.
- Operação: nível inicial 8,6 cm, vazão inicial 2,45 L/min, horizonte 1000 s e comando limitado a ±40 unidades de variação são escolhas didáticas. Não reproduzem a aquisição do artigo.
- Fotografia: recorte da Figura 2, página 3. A referência acima identifica a origem; a figura conserva os direitos e a autoria de sua fonte.

## Como usar

1. Abra o notebook no Colab e execute as células em ordem.
2. Veja os parâmetros ajustados e o gráfico de validação antes da sintonia.
3. Compare “Só vazão” com “Seletor MAX” no painel.
4. Comece com vazão final 2,5 L/min; depois 1,8 L/min. O trecho laranja mostra quando o nível assume.
5. Mude o nível mínimo e o ruído. Observe qual objetivo deixa de ser atendido.

As curvas mostram a resposta do modelo; o ruído afeta as medições dos controladores. Os controles atualizam ao soltar o cursor.

## As bibliotecas

| Pacote | Papel |
|---|---|
| NumPy | Sinais, ruído e atualização exata de cada modelo de primeira ordem com entrada constante por passo |
| SciPy | Ajuste de P1D/P2D/P3D por mínimos quadrados, com polos reais estáveis |
| Matplotlib | Gráficos de validação e comparação das estratégias |
| ipywidgets | Parâmetros interativos no Colab |

## Materiais de apoio

- [Controle Seletivo, Split-Range, Gain-Scheduled e Inferencial — UnB](https://www.ene.unb.br/estognetti/files/labcprocess/Apoio7_LCP_estrategias.pdf). Notas de Eduardo Stockler, 2015; páginas 2–8 mostram aplicações de seleção. Complemento conceitual, não fonte dos parâmetros deste caso.
- [Controlador PID — Parte I, canal LASC/UFSC](https://www.youtube.com/watch?v=KW4IGc9pgR0).
- [Controlador PID — Parte II, canal LASC/UFSC](https://www.youtube.com/watch?v=MZpidTSxtKI).
- [Página oficial do curso do LASC/UFSC](https://lasc.ufsc.br/curso-de-sistemas-de-controle/), que lista essas videoaulas. Os vídeos revisam PID; não são apresentados como aulas específicas de override.
- Os arquivos originais da disciplina ficam em [materiais_aula/](materiais_aula/), separados da implementação Python.

## Limites da simulação

Os modelos são lineares e locais. Não há cálculo de NPSH, cavitação, volume total ou curva hidráulica da bomba. O seletor prioriza o nível na simulação; não constitui um sistema independente de segurança. Ruído e transientes podem produzir pequenas violações do nível pretendido. Uma restrição inviável não se torna viável apenas por usar MAX.

Referências da identificação: [estruturas de modelos de processo — MathWorks](https://www.mathworks.com/help/ident/ref/idproc.html), [definição de FIT](https://www.mathworks.com/help/ident/ref/compare.html) e [validação de modelos](https://www.mathworks.com/help/ident/ug/validating-models-after-estimation.html). O código Python realiza o ajuste por mínimos quadrados; não utiliza MATLAB.

Para usar ensaios próprios, definir `usar_ensaio_externo=True`. Fornecer os três CSVs por canal em desvios do ponto de operação, começando em equilíbrio com entrada zero, na unidade de tempo e nas escalas desta planta. A família implementada é restrita a ganhos positivos e polos reais estáveis. O ajuste assume entrada mantida entre amostras; atrasos fracionários usam interpolação. Dados com outras dinâmicas exigem outras estruturas e revisão da sintonia.
