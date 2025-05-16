
clear all; close all;
% List of CSV filenames
files_both = {
    'PatchesRun1Both.csv',
    'PatchesRun2Both.csv'
};

files_pirf = {
    'PatchesRun1Pirf.csv',
    };
% Initialize vector to store total collagen per run
numRuns_both = numel(files_both);
totals_both = zeros(1, numRuns_both);

numRuns_pirf= numel(files_pirf);
totals_pirf = zeros(1, numRuns_pirf);
% Loop through each file
for i = 1:numRuns_both
    data = readtable(files_both{i});
    totals_both(i) = sum(data.total_patch_collagen, 'omitnan');
   
end

for i = 1:numRuns_pirf
    data = readtable(files_pirf{i});
    totals_pirf(i) = sum(data.total_patch_collagen, 'omitnan');
   
end

% Compute average
avgTotal_both = mean(totals_both);
avgTotal_pirf = mean(totals_pirf);

% % Append average as an extra bar
% totalsWithAvg = [totals, avgTotal];

% Create labels for x-axis
labels = {"Both","Pirf only"};

% Plot bar chart
figure;
bar([avgTotal_both,avgTotal_pirf]);
%bar(avgTotal_pirf);
set(gca, 'XTickLabel', labels);
title('Total Patch Collagen Across Runs with Average');
ylabel('Total Patch Collagen');
grid on;





