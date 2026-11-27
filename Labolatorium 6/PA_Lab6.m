clc
clear all
close all


%%%%%%%%%%%% Walec %%%%%%%%%%%%%
R1 = 1.9544;
H1 = 3;
C1 = 1.8257;

%%%%%%%%%%%% Ostroslup %%%%%%%%%%%%%
A2 = 1.47044;
B2 = 4.08042;
H2 = 10;
C2 = 0.745356;


%%%%%%%%%%%% charakterystyka statyczna %%%%%%%%%%%%%
qwe0 = C2*sqrt(0.5*H2);
qwe=qwe0;
q0=qwe;
h10 = (q0/C1).^2;
h20 = (C1/C2).^2*h10;
Q0=0:0.01:5;
H10=(Q0/C1).^2;
H20 = (C1/C2).^2*H10;

h20=0.5*H2;
q0=qwe;
k = 2*sqrt(h20)/C2;
T1 = (2*pi*R1^2*sqrt(h10))/C1;
T2 = (2*A2*B2*sqrt(h20)*h20^2)/(H2*H2*C2);
T3 = 0.3*min(T1,T2);

s = tf('s');
sys=k/((1+T1*s)*(1+T2*s)*(1+T3*s));

kgr = 2.06438;    % Wzmocnienie krytyczne naszego obiektu, zaokraglone.

%% PID wykres i nastawy %%%%%
% %---------------------Dla regulatora PID z metody QDR (laby 4)----------------------------%
% Czasy dla naszego obiektu: 28.3% i 63.2% odpowiedzi skokowej.
% Wyznaczone jak w labie 4, dla siatki czasu 0:0.05:150; 6 cyfr znaczacych.
% k zostaje takie jak obliczone wyzej (w przyblizeniu 6).
t2 = 13.5950;
t1 = 25.3456;
T = 1.5*(t1-t2);
To = t1-T;

kr_PID = 1.2*(T/(k*To));
TI_PID = 2*To;
TD_PID = 0.5*To;
TF_PID = 0.05*TD_PID;       

KPID = kr_PID*(1+(1/(TI_PID*s))+((TD_PID*s)/(TF_PID*s+1)));

Kz_PID = (KPID*sys)/(1+KPID*sys);
Ko_PID = sys*KPID;

K = sys;
Kr = KPID;

tc = 0.01;
tkoniec = 80;

sim('ukl_reg_ciagly.mdl', tkoniec);

figure
subplot(2,1,1)
plot(tout, yt_c)
grid on
title('Wyjście y(t) — regulacja ciągła')

subplot(2,1,2)
plot(ut_c)
grid on
title('Sterowanie u(t) — regulacja ciągła')

Tmax = max([T1,T2,T3]);

h1 = round(0.1*Tmax,2);
h2 = round(0.5*Tmax,2);
h3 = round(Tmax,2);

%% Transmitancja dyskretna obiektu K(s) z ZOH dla h1=0.1*Tmax
Tmax = max([T1,T2,T3]);

z=tf('z',h1);
To_d=To+h1/2;
Kr_PID_d = 1.2*(T/(k*To_d));
TI_PID_d = 2 * To_d;
TD_PID_d = 0.5 * To_d;
TF_PID_d = 0.05 * TD_PID_d;

Hr31 = Kr_PID_d *  (1 + (h1/TI_PID_d * z/(z-1)) + TD_PID_d/h1* ( (z-1) / z ) );
Hr=Hr31;
H=c2d(sys,h1,'zoh');
figure
step(sys,0:0.01:150);
hold on
  [yH,tH]=step(H,150);
  stem(tH,yH,'filled',':g')
hold off
title('Odpowiedz skokowa ukladu otwartego dla h1')
legend('y(t) dla K(s)','y(ih) dla H(z)')
%=====================================================================

%% Transmitancja dyskretna obiektu K(s) z ZOH dla h2=0.5*Tmax

z2=tf('z',h2);
To_d2=To+h2/2;
Kr_PID_d2 = 1.2*(T/(k*To_d2));
TI_PID_d2 = 2 * To_d2;
TD_PID_d2 = 0.5 * To_d2;
TF_PID_d2 = 0.05 * TD_PID_d2;

