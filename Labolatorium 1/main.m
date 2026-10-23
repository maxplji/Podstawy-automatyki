clc             %Czyszczenie okna poleceń
clear all       %Usunięcie zmiennych
close all       %zamknięcie wykresów

s = tf('s'); 

k = 3, T1 = 3, T2 = 4, T3= 5; %wartości liczbowe które wybraliśmy


Ks = k / ((1 + s * T1 ) * (1 + s * T2) * (1 + s * T3)); %transmitancja

zpk(Ks); 


[Zera, Bieguny, Wzmocnienia] = zpkdata(Ks, "v");  %Wyznaczenie zer biegunów i wzmocnienia

figure
pzmap(Ks); %Wyświetlenie wykresu zer i biegunów transmitancji

[L, M] = tfdata(Ks, 'v'); %Pobranie licznika i mianownika transmitancji

[A, B, C, D] = tf2ss(L, M); %Zamiana transmitancji na równania stanu

sys = ss(A, B, C, D); %Utworzenie modelu układu w przestrzeni stanów

%wyświetlanie odpowiedzi skokowej układu
figure
step(Ks, 'r', 0:0.1:50);
title('Odpowiedz skokowa transmitancji');
xlabel('Czas, s');
ylabel('y');
grid on;


Ks2 = Ks * (s+1);

%Charakterystyki Nyquista
figure 
nyquist(Ks, Ks2);
legend('Ks', 'Ks2');
title('Charakterystyki Nyquista');
grid on;

figure
h = nyquistplot(Ks);
setoptions(h,'PhaseUnits','rad','Grid','on');

%Charakterystyki Bodego
figure;
bode(Ks);
grid on;
title('Charakterystyka Bodego');

figure;
bodemag(Ks);
grid on;
title('Charakterystyka amplitudowa');

figure;
h = bodeplot(Ks);
setoptions(h, 'MagUnits', 'abs', 'PhaseVisible', 'off');

%linie pierwiastkowe
K2 = 1/((s*T1+1)*(s*T2+1));
figure
rlocus(Ks); %Wykres linii pierwiastkowych
figure
sisotool(Ks); %Wyznaczenie charakterystyk Bodego oraz linii pierwiastkowych
[zapasAmp, zapasFaz, wAmp, wFaz] = margin(Ks); %Zapasy stabilnosci