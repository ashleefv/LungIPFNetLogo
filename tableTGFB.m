% Read CSV file
filename = 'uptake.csv';
data = readtable(filename);

% Extract step values
steps = data.x_step_; 

% Automatically detect collagen and TGF-beta columns
collagen_columns = startsWith(data.Properties.VariableNames, 'world_collagen');
tgfbeta_columns = startsWith(data.Properties.VariableNames, 'world_TGFbeta');

% Extract relevant data
collagen_data = table2array(data(:, collagen_columns));
tgfbeta_data = table2array(data(:, tgfbeta_columns));


% Plot world_collagen and world_TGFbeta

num_collagen = size(collagen_data, 2);
num_tgfb = size(tgfbeta_data, 2);

figure(1)
% Plot collagen data
hold on
for i = 1:num_collagen
    plot(steps, collagen_data(:, i), '-','LineWidth',2,  'DisplayName', ['Collagen ' num2str(i)]);
end
xlabel('Steps');
ylabel('Concentration');
title('Collagen and Collagen Concentration over Steps');
legend;
grid on;
hold off;


figure(2)
% Plot TGF-beta data
hold on
for i = 1:num_tgfb
    plot(steps, tgfbeta_data(:, i), '--','LineWidth',2, 'DisplayName', ['TGFbeta ' num2str(i)]);
end
xlabel('Steps');
ylabel('Concentration');
title('Collagen and TGFbeta Concentration over Steps');
legend;
grid on;
hold off;


