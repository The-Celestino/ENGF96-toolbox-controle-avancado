close all
clc

%% =========================================================
%                  DADOS DA SIMULAÇÃO
% ==========================================================

t = F_alim.Time(:);
F = F_alim.Data(:);
T = T_base.Data(:);

% Tempo de amostragem
Ts = median(diff(t));

fprintf('\nTempo de amostragem Ts = %.8f\n',Ts);


%% =========================================================
%             PONTO DE OPERAÇÃO PRÉ-DEGRAU
% ==========================================================

% Degrau aplicado em t = 150
base = t >= 120 & t < 150;

F0 = mean(F(base));
T0 = mean(T(base));

fprintf('\nPonto de operação:\n');
fprintf('F0 = %.6f\n',F0);
fprintf('T0 = %.6f\n',T0);


%% =========================================================
%                 VARIÁVEIS EM DESVIO
% ==========================================================

FI_d = F - F0;
TI_d = T - T0;


%% =========================================================
%           DADOS DE ESTIMAÇÃO E COMPARAÇÃO
% ==========================================================

% Por enquanto estamos usando o mesmo ensaio
% tanto em ze quanto em zv

ze = iddata(TI_d,FI_d,Ts);
zv = iddata(TI_d,FI_d,Ts);


%% =========================================================
%              ESTRUTURAS A SEREM TESTADAS
% ==========================================================

estruturas = {
    'P1'
    'P1D'
    'P1Z'
    'P1ZD'
    'P2'
    'P2U'
    'P3'
    'P0I'
    'P0ID'
};

modelos = cell(size(estruturas));
fits = NaN(size(estruturas));


%% =========================================================
%                ESTIMAÇÃO DOS MODELOS
% ==========================================================

fprintf('\n=============================================\n');
fprintf('           ESTIMAÇÃO DOS MODELOS\n');
fprintf('=============================================\n');

for i = 1:length(estruturas)

    fprintf('\n---------------------------------------------\n');
    fprintf('MODELO: %s\n',estruturas{i});
    fprintf('---------------------------------------------\n');

    try

        estrutura = idproc(estruturas{i});

        % Estimação
        modelos{i} = pem(ze,estrutura);

        % Exibe modelo
        disp(modelos{i})

        % Calcula Fit sem abrir gráfico
        [~,fit_temp] = compare(zv,modelos{i});

        fits(i) = fit_temp;

        fprintf('Fit = %.2f %%\n',fits(i));

    catch ME

        fprintf('Não foi possível estimar %s.\n',estruturas{i});
        fprintf('Motivo: %s\n',ME.message);

        modelos{i} = [];
        fits(i) = NaN;

    end

end


%% =========================================================
%               TABELA COM TODOS OS FITS
% ==========================================================

resultado = table(estruturas,fits, ...
    'VariableNames',{'Modelo','Fit_percent'});

resultado = sortrows(resultado,'Fit_percent','descend');

fprintf('\n=============================================\n');
fprintf('          COMPARAÇÃO DOS MODELOS\n');
fprintf('=============================================\n');

disp(resultado)


%% =========================================================
%              ESCOLHA DO MELHOR MODELO
% ==========================================================

validos = ~isnan(fits);

if ~any(validos)
    error('Nenhum dos modelos pôde ser estimado.');
end

indices_validos = find(validos);

[melhorFit,posicao] = max(fits(validos));

idx = indices_validos(posicao);

Melhor_modelo = modelos{idx};
Melhor_estrutura = estruturas{idx};


fprintf('\n=============================================\n');
fprintf('          MELHOR MODELO IDENTIFICADO\n');
fprintf('=============================================\n');

fprintf('Estrutura: %s\n',Melhor_estrutura);
fprintf('Fit: %.2f %%\n\n',melhorFit);


%% =========================================================
%                  MODELO IDPROC
% ==========================================================

fprintf('\n=============================================\n');
fprintf('                 MODELO IDPROC\n');
fprintf('=============================================\n');

disp(Melhor_modelo)


%% =========================================================
%               FUNÇÃO DE TRANSFERÊNCIA
% ==========================================================

G = tf(Melhor_modelo);

fprintf('\n=============================================\n');
fprintf('            FUNÇÃO DE TRANSFERÊNCIA\n');
fprintf('=============================================\n');

disp(G)


%% =========================================================
%              NUMERADOR E DENOMINADOR
% ==========================================================

[num,den] = tfdata(G,'v');

fprintf('\nNumerador:\n');
disp(num)

fprintf('Denominador:\n');
disp(den)


%% =========================================================
%                    GANHO ESTÁTICO
% ==========================================================

Kdc = dcgain(G);

