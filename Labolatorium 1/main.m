clc             %Czyszczenie okna poleceń
clear all       %Usunięcie zmiennych
close all       %zamknięcie wykresów

s = tf('s'); %utworzenie zmiennej s

k = 3, T1 = 3, T2 = 4, T3= 5; %wartości liczbowe które wybraliśmy


Ks = k / ((1 + s * T1 ) * (1 + s * T2) * (1 + s * T3)); %transmitancja

zpk(Ks); %Postać biegunowa transmitancji


[Z, B, W] = zpkdata(Ks, "v");  %Wyznaczenie zer biegunów i wzmocnienia

%Wykres zer i biegunów układu
figure
pzmap(Ks); 

[L, trac] = tfdata(Ks, 'v'); %Pobranie licznika i mianownika transmitancji

[A, B, C, D] = tf2ss(L, trac); %Zamiana transmitancji na model w przestrzeni stanów

model_ss = ss(A, B, C, D); %Utworzenie modelu układu w przestrzeni stanów

%wyświetlanie odpowiedzi skokowej układu
figure
step(Ks, 'r', 0:0.1:50);
title('Odpowiedz skokowa transmitancji');
xlabel('Czas, s');
ylabel('y');
grid on;


Ks2 = Ks * (s+1);   %Utworzenie drugiej transmitancji do porównania charakterystyk
w = logspace(-4, 2, 3000);   % Zakres częstotliwości do analizy charakterystyk

%Charakterystyki Nyquista dla obu transmitancji
figure 
nyquist(Ks, Ks2, w);
legend('Ks', 'Ks2');
title('Charakterystyki Nyquista dla Ks i Ks2');
grid on;

%Wykres Nyquista z fazą wyrażoną w radianach
figure
wykr = nyquistplot(Ks, w);
setoptions(wykr,'PhaseUnits','rad','Grid','on');

%Charakterystyki Bodego
figure;
bode(Ks, w);
grid on;
title('Charakterystyka Bodego');

%Charakterystyka amplitudowa układu
figure;
bodemag(Ks, w);
grid on;
title('Charakterystyka amplitudowa');

%Charakterystyka amplitudowa bez wykresu fazy
figure;
wykr = bodeplot(Ks, w);
setoptions(wykr, 'MagUnits', 'abs', 'PhaseVisible', 'off');

%linie pierwiastkowe
K2 = 1/((s*T1+1)*(s*T2+1));
figure
rlocus(Ks); %Wykres linii pierwiastkowych
%figure
%sisotool(Ks); %Wyznaczenie charakterystyk Bodego oraz linii pierwiastkowych
[zw, zf, cw, cf] = margin(Ks); %Zapasy stabilnosci 


%Badanie układu zamkniętego
Kuch = 1/(1+Ks); %Transmitancja uchybowa

%Odpowiedź skokowa transmitancji uchybowej
figure
step(Kuch);
title('Odpowiedź skokowa transmitancji uchybowej (Kuch)');
grid on;

Kzam = Ks/(1+Ks); %Transmitancja układu zamkniętego 

%Odpowiedź skokowa układu zamkniętego
figure
step(Kzam);
title('Odpowiedź skokowa transmitancji głównej (Kzam)');
grid on;

%Porównanie odpowiedzi skokowych obu transmitancji
figure 
step(Kuch, Kzam);
legend('Kuch', 'Kzam');
title('Porównanie odpowiedzi skokowej Kuch i Kzam');
grid on;

minreal(K2); %Uproszczenie transmitancji

%Definicja wskaźników nadążania i regulacji
trac = Kzam; %wskaźnik nadążania
reg = Kuch; %wskaźnik regulacji

% Porównanie charakterystyk amplitudowych wskaźników
figure 
bodemag(trac);
hold on;
bodemag(reg);
xlim([1 10]);
ylim([-3 8]);
title('Przebieg wskaźnika nadążania i wskaźnika regulacji');
grid on;
hold off;


%% WYKRESY Z SYMULACJI (SIMULINK)

%Ustalenie parametrów zbiornika i warunków początkowych
r1 = 1;             %promień zbiornika 
a1 = pi * r1^2;     %Pole podstawy walca
c1 = 1;             %Stała zaworu 
h10 = 0.5;          %Warunek początkowy

%Uruchomienie symulacji modelu w Simulinku
out = sim('Lab1_placeholder.slx');

%Wykres zmian przepływu w czasie
figure;
plot(out.Flow.Time, out.Flow.Data); 
grid on;
title('Przebieg odpowiedzi skokowej przepływu (q_{12})');
xlabel('Czas t [s]');
ylabel('Przepływ q_{12} [m^3/s]');

%Wykres zmian wysokości cieczy w zbiorniku
figure;
plot(out.Level.Time, out.Level.Data); 
grid on;
title('Przebieg odpowiedzi skokowej wysokości (h_1)');
xlabel('Czas t [s]');
ylabel('Wysokość h_1 [m]');
