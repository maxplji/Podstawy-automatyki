clc;
clear;
close all;

C1 = 1.0847;
C2 = 0.263067;

H1 = 1 ;
H2 = 10;


%charakterystyka statyczna
qwe = 0.5;
q0 = qwe;
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