fprintf('\nGanho estático (DC Gain):\n');
disp(Kdc)


%% =========================================================
%                         POLOS
% ==========================================================

% Remove zeros iniciais do denominador, se existirem
den_aux = den;

while length(den_aux) > 1 && abs(den_aux(1)) < 1e-12
    den_aux(1) = [];
end

polos = roots(den_aux);

fprintf('\nPolos:\n');
disp(polos)


%% =========================================================
%                         ZEROS
% ==========================================================

% Usamos roots() para evitar conflito com variável chamada "zero"

num_aux = num;

while length(num_aux) > 1 && abs(num_aux(1)) < 1e-12
    num_aux(1) = [];
end

if length(num_aux) <= 1

    zeros_modelo = [];

else

    zeros_modelo = roots(num_aux);

end

fprintf('\nZeros:\n');

if isempty(zeros_modelo)

    fprintf('O modelo não possui zeros finitos.\n');

else

    disp(zeros_modelo)

end


%% =========================================================
%                  ATRASO DE ENTRADA
% ==========================================================

try

    atraso = G.InputDelay;

    fprintf('\nAtraso de entrada da função de transferência:\n');
    disp(atraso)

catch

    fprintf('\nAtraso de entrada não disponível.\n');

end


%% =========================================================
%             PARÂMETROS DO MODELO IDPROC
% ==========================================================

fprintf('\n=============================================\n');
fprintf('          PARÂMETROS DO MODELO\n');
fprintf('=============================================\n');


if isprop(Melhor_modelo,'Kp')

    fprintf('Kp = ');
    disp(Melhor_modelo.Kp)

end


if isprop(Melhor_modelo,'Tp1')

    fprintf('Tp1 = ');
    disp(Melhor_modelo.Tp1)

end


if isprop(Melhor_modelo,'Tp2')

    fprintf('Tp2 = ');
    disp(Melhor_modelo.Tp2)

end


if isprop(Melhor_modelo,'Tp3')

    fprintf('Tp3 = ');
    disp(Melhor_modelo.Tp3)

end


if isprop(Melhor_modelo,'Tw')

    fprintf('Tw = ');
    disp(Melhor_modelo.Tw)

end


if isprop(Melhor_modelo,'Zeta')

    fprintf('Zeta = ');
    disp(Melhor_modelo.Zeta)

end


if isprop(Melhor_modelo,'Tz')

    fprintf('Tz = ');
    disp(Melhor_modelo.Tz)

end


if isprop(Melhor_modelo,'Td')

    fprintf('Td = ');
    disp(Melhor_modelo.Td)

end


%% =========================================================
%       GRÁFICO PADRÃO DO PROFESSOR - compare(zv,...)
% ==========================================================

figure(1)

compare(zv,Melhor_modelo)

grid on

title(['Comparação - ',Melhor_estrutura, ...
       ' | Fit = ',num2str(melhorFit,'%.2f'),' %'])


%% =========================================================
%              SIMULAÇÃO DO MELHOR MODELO
% ==========================================================

yest = idsim(FI_d,Melhor_modelo);


%% =========================================================
%       GRÁFICO DADOS EXPERIMENTAIS x MODELO
% ==========================================================

figure(2)

plot(t(1:end-1), ...
     TI_d(1:end-1), ...
     'b-', ...
     'LineWidth',1.2)

hold on

plot(t(1:end-1), ...
     yest(1:end-1), ...
     'r--', ...
     'LineWidth',1.2)

grid on

legend('Dados experimentais', ...
       'Melhor modelo', ...
       'Location','best')

xlabel('Tempo')

ylabel('\Delta T')

title(['Melhor modelo: ', ...
       Melhor_estrutura, ...
       ' | Fit = ', ...
       num2str(melhorFit,'%.2f'), ...
       ' %'])


%% =========================================================
%                       RESUMO FINAL
% ==========================================================

fprintf('\n=============================================\n');
fprintf('                 RESUMO FINAL\n');
fprintf('=============================================\n');

fprintf('Estrutura escolhida: %s\n',Melhor_estrutura);

fprintf('Fit: %.2f %%\n',melhorFit);

fprintf('Ganho estático: %.6f\n',Kdc);

fprintf('\nFunção de transferência:\n');
disp(G)

fprintf('\nNumerador:\n');
disp(num)

fprintf('Denominador:\n');
disp(den)

fprintf('\nPolos:\n');
disp(polos)

fprintf('Zeros:\n');

if isempty(zeros_modelo)

    fprintf('Nenhum zero finito.\n');

else

    disp(zeros_modelo)

end

fprintf('\n=============================================\n');
fprintf('              FIM DA IDENTIFICAÇÃO\n');
fprintf('=============================================\n');