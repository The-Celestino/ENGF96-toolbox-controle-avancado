function [sys,x0] = tanque(t,x,u,flag,rho,Cp,A,k,lambda)

% Sistema: Vaso pulmao encamisado com vapor saturado
%
% Autor:  Marcio Martins
%         Departamento de Engenharia Quimica EPUFBA
%
% Interface Simulink e Matlab atraves do bloco S-function     
%
% Inputs:
%
% t : variavel independente (geralmente esta variavel e o tempo) 
% x : variaveis de estado do sistema
% u : perturbações externas ou variáveis manipuladas
%
% Outputs:   variaveis internas: sys, flag e  x0
%            quando  flag  é  0, sys contem as dimensões dos vetores do
%            sistema (nº de variaveis de estado, entrada e saida) e 
%            x0  contem as condições iniciais;
%            quando  flag  é  1, sys contem o sistema de EDOs;
%            quando  flag  é  3, sys contem o vetor das variaveis de saida 

%==========================================================================

if abs(flag) == 1
    
    % Variaveis de estado do sistema
    L = x(1) ; % nivel  do tanque  [=] m
    T = x(2) ; % temperatura interna do vaso  [=] ºC
    
    % Entradas do sistema
    Fi = u(1) ; % vazão volumetrica de alimentação do vaso [=] m3/min
    Ti = u(2) ; % temperatura  da corrente de alimentacao do vaso [=] ºC
    Fv = u(3) ; % vazão massica de vapor transportado para a camisa do vaso [=] kg/min
    
    if ( L <= eps | T <= eps ) %#ok<OR2>
        disp( '      L        T       ' )
        disp( [ L  T ] )
        disp( ' Problemas em tanque.m' )
        return
    end
    
    
    % Sistema de equações diferenciais ordinárias (SEDO)
    dLdt  = ( Fi - k*sqrt(L) ) / A                              ;
    dTdt  = ( rho*Fi*Cp*(Ti - T) +  Fv*lambda )/ ( rho*A*L*Cp ) ;
    
    sys = [ dLdt dTdt ] ;
    
elseif abs(flag) == 3
    
    % estados do sistemas
    L = x(1) ; % nivel  do tanque  [=] m
    T = x(2) ; % temperatura interna do tanque  [=] ºC
    
    sys(1,1) = L  ; 
    sys(2,1) = T  ; 
    
elseif flag == 0
    
    % Inicialização do sistema
    CondInicL  = 2.0408 ; % nivel do vaso       [=] m
    CondInicT  = 45.4  ; % temperatura do vaso [=] ºC
    
    x0 = [ CondInicL
           CondInicT ] ;
    
    sys(1) =  2 ; % Número de estados contínuos
    sys(2) =  0 ; % Número de estados discretos
    sys(3) =  2 ; % Número de saídas
    sys(4) =  3 ; % Número de entradas
    sys(5) =  0 ; % Necessário quando as saídas dependem diretamente das entradas
    sys(6) =  1 ; % tempo de amostragem
else
    sys = [];
end

% Autor:  Marcio Martins
% Duvidas ou sugestoes: marciomartins@ufba.br

% Fim deste arquivo
