close all
clc

% Nomenclatura para especificar a estrutura do modelo
%'Pk': means a process with k poles (not including a possible integration)
%'Z': means at a Zero (numerator Tz~=0) is included.
%'D': means that a deadtime Td~=0 is included
%'I': means that an integrating process is chosen.
%'U': means that the model is underdamped: The first two poles are complex.

Ts=tempo_amostragem; % intervalo de amostragem

%% 
ze = iddata(TI_d(1:40000),FI_d(1:40000),Ts); % cria????o do objeto de saida e entrada
zv = iddata(TI_d(40001:end),FI_d(40001:end),Ts); % cria????o do objeto de saida e entrada
% z = iddata(TI,FI,Ts)2
estrutura = idproc('P1'); % setup da estrutura de modelo escolhida

Modelo_estimado = pem(ze,estrutura)  %estimacao dos parametros do modelo

yest = idsim(FI_d(1:end),Modelo_estimado); % simulacao a infinitos passos a frente
% fpe_calc = fpe(Modelo_estimado);
% aic_calc = aic(Modelo_estimado);
figure(1)
compare(zv,Modelo_estimado)
figure(2)
plot(yest(1:end-1),'r.-')
hold on
plot(TI_d(1:end-1),'b-')

