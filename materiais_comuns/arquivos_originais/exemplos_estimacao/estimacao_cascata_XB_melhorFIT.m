close all
clc

%% =========================================================
%                  DADOS DA SIMULAÇÃO
% ==========================================================

t  = FC503_SP_id.Time(:);
SP = FC503_SP_id.Data(:);
B  = xB_topo.Data(:);

Ts = median(diff(t));

fprintf('\nTempo de amostragem Ts = %.8f\n',Ts);


%% =========================================================
%             PONTO DE OPERAÇÃO PRÉ-DEGRAU
% ==========================================================

% Degrau aplicado em t = 150
base = t >= 120 & t < 150;

SP0 = mean(SP(base));
B0  = mean(B(base));

fprintf('\nPonto de operação:\n');
fprintf('FC503_SP0 = %.6f\n',SP0);
fprintf('xB_topo0  = %.6f\n',B0);


%% =========================================================
%                 VARIÁVEIS EM DESVIO
% ==========================================================

FC503_d = SP - SP0;
BI_d    = B  - B0;


%% =========================================================
%             DADOS PARA IDENTIFICAÇÃO
% ==========================================================

ze = iddata(BI_d,FC503_d,Ts);
zv = iddata(BI_d,FC503_d,Ts);


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

% Número aproximado de parâmetros livres de cada estrutura
nParametros = [
    2   % P1    = Kp, Tp1
    3   % P1D   = Kp, Tp1, Td
    3   % P1Z   = Kp, Tp1, Tz
    4   % P1ZD  = Kp, Tp1, Tz, Td
    3   % P2    = Kp, Tp1, Tp2
    3   % P2U   = Kp, Tw, Zeta
    4   % P3    = Kp, Tp1, Tp2, Tp3
    1   % P0I   = Kp + integrador estrutural
    2   % P0ID  = Kp, Td + integrador estrutural
];

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

        modelos{i} = pem(ze,estrutura);

        disp(modelos{i})

        [~,fit_temp] = compare(zv,modelos{i});

        fits(i) = fit_temp;

        fprintf('Fit = %.2f %%\n',fits(i));
        fprintf('Número de parâmetros = %d\n',nParametros(i));

    catch ME

        fprintf('Não foi possível estimar %s.\n',estruturas{i});
        fprintf('Motivo: %s\n',ME.message);

        modelos{i} = [];
        fits(i) = NaN;

    end

end


%% =========================================================
%              CRITÉRIO DE PARCIMÔNIA
% ==========================================================

% Tolerância em pontos percentuais em relação ao melhor Fit.
%
% Exemplo:
% melhor Fit = 90%
% tolFit = 1
%
% São candidatos os modelos com Fit >= 89%.

tolFit = 1.0;

validos = ~isnan(fits);

if ~any(validos)
    error('Nenhum modelo pôde ser estimado.');
end

melhorFitAbsoluto = max(fits(validos));

deltaFit = melhorFitAbsoluto - fits;

% Modelos considerados praticamente equivalentes ao melhor Fit
candidatos = validos & (deltaFit <= tolFit);

fprintf('\n=============================================\n');
fprintf('          ANÁLISE DE PARCIMÔNIA\n');
fprintf('=============================================\n');

fprintf('Maior Fit encontrado = %.2f %%\n',melhorFitAbsoluto);
fprintf('Tolerância adotada = %.2f ponto percentual\n',tolFit);

fprintf('\nModelos dentro da faixa de parcimônia:\n');

for i = find(candidatos)'

    fprintf('%-6s | Fit = %6.2f %% | Parâmetros = %d\n', ...
        estruturas{i},fits(i),nParametros(i));

end


%% =========================================================
%   ESCOLHA DO MAIS SIMPLES ENTRE OS CANDIDATOS
% ==========================================================

indices_candidatos = find(candidatos);

minParametros = min(nParametros(indices_candidatos));

maisSimples = indices_candidatos( ...
    nParametros(indices_candidatos) == minParametros);


% Se houver empate na complexidade,
% escolhe o de maior Fit
[~,pos] = max(fits(maisSimples));

idx = maisSimples(pos);


Modelo_parcimonioso = modelos{idx};
Estrutura_parcimoniosa = estruturas{idx};
Fit_parcimonioso = fits(idx);


%% =========================================================
%                 TABELA DE RESULTADOS
% ==========================================================

resultado = table( ...
    estruturas, ...
    fits, ...
    nParametros, ...
    deltaFit, ...
    candidatos, ...
    'VariableNames', ...
    {'Modelo','Fit_percent','N_parametros', ...
     'Delta_Fit','Candidato_parcimonia'});

resultado = sortrows(resultado, ...
    {'Candidato_parcimonia','N_parametros','Fit_percent'}, ...
    {'descend','ascend','descend'});

fprintf('\n=============================================\n');
fprintf('          COMPARAÇÃO DOS MODELOS\n');
fprintf('=============================================\n');

disp(resultado)


%% =========================================================
%                MODELO SELECIONADO
% ==========================================================

fprintf('\n=============================================\n');
fprintf('     MODELO ESCOLHIDO POR PARCIMÔNIA\n');
fprintf('=============================================\n');

fprintf('Estrutura: %s\n',Estrutura_parcimoniosa);
fprintf('Fit: %.2f %%\n',Fit_parcimonioso);
fprintf('Número de parâmetros: %d\n',nParametros(idx));

