clear all
close all
clc

syms k At rho Cp lambda Fi Ti Fv L T 

f1  = ( Fi - k*sqrt(L) ) / At                              ;
f2  = ( rho*Fi*Cp*(Ti - T) +  Fv*lambda )/ ( rho*At*L*Cp ) ;
f     = [f1;f2]   ;
state = [L;T]     ;
in    = [Fi;Ti;Fv];

% Valores nominais
% ====================================================================
% Parametros
% ====================================================================
k=7;
At=pi*0.5^2;
rho=1e3;
Cp=4.18;
lambda=2.257e4;
% ====================================================================
% Variaveis entrada/saida
% ====================================================================
Fi_nom=10;
Ti_nom=40;
Fv_nom=10;
L_nom=2.0408;
T_nom=45.4;

Fi=Fi_nom;
Ti=Ti_nom;
Fv=Fv_nom;
L=L_nom;
T=T_nom;

A = double(subs(jacobian(f,state)));
B = double(subs(jacobian(f,in)))   ;
C = eye(2)                 ;
D = zeros(2,3)             ;

sys=ss(A,B,C,D)          ;
[num,den]=tfdata(sys,'v');
g=tf(num,den)            ;

Ts=0.1;
gd=c2d(g,Ts);
% Kp=0.4081
% tau_p=0.3206