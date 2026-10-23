clc
clear all 
close all

s = tf('s'); 

k = 3, T1 = 3, T2 = 4, T3= 5; %wartości liczbowe dla wzmocnienia


Ks = k / ((1 + s * T1 ) * (1 + s * T2) * (1 + s * T3)); %transmitancja

zpk(Ks); 


[Zera, Bieguny, Wzmocnienia] = zpkdata(Ks, "v");

figure
pzmap(Ks);

[L, M] = tfdata(Ks, 'v');

[A, B, C, D] = tf2ss(L, M);

sys = ss(A, B, C, D);

%wyświetlanie odpowiedzi skokowej transmitancji
figure
step(Ks, 'r', 0:0.1:50);
title('Odpowiedz skokowa transmitancji');
xlabel('Czas, s');
ylabel('y');
grid on;


Ks2 = Ks * (s+1);

figure 
nyquist(Ks, Ks2);
legend('Ks', 'Ks2');

figure
h = nyquistplot(Ks);
setoptions(h,'PhaseUnits','rad','Grid','on');



Kz = 1/ (1 + Ks);

figure
rlocus(Kz);

%figure
%sisotool(Kz);

[zapasAmp, zapasFaz, wAmp, wFaz] = margin(Kz);


