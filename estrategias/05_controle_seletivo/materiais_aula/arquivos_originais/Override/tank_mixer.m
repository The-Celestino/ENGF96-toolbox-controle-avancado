function [sys,x0] = tank_mixer(t,x,u,flag)
V = 24    ; % [=] m3
A = 12.19 ; % [=] m2
h = V/A ; % [=] m

if abs(flag) == 1
    L = x(1);
    C = x(2);
    
    F1 = u(1);
    C1 = u(2);
    F2 = u(3);
    F3 = u(4);
    
    dLdt = (F1+F2-F3)/(A*L);
    dCdt = ((C1-C)*F1-C*F2)/(A*L);

    sys = [dLdt; dCdt];
elseif abs(flag) == 3
    L = x(1);
    C = x(2);
    sys = [L;C];
elseif flag == 0
    L0 = 2;
    C1 = 4  ; % [=] kmol/m3
    F1 = 0.2 ; % [=] m3/min
    F2 = 1.3 ; % [=] m3/min
    C0 = C1; % [=] kmol/m3
    x0 = [L0;C0];
    
    sys = [2 0 2 4 0 0];
else
    sys=[];
end
    