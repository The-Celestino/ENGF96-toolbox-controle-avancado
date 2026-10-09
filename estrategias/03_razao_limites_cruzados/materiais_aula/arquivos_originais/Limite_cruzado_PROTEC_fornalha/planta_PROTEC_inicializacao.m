% Inicializa��o da Planta PROTEC
%
% Univesidade Federal da Bahia
% Escola Polit�cnica
% Programa de Engenharia Industrial
% PROTEC: Laborat�rio de Processo e Tecnologia
%
% Sugest�es e cr�ticas, favor escrever para 
% kalid@ufba.br           www.PEI.ufba.br
% (71) 3283.9811    ou    (71) 9188.3316

% � � � � � � � � � �

clear all ; close all ; clc
disp(' ')
disp(' Simula��o em regime din�mico da planta PROTEC')
disp(' ')
disp(' Universidade Federal da Bahia')
disp(' Escola Polit�cnica')
disp(' Programa de Engenharia Industrial')
disp(' PROTEC: Laborat�rio de Processo e Tecnologia')
disp(' ')
disp(' Sugest�es e cr�ticas, favor escrever para')
disp(' kalid@ufba.br           www.PEI.ufba.br')
disp(' (71) 3283.9811    ou    (71) 9188.3316')
disp(' ')

load planta_PROTEC_estado_estacionario_inicial

tempo_amostragem = 1e-2 ;
tempo_simulacao = inf ;

% Estimativa da temperatura ambiente no m�s, dia e hor�rio da simula��o:
dia     = date ;
n_dia   = datenum(dia(1:6), 'dd-mmm') ;
hora    = clock ;
minutos = hora(4)*60 + hora(5) ;

%             dia    temperatura m�nima
T_m_data = [ 733408     26.5     % '01-jan'
             733589     20     % '30-jun'
             733772     26.5 ] ; % '30-dez'

%           minutos  temperatura m�xima
% T_m_hora = [    0       27     % zero hora
%               840       37     % 14 horas
%              1440       27 ] ; % 24 horas
% 
% T_interp_data = interp1( T_m_data(:,1) , T_m_data(:,2)    , n_dia )   ;
% T_interp_hora = interp1( T_m_hora(:,1) , T_m_hora(:,2)-27 , minutos ) ;
% temperatura_ref   = ( min(T_m_data(:,2)) + max(T_m_data(:,2)) ) / 2   ;
% temperatura_delta = T_interp_data + T_interp_hora - temperatura_ref   ;
temperatura_delta = 0 ;

%--------------------------------------
% Dados para o modelo da caldeira
% Fonte: Pellegrinetti, Gordon and Bentsman, Joseph. 
% Nonlinear Control Oriented Boiler Modeling - A Benchmark Problem for Controller Design. 
% IEEE Transactions on Control System Technology, Vol. 4, No. 1, January 1996
% sem incertezas  n_i = 0

c(1,1) = -0.00478 ;
c(1,2) =  0.280   ;
c(1,3) =  0.01348 ;
c(1,4) =  0.02493 ;

c(2,1) =   0.1540357 ;
c(2,2) = 103.5462    ;
c(2,3) = 107.4835    ;
c(2,4) =   1.95150   ;
c(2,5) =  20.04      ;
c(2,6) =   1.824     ;

c(3,1) = 0.00533176 ;
c(3,2) = 0.0251950  ;
c(3,3) = 0.7317058  ;

c(4,1) = 0.04     ;
c(4,2) = 0.029988 ;
c(4,3) = 0.018088 ;

c(5,1) = 14.214 ;

c(6,1) = 1.00 ;

c(7,10) = -0.1048569 ;
c(7,1) =  0.15479    ;
c(7,2) =  0.4954961  ;
c(7,3) = -0.20797    ;
c(7,4) =  1.2720     ;

c(7,5) = -324212.7805  ;
c(7,6) =  -99556.24778 ;

c(7,7) =     0.0011850 ;
c(7,8) = -1704.50476   ;
c(7,9) =  -103.7351    ;

c(8,1) =  0.85663 ;
c(8,2) = -0.18128 ;

tm(1) =  2 ; % tm [=] segundos
tm(2) =  2 ;
tm(3) =  3 ;
tm(4) =  3 ;
tm(5) =  4 ;
tm(6) = 10 ;
tm(7) =  2 ;
% tm = tm/60 ; % tempo em minutos
% Fim dos dados para o modelo da caldeira
%--------------------------------------


%--------------------------------------------------------------------------

