% =========================================================================
% FERRAMENTA COMPUTACIONAL PARA PROJETO DE CROSSOVER PASSIVO DE 2A ORDEM
% -------------------------------------------------------------------------
% Curso:    Circuitos de Corrente Alternada - CC44CP
% Aluno:    Alanderson Sousa Lopes
% Prof.:    Prof. Dionatan Cieslak, Dr. Eng.
% =========================================================================

% --- PREPARAÇÃO DO AMBIENTE ---
% Limpa a tela de comando, as variáveis e fecha todas as figuras abertas
clear;
clc;
close all;

% =========================================================================
% ETAPA 1: DEFINIÇÃO DOS PARÂMETROS E COMPONENTES
% =========================================================================
fprintf('Iniciando o projeto do crossover...\n\n');

% --- Parâmetros de Projeto do Aluno ---
% Valores especificados na tabela do trabalho
R_L = 8.0;      % Impedância de Carga (Ohm)
f_c = 2000.0;   % Frequência de Corte (Hz)
W_c = 2 * pi * f_c; % Conversão para frequência de corte angular (rad/s)

fprintf('Parâmetros de Entrada:\n');
fprintf('  - Impedância de Carga (R_L): %.1f Ohm\n', R_L);
fprintf('  - Frequência de Corte (f_c): %.1f kHz\n\n', f_c/1000);

% --- Listas de Componentes Comerciais Disponíveis ---
% Os valores das tabelas são armazenados em vetores.
% Tabela de Capacitores Comerciais (em Farads)
C_comercial = [
    1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2, ...
    10, 12, 15, 18, 22, 27, 33, 39, 47, 56, 68, 82, 100
] * 1e-6; % Multiplica por 1e-6 para converter de uF para F

% Tabela de Indutores Comerciais (em Henrys)
L_comercial = [
    0.10, 0.12, 0.15, 0.18, 0.22, 0.27, 0.33, 0.39, 0.47, 0.56, ...
    0.68, 0.82, 1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, ...
    6.8, 8.2, 10, 12, 15
] * 1e-3; % Multiplica por 1e-3 para converter de mH para H

% =========================================================================
% ETAPA 2: CÁLCULO DOS VALORES IDEAIS E SELEÇÃO DOS REAIS
% =========================================================================
fprintf('-------------------------------------------------------------\n');
fprintf('RESULTADOS DO CÁLCULO E SELEÇÃO DE COMPONENTES\n');
fprintf('-------------------------------------------------------------\n\n');

% --- Filtro Passa-Baixas (LPF) para o Woofer ---
% a. Cálculo dos valores ideais de L e C para o LPF
L_lpf_ideal = (R_L * sqrt(2)) / W_c;
C_lpf_ideal = sqrt(2) / (R_L * W_c);

% b. Sugestão dos componentes reais mais próximos para o LPF
[~, idx_L] = min(abs(L_comercial - L_lpf_ideal)); % Encontra o índice do valor mais próximo
L_lpf_real = L_comercial(idx_L);

[~, idx_C] = min(abs(C_comercial - C_lpf_ideal));
C_lpf_real = C_comercial(idx_C);

% Exibe os resultados do LPF
fprintf('Filtro Passa-Baixas (LPF):\n');
fprintf('  - Indutor:   Ideal = %.3f mH  ->  Real Escolhido: %.2f mH\n', L_lpf_ideal*1000, L_lpf_real*1000);
fprintf('  - Capacitor: Ideal = %.2f uF  ->  Real Escolhido: %.2f uF\n\n', C_lpf_ideal*1e6, C_lpf_real*1e6);

% --- Filtro Passa-Altas (HPF) para o Tweeter ---
% a. Cálculo dos valores ideais de L e C para o HPF
C_hpf_ideal = 1 / (W_c * R_L * sqrt(2));
L_hpf_ideal = R_L / (W_c * sqrt(2));

% b. Sugestão dos componentes reais mais próximos para o HPF
[~, idx_C] = min(abs(C_comercial - C_hpf_ideal));
C_hpf_real = C_comercial(idx_C);

[~, idx_L] = min(abs(L_comercial - L_hpf_ideal));
L_hpf_real = L_comercial(idx_L);

% Exibe os resultados do HPF
fprintf('Filtro Passa-Altas (HPF):\n');
fprintf('  - Capacitor: Ideal = %.2f uF  ->  Real Escolhido: %.2f uF\n', C_hpf_ideal*1e6, C_hpf_real*1e6);
fprintf('  - Indutor:   Ideal = %.3f mH  ->  Real Escolhido: %.2f mH\n\n', L_hpf_ideal*1000, L_hpf_real*1000);

% =========================================================================
% ETAPA 3: GERAÇÃO DOS GRÁFICOS DE BODE COMPARATIVOS
% =========================================================================

% --- Gráfico de Bode para o Filtro Passa-Baixas (LPF) ---
figure('Name', 'Análise do Filtro Passa-Baixas (LPF)'); % Cria uma nova janela para a figura

% Define o filtro LPF ideal de 2ª ordem Butterworth
[num_ideal_lpf, den_ideal_lpf] = butter(2, W_c, 'low', 's');
lpf_ideal = tf(num_ideal_lpf, den_ideal_lpf);

% Define o filtro LPF real com base nos componentes comerciais
% A função de transferência para este circuito é: H(s) = (1/LC) / (s^2 + s/(RC) + 1/LC)
num_real_lpf = [1 / (L_lpf_real * C_lpf_real)];
den_real_lpf = [1, 1 / (R_L * C_lpf_real), 1 / (L_lpf_real * C_lpf_real)];
lpf_real = tf(num_real_lpf, den_real_lpf);

% Configurações de plotagem
opt = bodeoptions;
opt.Title.String = 'Gráfico de Bode Comparativo - LPF';
opt.Grid = 'on';

% Plota as duas respostas no mesmo gráfico
bode(lpf_ideal, 'b--', lpf_real, 'r-', opt); % Ideal: azul tracejado; Real: vermelho sólido
legend('Resposta Ideal', 'Resposta Real (Componentes Comerciais)', 'Location', 'southwest');


% --- Gráfico de Bode para o Filtro Passa-Altas (HPF) ---
figure('Name', 'Análise do Filtro Passa-Altas (HPF)'); % Cria uma nova janela para a figura

% Define o filtro HPF ideal de 2ª ordem Butterworth
[num_ideal_hpf, den_ideal_hpf] = butter(2, W_c, 'high', 's');
hpf_ideal = tf(num_ideal_hpf, den_ideal_hpf);

% Define o filtro HPF real com base nos componentes comerciais
% A função de transferência para este circuito é: H(s) = s^2 / (s^2 + s/(RC) + 1/LC)
num_real_hpf = [1, 0, 0];
den_real_hpf = [1, 1 / (R_L * C_hpf_real), 1 / (L_hpf_real * C_hpf_real)];
hpf_real = tf(num_real_hpf, den_real_hpf);

% Configurações de plotagem
opt.Title.String = 'Gráfico de Bode Comparativo - HPF';

% Plota as duas respostas no mesmo gráfico
bode(hpf_ideal, 'b--', hpf_real, 'r-', opt);
legend('Resposta Ideal', 'Resposta Real (Componentes Comerciais)', 'Location', 'southwest');

fprintf('-------------------------------------------------------------\n');
fprintf('Gráficos de Bode gerados com sucesso.\n');
fprintf('-------------------------------------------------------------\n');
