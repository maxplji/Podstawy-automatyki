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

qwe = 0.5;
q0 = qwe;
pp = 0.5;
h10 = q0*q0 / (C1*C1);
h20 = (q0./C2).^2 ;

Q = 0:0.01: 0.8;

H10 = (Q./C1).^2;
H20 = (Q./C2).^2;

figure;
plot(Q, H10, 'b', Q, H20, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Q');
ylabel('H');
title('Charakterystyka statyczna');
legend('H_1(Q)', 'H_2(Q)', 'Location', 'northwest');

out = sim('walec_ostroslup_simulink.slx');

figure;
plot(out.qwy.time, out.qwy.data);
grid on;
xlabel('x');
ylabel('y');
title('qwy');