Hr32 = Kr_PID_d2 *  (1 + (h2/TI_PID_d2 * z2/(z2-1)) + TD_PID_d2/h2* ( (z2-1) / z2 ) );
Hr2=Hr32;
H2=c2d(sys,h2,'zoh');
figure
step(sys,0:0.01:150);
hold on
  [yH2,tH2]=step(H2,150);
  stem(tH2,yH2,'filled',':g')
hold off
title('Odpowiedz skokowa ukladu otwartego  dla h2')
legend('y(t) dla K(s)','y(ih) dla H(z)')
%=====================================================================

%% Transmitancja dyskretna obiektu K(s) z ZOH dla h3=1*Tmax

z3=tf('z',h3);
To_d3=To+h3/2;
Kr_PID_d3 = 1.2*(T/(k*To_d3));
TI_PID_d3 = 2 * To_d3;
TD_PID_d3 = 0.5 * To_d3;
TF_PID_d3 = 0.05 * TD_PID_d3;

Hr33 = Kr_PID_d3 *  (1 + (h3/TI_PID_d3 * z3/(z3-1)) + TD_PID_d3/h3* ( (z3-1) / z3 ) );
Hr3=Hr33;
H3=c2d(sys,h3,'zoh');
figure
step(sys,0:0.01:150);
hold on
  [yH3,tH3]=step(H3,150);
  stem(tH3,yH3,'filled',':g')
hold off
title('Odpowiedz skokowa ukladu otwartego  dla h3')
legend('y(t) dla K(s)','y(ih) dla H(z)')
%=====================================================================

tc=0.01;
tkoniec=200;

%% zad2

%dla metody Hr3 juz mamy z pkt1
Hr34 = Kr_PID_d *  (1 + (1/(TI_PID_d*(2/h1*(z-1)/(z+1)))) + TD_PID_d* (2/h1*(z-1)/(z+1)));                                      %dla metody Hr1
Hr35 = Kr_PID_d *  (1 + (1/(TI_PID_d*(2/h1*(z-1)/(z+1)))) + (TD_PID_d* (2/h1*(z-1)/(z+1)))/(1+TF_PID_d*(2/h1*(z-1)/(z+1))));    %dla metody Hr2
Hr4=Hr34;
Hr5=Hr35;

fprintf('\nPUNKT 0 - h = %.6f s\n', h2);

fprintf('\nNastawy z laboratorium 4:\n');
fprintf('kr = %.6f\n', kr_PID);
fprintf('Ti = %.6f s\n', TI_PID);
fprintf('Td = %.6f s\n', TD_PID);
fprintf('Tf = %.6f s\n', TF_PID);

fprintf('\nNastawy wlasciwe dla h = %.6f s:\n', h2);
fprintf('To_d = %.6f s\n', To_d2);
fprintf('kr = %.6f\n', Kr_PID_d2);
fprintf('Ti = %.6f s\n', TI_PID_d2);
fprintf('Td = %.6f s\n', TD_PID_d2);


%% Punkt 0 - nastawy z regulacji ciaglej dla h2
Hr2 = kr_PID * (1 + h2/TI_PID*z2/(z2-1) ...
                   + TD_PID/h2*(z2-1)/z2);

sim('ukl_reg_dysk.mdl',tkoniec)

[y_ciagly,t_ciagly] = step(Kz_PID,0:tc:tkoniec);

figure('Color','w','Position',[100 100 1200 750])
tiledlayout(2,1,'TileSpacing','compact','Padding','compact')

nexttile
hold on
p1 = plot(tout,yt_d1,'b','LineWidth',1.8);
p2 = stem(yih1.time,yih1.signals.values, ...
    ':b','filled','MarkerSize',5);
p3 = plot(t_ciagly,y_ciagly,'r--','LineWidth',1.8);
hold off

grid on
ylim('auto')
xlim([0 tkoniec])
ylabel('Wyjscie y(t)')
title('Punkt 0 - wyjscie, h = 0.5*Tmax')
legend([p1 p2 p3],{'Dyskretny','Probki','Ciagly'}, ...
    'Location','best')

nexttile
hold on
p1 = stairs(ut_d1.Time,ut_d1.Data,'b','LineWidth',1.8);
p2 = plot(ut_c.Time,ut_c.Data,'r--','LineWidth',1.8);
hold off

