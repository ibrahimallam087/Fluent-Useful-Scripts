% Read data from the file
clc
clear 
close all

filename = 'mass-balance-rfile.out';
fileID = fopen(filename, 'r');

% Skip the first three lines of the file (header)
for i = 1:3
    fgetl(fileID);
end

% Read the numerical data
data = fscanf(fileID, '%f %f %f', [3 Inf]);
fclose(fileID);

% Transpose data for easier handling
data = data';

% Extract columns
time_step = data(:, 1);
mass_balance = data(:, 2);
flow_time = data(:, 3);


zero_crossing_inecies = find(mass_balance==0)
% Plot 1: Flow time vs Mass balance
figure;
subplot(2, 1, 1);
plot(flow_time, mass_balance, 'b', 'LineWidth', 1.5);
xlabel('Flow Time (s)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Mass Balance', 'Interpreter', 'latex', 'FontSize', 14);
title('Flow Time vs Mass Balance', 'Interpreter', 'latex', 'FontSize', 16);
grid on;

% Plot 2: Time step vs Mass balance
subplot(2, 1, 2);
plot(time_step, mass_balance, 'r', 'LineWidth', 1.5);
xlabel('Time Step', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Mass Balance', 'Interpreter', 'latex', 'FontSize', 14);
title('Time Step vs Mass Balance', 'Interpreter', 'latex', 'FontSize', 16);
grid on;

% Adjust figure properties
sgtitle('Mass Balance Plots', 'Interpreter', 'latex', 'FontSize', 18);