fprintf('\nCritério:\n');
fprintf(['Modelo dentro de %.2f ponto percentual do maior Fit ', ...
         'com o menor número de parâmetros.\n'],tolFit);


%% =========================================================
%                  MODELO IDPROC
% ==========================================================

disp(' ')
disp('Modelo IDPROC selecionado:')

disp(Modelo_parcimonioso)


%% =========================================================
%               FUNÇÃO DE TRANSFERÊNCIA
% ==========================================================

G = tf(Modelo_parcimonioso);

fprintf('\n=============================================\n');
fprintf('            FUNÇÃO DE TRANSFERÊNCIA\n');
fprintf('=============================================\n');

disp(G)


%% =========================================================
%             NUMERADOR E DENOMINADOR
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

fprintf('\nGanho estático:\n');
disp(Kdc)


%% =========================================================
%                         POLOS
% ==========================================================

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
%                 PARÂMETROS IDPROC
% ==========================================================

fprintf('\n=============================================\n');
fprintf('          PARÂMETROS DO MODELO\n');
fprintf('=============================================\n');

if isprop(Modelo_parcimonioso,'Kp')
    fprintf('Kp = ');
    disp(Modelo_parcimonioso.Kp)
end

if isprop(Modelo_parcimonioso,'Tp1')
    fprintf('Tp1 = ');
    disp(Modelo_parcimonioso.Tp1)
end

if isprop(Modelo_parcimonioso,'Tp2')
    fprintf('Tp2 = ');
    disp(Modelo_parcimonioso.Tp2)
end

if isprop(Modelo_parcimonioso,'Tp3')
    fprintf('Tp3 = ');
    disp(Modelo_parcimonioso.Tp3)
end

if isprop(Modelo_parcimonioso,'Tw')
    fprintf('Tw = ');
    disp(Modelo_parcimonioso.Tw)
end

if isprop(Modelo_parcimonioso,'Zeta')
    fprintf('Zeta = ');
    disp(Modelo_parcimonioso.Zeta)
end

if isprop(Modelo_parcimonioso,'Tz')
    fprintf('Tz = ');
    disp(Modelo_parcimonioso.Tz)
end

if isprop(Modelo_parcimonioso,'Td')
    fprintf('Td = ');
    disp(Modelo_parcimonioso.Td)
end


%% =========================================================
%        GRÁFICO PADRÃO DO SYSTEM IDENTIFICATION
% ==========================================================

figure(1)

compare(zv,Modelo_parcimonioso)

grid on

title(['Modelo parcimonioso: ', ...
       Estrutura_parcimoniosa, ...
       ' | Fit = ', ...
       num2str(Fit_parcimonioso,'%.2f'), ...
       ' %'])


%% =========================================================
%              SIMULAÇÃO DO MODELO
% ==========================================================

yest = idsim(FC503_d,Modelo_parcimonioso);


%% =========================================================
%          DADOS EXPERIMENTAIS x MODELO
% ==========================================================

figure(2)

plot(t(1:end-1), ...
     BI_d(1:end-1), ...
     'b-', ...
     'LineWidth',1.3)

hold on

plot(t(1:end-1), ...
     yest(1:end-1), ...
     'r--', ...
     'LineWidth',1.3)

grid on

legend( ...
    'Dados experimentais', ...
    ['Modelo ',Estrutura_parcimoniosa], ...
    'Location','best')

xlabel('Tempo')

ylabel('\Delta x_B')

title(['FC503 SP \rightarrow xB topo | ', ...
       Estrutura_parcimoniosa, ...
       ' | Fit = ', ...
       num2str(Fit_parcimonioso,'%.2f'), ...
       ' %'])


%% =========================================================
%      GRÁFICO DE FIT x COMPLEXIDADE DOS MODELOS
% ==========================================================

figure(3)

scatter(nParametros(validos), ...
        fits(validos), ...
        70, ...
        'filled')

grid on
hold on

for i = find(validos)'

    text( ...
        nParametros(i)+0.03, ...
        fits(i), ...
        estruturas{i});

end

plot( ...
    nParametros(idx), ...
    fits(idx), ...
    'kp', ...
    'MarkerSize',14, ...
    'MarkerFaceColor','y')

xlabel('Número de parâmetros')

ylabel('Fit (%)')

title('Avaliação de parcimônia: ajuste x complexidade')

legend( ...
    'Modelos testados', ...
    'Modelo escolhido', ...
    'Location','best')


%% =========================================================
%                       RESUMO FINAL
% ==========================================================

fprintf('\n=============================================\n');
fprintf('       RESUMO FINAL - PARCIMÔNIA\n');
fprintf('=============================================\n');

fprintf('Entrada: FC503_SP\n');
fprintf('Saída: xB_topo\n');

fprintf('\nMaior Fit absoluto: %.2f %%\n', ...
    melhorFitAbsoluto);

fprintf('Modelo selecionado: %s\n', ...
    Estrutura_parcimoniosa);

fprintf('Fit selecionado: %.2f %%\n', ...
    Fit_parcimonioso);

fprintf('Número de parâmetros: %d\n', ...
    nParametros(idx));

fprintf('Perda de Fit em relação ao máximo: %.4f p.p.\n', ...
    melhorFitAbsoluto - Fit_parcimonioso);

fprintf('\nFunção de transferência selecionada:\n');
disp(G)

fprintf('\n=============================================\n');
fprintf('          FIM DA IDENTIFICAÇÃO\n');
fprintf('=============================================\n');