close all
clc

% Nomenclatura para especificar a estrutura do modelo
%'Pk': means a process with k poles (not including a possible integration)
%'Z': means that a Zero (numerator Tz~=0) is included.
%'D': means that a deadtime Td~=0 is included
%'I': means that an integrating process is chosen.
%'U': means that the model is underdamped: The first two poles are complex.
Ts=.1; % intervalo de amostragem
n=length(L_med); % num de amostras
ne=fix(0.8*n)  ; % num de amostras para estimacao
% nv=n-ne; % num de amostras para validacao

ze = iddata(L_med(1:ne),Fi_med(1:ne),Ts); % criação do objeto de saida e entrada
zv = iddata(L_med(ne+1:end),Fi_med(ne+1:end),Ts); % criação do objeto de saida e entrada

% T_med  -- dados experimentais da temperatura medido em desvio [=] C
% Fv_med -- dados experimentais da vazao de vapor medido em desvio [=] m3/min %
% Ts    -- intervalo de amostragem [=] min

estrutura = idproc('P1'); % setup da estrutura de modelo escolhida
Modelo_estimado = pem(ze,estrutura);  % estimacao dos parametros do modelo
yest=idsim(Fi_med(1:ne),Modelo_estimado); % simulacao a infinitos passos a frente

figure(1)
% plot(L_med(1:end-1),'b-')
plot(L_med(1:ne),'b-')
hold on
plot(yest(1:end-1),'r.-')
legend('Exp','Pred')

% Validacao cruzada
figure(2)
compare(zv,Modelo_estimado)