grid on
xlim([0 tkoniec])
xlabel('Czas [s]')
ylabel('Sterowanie u(t)')
title('Punkt 0 - sterowanie, h = 0.5*Tmax')
legend([p1 p2],{'Dyskretny','Ciagly'},'Location','best')

set(findall(gcf,'Type','axes'), ...
    'Color','w','XColor','k','YColor','k','FontSize',12)
set(findall(gcf,'Type','text'),'Color','k')
set(findall(gcf,'Type','legend'), ...
    'Color','w','TextColor','k','EdgeColor','k')

figure
subplot(2,1,1)
    hold on
    plot(tout,yt_d1,'g');
    stem(yih1.time,yih1.signals.values,'filled',':g');
    step(Kz_PID,tkoniec,'k');
    hold off
grid on
title('Punkt 0 - wyjscie y(t), h = 0.5*Tmax')
legend('Dyskretny','Probki','Ciagly')

subplot(2,1,2)
    hold on
    plot(ut_d1,'g');
    plot(ut_c,'k');
    hold off
grid on
title('Punkt 0 - sterowanie u(t), h = 0.5*Tmax')
legend('Dyskretny','Ciagly')

Hr2 = Hr32;


sim('ukl_reg_dysk.mdl',tkoniec)


%% Rysunki dla pkt1
figure
subplot(2,1,1)
    hold on
    plot(tout,yt_d,'g');
    stem(yih.time,yih.signals.values,'filled',':g');
    plot(tout,yt_d1,'b');
    stem(yih1.time,yih1.signals.values,'filled',':b');
    plot(tout,yt_d2,'r');
    stem(yih2.time,yih2.signals.values,'filled',':r');
    step(Kz_PID, 80, 'k');
    hold off
title('Odpowiedz skokowa ukladu zamknietego')
legend('y1(t) - wyjscie obiektu','y1(ih1) - probki',    'y2(t) - wyjscie obiektu','y2(ih2) - probki',    'y3(t) - wyjscie obiektu','y3(ih3) - probki',   'uklad ciagly');

subplot(2,1,2)
    hold on
    plot(ut_d,'g');     %Dla Structure with Time: stairs(ut_d.time,ut_d.signals.values,'b')
    plot(ut_d1,'b');
    plot(ut_d2,'r');
    hold off
title('Sterowanie u(t)')
legend('u(t) dla h1', 'u(t) dla h2', 'u(t) dla h3')

%Wyswietlane nastawy dla poszczegolnych okresow probkowania
X_h1 = sprintf('Dla h1: \nkr: %f \nTi: %f \nTd: %f \nTf: %f\n',Kr_PID_d, TI_PID_d, TD_PID_d, TF_PID_d);
disp(X_h1)

X_h2 = sprintf('Dla h2: \nkr: %f \nTi: %f \nTd: %f \nTf: %f\n',Kr_PID_d2, TI_PID_d2, TD_PID_d2, TF_PID_d2);
disp(X_h2)

X_h3 = sprintf('Dla h3: \nkr: %f \nTi: %f \nTd: %f \nTf: %f\n',Kr_PID_d3, TI_PID_d3, TD_PID_d3, TF_PID_d3);
disp(X_h3)



%% Rysunki dla pkt2
figure (21)
    hold on
    plot(tout,yt_d3,'b');
    stem(yih3.time,yih3.signals.values,'filled',':b');
    plot(tout,yt_d4,'r');
    stem(yih4.time,yih4.signals.values,'filled',':r');
    plot(tout,yt_d,'g');
    stem(yih.time,yih.signals.values,'filled',':g');
    step(Kz_PID, 80, 'k');
    hold off
title('Odpowiedz skokowa ukladu zamknietego')
legend('y2(t) - dla Hr1','y2(ih1) - probki dla Hr1',    'y3(t) - dla Hr2','y3(ih1) - probki dla Hr2',   'y1(t) - dla Hr3','y1(ih1) - probki dla Hr3', 'uklad ciagly');

figure (22)
    hold on
    plot(ut_d3,'b');    %Dla Structure with Time: stairs(ut_d.time,ut_d.signals.values,'b')
    plot(ut_d4,'r');
    plot(ut_d,'g');
    hold off
title('Sterowanie u(t)')
legend('u(t) dla Hr1', 'u(t) dla Hr2', 'u(t) dla Hr3')
