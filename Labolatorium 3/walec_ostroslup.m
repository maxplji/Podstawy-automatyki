clc;
clear;
close all;

A2 = 1.47044;
B2 = 4.08042;

H1 = 3 ;
H2 = 10;

R1 = 1.9544;

C1 = 1.8257;
C2 = 0.745356;

%-----------------------------cz.1-----------------------------%

w = logspace(-4, 2, 8000);

% Punkt pracy
h20 = 0.5*H2;
qwe0 = C2*sqrt(h20);
h10 = (qwe0/C1)^2;

% Wzmocnienie i stale czasowe
k = 2*sqrt(h20)/C2;

T1 = (2*pi*R1^2*sqrt(h10))/C1;
T2 = (2*A2*B2*h20^(5/2))/(H2^2*C2);
T3 = 0.5*min(T1,T2);

% Transmitancja obiektu z elementem wykonawczym
s = tf('s');

sys = k/((1+T1*s)*(1+T2*s)*(1+T3*s));

figure;
bode(sys);
grid on;

figure;
nyquist(sys, w);
grid on;


% Kryterium Mmax

kr1 = 0.5;

Ko1 = kr1 * sys; 
G1 = feedback(Ko1, 1);   

[Mmax, wpeak] = getPeakGain(G1);

Mmax
wpeak

figure;
bodemag(G1);
grid on;
title('Charakterystyka amplitudowa - Mmax');

% Zapas modulu
kr2 = 0.8007;

Ko2 = kr2 * sys;
[dK, dFi] = margin(Ko2);

dK
dFi


figure;
margin(Ko2);
grid on;

% Zapas fazy
kr3 = 0.7202;

Ko3 = kr3 * sys;
[dK3, dFi3] = margin(Ko3);

dFi3

figure;
margin(Ko3);
grid on;

G1 = feedback(kr1*sys, 1);
G2 = feedback(kr2*sys, 1);
G3 = feedback(kr3*sys, 1);

figure;
step(G1, G2, G3);
grid on;
legend('Mmax', 'Zapas modulu', 'Zapas fazy');
title('Porownanie odpowiedzi skokowych');

dFi




%cz2




%------------------------------cz.2--------------------------------%
%%%%%%%%%% regulacja P dla kr dla delta_K %%%%%%%%%%%%%%
kr = kr2;
K0 = sys*kr;
KZ = K0/(K0+1);
figure
step(KZ)
stpinf = stepinfo(KZ);
eust = 1 - dcgain(KZ);

%%% wskazniki czasowe %%%
przeregulowanie_procent = stpinf.Overshoot;
czas_narastania = stpinf.RiseTime;
czas_opoznienia = 0; %policzyc trzeba
tr = stepinfo(KZ, 'SettlingTimeThreshold', 0.02).TransientTime;

%%% wskazniki czestotliwosciowe %%%
[zapas_amp, zapas_fazy] = margin(K0);

% figure
% bodemag(KZ);
[Max_rez, czestotliwosc_rez] = getPeakGain(KZ);

%%% wskazniki pierwiastkowe %%%
figure
rlocus(K0);
RR = rlocus(K0, 1);
ni = abs(max(real(RR)));
teta = max(abs(imag(RR./real(RR))));

zapas_amp
zapas_fazy
Max_rez
przeregulowanie_procent
tr
eust
ni
teta

%%%%%%%%%% regulacja P dla kr dla delta_fi %%%%%%%%%%%%%%
kr7 = kr3;
K01 = sys*kr7;
KZ1 = K01/(K01+1);
step(KZ1)
stpinf1 = stepinfo(KZ1);
eust1 = 1 - dcgain(KZ1);

%%% wskazniki czasowe %%%
przeregulowanie_procent1 = stpinf1.Overshoot;
czas_narastania1 = stpinf1.RiseTime;
czas_opoznienia1 = 0; %policzyc trzeba
tr1 = stepinfo(KZ1, 'SettlingTimeThreshold', 0.02).TransientTime;

%%% wskazniki czestotliwosciowe %%%
[zapas_amp1, zapas_fazy1] = margin(K01);
bodemag(KZ1);
[Max_rez1, czestotliwosc_rez1] = getPeakGain(KZ1);

%%% wskazniki pierwiastkowe %%%
rlocus(sys);
RR1 = rlocus(K01, 1);
ni1 = abs(max(real(RR1)));
teta1 = max(abs(imag(RR1./real(RR1))));

zapas_amp1
zapas_fazy1
Max_rez1
przeregulowanie_procent1
tr1
eust1
ni1
teta1
