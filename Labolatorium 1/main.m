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


%Badanie układu zamkniętego
Ke = 1/(1+Ks); %Transmitancja uchybowa
figure
step(Ke);
title('Odpowiedź skokowa transmitancji uchybowej (Ke)');
grid on;

Ky = Ks/(1+Ks); %Transmitancja główna 
figure
step(Ky);
title('Odpowiedź skokowa transmitancji głównej (Ky)');
grid on;

figure 
step(Ke, Ky);
legend('Ke', 'Ky');
title('Porównanie odpowiedzi skokowej Ke i Ky');
grid on;

minreal(K2); % Skraca tranmitancje (zera i bieguny) - w 2 kodzie to było K114

M = Ky; % Określenie zmiennych - wskaźnik nadążania
q = Ke; % Określenie zmiennych - wskaźnik regulacji
figure 
bodemag(M);
hold on;
bodemag(q);
xlim([0.01 10]);
ylim([-6 5]);
title('Przebieg wskaźnika nadążania i wskaźnika regulacji');
grid on;
hold off;


%% WYKRESY Z SYMULACJI (SIMULINK)
% Definicja zmiennych w
r1 = 1;             %promień zbiornika 
a1 = pi * r1^2;     %Pole podstawy walca
c1 = 1;             %Stała zaworu 
h10 = 0;            %Warunek początkowy


figure;
plot(out.tout, out.Flow); 
grid on;
title('Przebieg odpowiedzi skokowej przepływu (q_{12})');
xlabel('Czas t [s]');
ylabel('Przepływ q_{12} [m^3/s]');

figure;
plot(out.tout, out.Level); 
grid on;
title('Przebieg odpowiedzi skokowej wysokości (h_1)');
xlabel('Czas t [s]');
ylabel('Wysokość h_1 [m]');
