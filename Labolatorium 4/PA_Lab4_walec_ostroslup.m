clc;
clear;
close all;

%% Dane z labu 3
A2 = 1.47044;
B2 = 4.08042;
H1 = 3;
H2 = 10;
R1 = 1.9544;
C1 = 1.8257;
C2 = 0.745356;

w = logspace(-2, 4, 8000);

h20 = 0.5*H2;
qwe0 = C2*sqrt(h20);
h10 = (qwe0/C1)^2;

k = 2*sqrt(h20)/C2;
T1 = (2*pi*R1^2*sqrt(h10))/C1;
T2 = (2*A2*B2*h20^(5/2))/(H2^2*C2);
T3 = 0.3*min(T1,T2);

s = tf('s');
sys = k/((1+T1*s)*(1+T2*s)*(1+T3*s));

%% 1.1. Ziegler-Nichols - wzmocnienie krytyczne
[kgr, ~, wgr] = margin(sys);
kgr
Tosc = 2*pi/wgr

figure;
nyquist(kgr*sys, w);
grid on;

figure;
step(feedback(kgr*sys,1), 0:0.05:6*Tosc);
grid on;
title('Oscylacje na granicy stabilnosci');

% Regulator P
disp('P - Ziegler-Nichols');
kr_P = 0.5*kgr
K0_P = kr_P*sys;
KZ_P = feedback(K0_P,1);

info_P = stepinfo(KZ_P);
przeregulowanie_P = info_P.Overshoot
czas_narastania_P = info_P.RiseTime
tr_P = info_P.SettlingTime
eust_P = 1 - dcgain(KZ_P)
[zapas_amp_P, zapas_fazy_P] = margin(K0_P)
Mmax_P = getPeakGain(KZ_P)

% Regulator PI
disp('PI - Ziegler-Nichols');
kr_PI = 0.45*kgr
TI_PI = Tosc/1.2
Kr_PI = kr_PI*(1 + 1/(TI_PI*s));
K0_PI = Kr_PI*sys;
KZ_PI = feedback(K0_PI,1);

info_PI = stepinfo(KZ_PI);
przeregulowanie_PI = info_PI.Overshoot
czas_narastania_PI = info_PI.RiseTime
tr_PI = info_PI.SettlingTime
eust_PI = 1 - dcgain(KZ_PI)
[zapas_amp_PI, zapas_fazy_PI] = margin(K0_PI)
Mmax_PI = getPeakGain(KZ_PI)

% Regulator PID
disp('PID - Ziegler-Nichols');
kr_PID = 0.6*kgr
TI_PID = Tosc/2
TD_PID = Tosc/8
TF_PID = 0.02*TD_PID
Kr_PID = kr_PID*(1 + 1/(TI_PID*s) + TD_PID*s/(TF_PID*s+1));
K0_PID = Kr_PID*sys;
KZ_PID = feedback(K0_PID,1);

info_PID = stepinfo(KZ_PID);
przeregulowanie_PID = info_PID.Overshoot
czas_narastania_PID = info_PID.RiseTime
tr_PID = info_PID.SettlingTime
eust_PID = 1 - dcgain(KZ_PID)
[zapas_amp_PID, zapas_fazy_PID] = margin(K0_PID)
Mmax_PID = getPeakGain(KZ_PID)

figure;
step(KZ_P, KZ_PI, KZ_PID);
grid on;
legend('P','PI','PID');

%% 1.2. PID QDR - metoda dwoch punktow
[y,t] = step(sys, 0:0.05:150);
i1 = find(y >= 0.632*k,1);
i2 = find(y >= 0.283*k,1);
t1 = interp1(y(i1-1:i1), t(i1-1:i1), 0.632*k);
t2 = interp1(y(i2-1:i2), t(i2-1:i2), 0.283*k);
T = 1.5*(t1-t2)
To = t1-T
Ka = tf(k, [T 1], 'InputDelay', To);

figure;
step(sys, Ka);
grid on;
legend('Obiekt liniowy','Model zastepczy');