% Os pr�ximos comandos somente s�o necess�rios se houver altera��o na
% planta que mude o estado estacion�rio da mesma
% 
% % Area 100 - Tanque de carga
% Estado_Estacionario( 1)  = LI111(end)  ;
% Estado_Estacionario( 2)  = TI111(end)  ;
% Estado_Estacionario(3:5) = Tanque_concentracoes_molares(end,:) ;
% Estado_Estacionario( 6)  = FI111(end)  ;
% Estado_Estacionario( 7)  = AI111A(end) ;
% Estado_Estacionario( 8)  = AI111B(end) ;
% Estado_Estacionario( 9)  = AI111C(end) ;
% Estado_Estacionario(10)  = FI101(end)  ;
% 
% % Area 400 - CSTR
% Estado_Estacionario(11)  = AI411A(end) ;
% Estado_Estacionario(12)  = AI411B(end) ;
% Estado_Estacionario(13)  = AI411C(end) ;
% 
% % Area 200 - Trocador de calor
% Estado_Estacionario(14:21) = Ttubo(end,1:8)   ;
% Estado_Estacionario(22:29) = Tcasco(end,2:9)  ;
% Estado_Estacionario(30:37) = Tparede(end,1:8) ;
% 
% % Area 300 - Fornalha
% Estado_Estacionario(38) = FI302(end) ;
% Estado_Estacionario(39) = FI303(end) ;
% Estado_Estacionario(40) = TI312(end) ;
% Estado_Estacionario(41:40+26) = Fornalha_Estados(end,:) ;
% 
% % Area 400 - CSTR
% Estado_Estacionario(67)    = FI411(end) ;
% Estado_Estacionario(68)    = FI403(end) ;
% Estado_Estacionario(69)    = FI402(end) ;
% Estado_Estacionario(70:72) = CSTR_Concentracao_molar(end,:) ;
% Estado_Estacionario(73)    = LI411(end) ;
% Estado_Estacionario(74)    = TI411(end) ;
% Estado_Estacionario(75)    = TI412(end) ;
% 
% % Area 500 - Torre de Destila��o
% Estado_Estacionario(76)    = FI511(end) ;
% Estado_Estacionario(77)    = FI503(end) ;
% Estado_Estacionario(78)    = FI512(end) ;
% Estado_Estacionario(79)    = FI502(end) ;
% Estado_Estacionario(80)    = FI912(end) ;
% Estado_Estacionario(81:80+41)   = perfil_fracao_molar_B_sem_C(end,:) ;
% Estado_Estacionario(122:121+41) = perfil_holdup(end,:)               ;
% Estado_Estacionario(163)   = Vazao_molar_C(end)         ;
% Estado_Estacionario(164)   = A500_calor_refervedor(end) ;
% 
% % Area 100 - Tanque de carga
% Estado_Estacionario(165)   = FI103(end) ;
% Estado_Estacionario(166)   = B103(end)  ; % Energia para tanque de carga
% 
% % Area 700 - Caldeira
% Estado_Estacionario(167)   = 1000       ; % Vaz�o de gases de exaust�o para caldeira [=] m�/h
% Estado_Estacionario(168)   = FI711(end) ; % Vaz�o de �gua de alimenta��o da caldeira= vaz�o de vapor
% Estado_Estacionario(169)   = FI711(end) ; % Vaz�o de �gua de alimenta��o da caldeira= vaz�o de vapor
% % Estado_Estacionario(170)   = 
% Estado_Estacionario(171)   = 0.56144083668423 ; % Vaz�o de �gua para        caldeira [=] adimensional
% Estado_Estacionario(172)   = PI711(end) ; % Press�o [=] kgf/cm�
% Estado_Estacionario(173)   = AI711(end) ; % Excesso de oxig�nio        na   caldeira [=] %
% Estado_Estacionario(174)   = AI712(end) ; % Massa espec�fica da �gua L na   caldeira [=] kg/m�
% Estado_Estacionario(175)   = 0.3227     ; % Vazao de combustivel       para caldeira [=] adimensional
% Estado_Estacionario(176)   = 0.39503    ; % Vazao de ar                para caldeira [=] adimensional
% 
% % Area 900 - Tanque de efluente
% Estado_Estacionario(177)   = LI911(end) ;
% Estado_Estacionario(178)   = TI911(end) ;
% Estado_Estacionario(179)   = Tanque_efluente_conc_molar(end,1) ;
% Estado_Estacionario(180)   = Tanque_efluente_conc_molar(end,2) ;
% Estado_Estacionario(181)   = Tanque_efluente_conc_molar(end,3) ;
% Estado_Estacionario(182)   = FI911(end) ;
% 
% save  Planta_PROTEC_estado_estacionario_inicial  Estado_Estacionario
% 
% 
% Inicializa��o da Planta PROTEC
%
% Univesidade Federal da Bahia
% Escola Polit�cnica
% Programa de Engenharia Industrial
% PROTEC: Laborat�rio de Processo e Tecnologia
%
% Sugest�es e cr�ticas, favor escrever para 
% kalid@ufba.br           www.PEI.ufba.br
% (71) 3283.9811    ou    (71) 9188.3316