disp('PID - QDR');
kr_QDR = 1.2*T/(k*To)
TI_QDR = 2*To
TD_QDR = 0.5*To
TF_QDR = 0.05*TD_QDR
Kr_QDR = kr_QDR*(1 + 1/(TI_QDR*s) + TD_QDR*s/(TF_QDR*s+1));
K0_QDR = Kr_QDR*sys;
KZ_QDR = feedback(K0_QDR,1);

info_QDR = stepinfo(KZ_QDR);
przeregulowanie_QDR = info_QDR.Overshoot
czas_narastania_QDR = info_QDR.RiseTime
tr_QDR = info_QDR.SettlingTime
eust_QDR = 1 - dcgain(KZ_QDR)
[zapas_amp_QDR, zapas_fazy_QDR] = margin(K0_QDR)
Mmax_QDR = getPeakGain(KZ_QDR)

figure;
step(KZ_PID, KZ_QDR);
grid on;
legend('PID Z-N','PID QDR');

figure;
nyquist(K0_PID, K0_QDR);
grid on;
legend('PID Z-N','PID QDR');

figure;
bodemag(KZ_PID, KZ_QDR);
grid on;
legend('PID Z-N','PID QDR');

%% 2.1. Simulink - PID z nastawami z punktu 1.2
dw = 0.1;
t_skoku = 10;
t_koniec = 150;
du = C2*sqrt(h20+dw) - qwe0;

% W Simulinku: 0 wybiera wyjscie PID, 1 wybiera skok przeplywu.
tryb_otwarty = 0;
kr = kr_QDR;
TI = TI_QDR;
TD = TD_QDR;
TF = TF_QDR;

out21 = sim('walec_ostroslup_simulink.slx');
t21 = out21.h2.Time;
y21 = out21.h2.Data;
idx21 = t21 >= t_skoku;

disp('2.1. Model nieliniowy, nastawy z 1.2');
info21 = stepinfo(y21(idx21), t21(idx21)-t_skoku, y21(end), h20);
przeregulowanie_21 = info21.Overshoot
czas_narastania_21 = info21.RiseTime
tr_21 = info21.SettlingTime
eust_21 = h20 + dw - y21(end)

%% 2.2. Simulink - strojenie PID z odpowiedzi otwartego obiektu
tryb_otwarty = 1;
out_otw = sim('walec_ostroslup_simulink.slx');
t_otw = out_otw.h2.Time;
y_otw = out_otw.h2.Data;
idx_otw = t_otw >= t_skoku;
t = t_otw(idx_otw) - t_skoku;
y = y_otw(idx_otw) - h20;

dy = y(end);
k_nl = dy/du
i1 = find(y >= 0.632*dy,1);
i2 = find(y >= 0.283*dy,1);
t1 = interp1(y(i1-1:i1), t(i1-1:i1), 0.632*dy);
t2 = interp1(y(i2-1:i2), t(i2-1:i2), 0.283*dy);
T_nl = 1.5*(t1-t2)
To_nl = t1-T_nl

disp('2.2. Model nieliniowy, nastawy z odpowiedzi obiektu');
kr = 1.2*T_nl/(k_nl*To_nl)
TI = 2*To_nl
TD = 0.5*To_nl
TF = 0.05*TD

tryb_otwarty = 0;
out22 = sim('walec_ostroslup_simulink.slx');
t22 = out22.h2.Time;
y22 = out22.h2.Data;
idx22 = t22 >= t_skoku;

info22 = stepinfo(y22(idx22), t22(idx22)-t_skoku, y22(end), h20);
przeregulowanie_22 = info22.Overshoot
czas_narastania_22 = info22.RiseTime
tr_22 = info22.SettlingTime
eust_22 = h20 + dw - y22(end)

%% Porownanie 1.2, 2.1 i 2.2 dla tego samego skoku dw
[y12,t12] = step(dw*KZ_QDR, 0:0.05:(t_koniec-t_skoku));

figure;
plot([0; t12+t_skoku], [h20; h20+y12]);
hold on;
plot(t21,y21);
plot(t22,y22);
grid on;
xlabel('Czas [s]');
ylabel('h2 [m]');
legend('1.2. Model liniowy', '2.1. Nieliniowy, nastawy z 1.2', ...
    '2.2. Nieliniowy, nowe nastawy');
