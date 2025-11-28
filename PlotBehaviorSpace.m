clear all
close all
warning('off','all');

%% All the patients tested
ResultsPath = {"BehaviorSpaceResults\Results-V10T03-280-A1-101525","BehaviorSpaceResults\Results-V19S23-092-C1-101525","BehaviorSpaceResults\Results-V10T03-279-D1-101525"};
ResultsString = {"A","C","D"};
for z = 1:length(ResultsPath)
%% read in data for one patient starting world
csv_filename =  string(ResultsPath(z))+'\spreadsheet.csv';
name = readtable(csv_filename,Range = "A3:A4")
numberRuns = 60;
numReporters = 6;
numRunParams = 4;
startCol = "A";
startColIndex = 1;

startRow = "7";
finalRow = num2str(str2num(startRow)+numRunParams);

% csv_filename = 'Exp01.csv';
% numberRuns = 10;
% numReporters = 3;
% startCol = "A";
% startColIndex = 1;
% startRow = "8";
% finalRow = "13";
finalColIndexStart = startColIndex + numberRuns*numReporters;

% Convert to Excel column letter
finalColLetter = '';
finalColIndex = finalColIndexStart;
while finalColIndex > 0
    remainder = mod(finalColIndex - 1, 26);
    finalColLetter = [char(65 + remainder), finalColLetter];
    finalColIndex = floor((finalColIndex - 1) / 26);
end
%disp(['Final column letter: ', finalColLetter])

RunParams = readtable(csv_filename, Range = startCol + startRow + ":" + finalColLetter + finalRow, MissingRule = "omitvar");

startRow = num2str(str2num(finalRow)+1); 
finalRow = num2str(str2num(startRow) + 5);
Reporters = readtable(csv_filename, Range = startCol + startRow + ":" + finalColLetter + finalRow);

startRow = num2str(str2num(finalRow)+2);
finalRow = num2str(str2num(startRow) + max(Reporters{end,2:finalColIndexStart})+1);
RunData = readtable(csv_filename, Range = "B" + startRow + ":" + finalColLetter + finalRow);

%% Bulk plots
ReporterNumber = 1;
timesteps = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber}./(24*7); % in weeks
% assuming that all time vectors are identical
time = timesteps(:,1); % in weeks
xmin = min(min(time));
xmax = max(max(time));

% Define line styles in the desired sequence
lineStyles = {'-', '--', '-.', ':'};
Replicates = 3;
TreatmentGroups = 4;
colorCycling = Replicates*TreatmentGroups ;
fig1Colors = [
    [124 80 164]/255; % purple
    0.2 0.4 0.8;        % dark blue
    1.0 0.8 0.0;        % gold
    1.0 0.4 0.0;        % dark orange
    0.8 0.0 0.0;        % red
];

ReporterLabels = {'total world collagen', '% pixel collagen', 'fibroblasts', 'myofibroblasts', 'max pixel collagen'};
for i = 2:numReporters
    figure(1)
    subplot(length(ResultsPath),numReporters-1,(z-1)*(numReporters-1) + (i-1));
    ReporterNumber = i;
    reporterValues = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber};
    % should add legend with DisplayName across runs
    
    for r = 1:numberRuns
        % Determine which line style to use
        styleIndex = mod(floor((r-1)/Replicates), length(lineStyles)) + 1;
        currentStyle = lineStyles{styleIndex};


        % Determine color (change every 12 runs)
        colorIndex = floor((r-1)/colorCycling) + 1;
        currentColor = fig1Colors(colorIndex, :);

    
        % Plot each run with its style
        plot(time, reporterValues(:, r), 'LineStyle', currentStyle,'Color', currentColor);
        
        hold on;
    end
    hold off;

    xlim([xmin xmax])
    xlabel('Time (weeks)');
    ylabel(ReporterLabels{i-1})

end

% 
% %% Process the experimental conditions
% RunParams{:,1};
% for rowIndex = 2:numRunParams+1
%     % Extract the row as a cell array
%     rowData = table2array(RunParams(rowIndex, 2:end));
% 
%     % Find unique values in the row
%     uniqueValues = unique(rowData);
% 
%     % Display results
%     disp(strjoin(['Unique values in row'  num2str(rowIndex) 'for' string(RunParams{rowIndex,1})]))
%     disp(uniqueValues);
% 
%     if rowIndex == 5;
%         numReps = length(uniqueValues);
%     end
% end
% treatmentLabel = {" treatment: none", " treatment: pirf", " treatment: pentox", " treatment: pentox and pirf"};
% for rowIndex = 2    
%     % Extract the row as a cell array
%     rowData = table2array(RunParams(rowIndex, 2:end));
% 
%     % Find unique values in the row
%     uniqueValues = unique(rowData);
% 
%     for i = [2 3 numReporters]% 2:numReporters; don't further process final numbers of fibroblasts or myofibroblasts
%         ReporterNumber = i;
%         for k = 1:length(uniqueValues)
%             figure(1+(i-1))
%             subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
%             hold on
%             matchingIndices = find(ismember(rowData,uniqueValues(k) ) );
%             reporterValues = RunData{:,(matchingIndices-1)*numReporters+ReporterNumber};
%             plot(time,reporterValues)
%             xlim([xmin xmax])
%             xlabel('Time (weeks)')
%             ylabel(ReporterLabels{i-1})
%             title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
%             %legend('-DynamicLegend');
%             if k == 1;
%                 text(-0.5, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
%             end
%             hold off
% 
%             figure((numReporters-1) + i)
%             subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
%             hold on
% 
%             % statistics on replicates. Using the known structure of the
%             % data with the replicates being sequential
% 
%             numTreatments = size(reporterValues,2)/numReps;
%             mean_reporterValues = zeros(size(reporterValues,1),numTreatments);
%             std_reporterValues = zeros(size(reporterValues,1),numTreatments);
%             co = orderedcolors("gem");
%             for m = 1:numTreatments              
%                 indices = (m-1)*(numReps)+[1:numReps];
%                 mean_reporterValues(:,m) = mean(reporterValues(:,indices),2);
%                 std_reporterValues(:,m) = std(reporterValues(:,indices),0,2);
%                 % Plot mean curve
%                 meanHandles(m) = plot(time, mean_reporterValues(:,m), 'color', co(m,:), 'LineWidth', 3,'DisplayName',strcat('Mean of ', string(treatmentLabel(m))));
%                 xlim([xmin xmax])
%             end
%             legend(meanHandles, 'Location', 'best');
%             for m = 1:numTreatments   
%                 indices = (m-1)*(numReps)+[1:numReps];
%                 plot(time,reporterValues(:,indices),'color', co(m,:), 'LineWidth', 0.5,'HandleVisibility', 'off');
%                 xlim([xmin xmax])
%             end
% 
%             % Labels and formatting
%             xlabel('Time (weeks)');
%             ylabel(ReporterLabels{i-1})
% 
%             title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
%             if k == 1;
%                 text(-0.5, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
%             end
%             hold off
% 
%                 figure(2*(numReporters-1) + i)
%                 subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
%                 hold on
%                 y = mean_reporterValues(end,:);
%                 barError = std_reporterValues(end,:);
% 
%                 b = bar(y);
%                 hold on
%                 x = b.XData;
% 
%                 % Get the default color order
%                 colors = get(gca, 'ColorOrder');
%                 numColors = size(colors, 1);
% 
%                 % Set each bar to a different color from the color order
%                 for s = 1:length(y)
%                     b.FaceColor = 'flat';         % Enable individual coloring
%                     b.CData(s,:) = colors(mod(s-1, numColors)+1, :);
%                 end
% 
% 
%                 % Set custom x-axis labels
%                 xticks(x);
%                 xticklabels(treatmentLabel);
%                 xtickangle(45);  % Optional: rotate labels for readability
%                 ylabel(ReporterLabels{i-1} + " after 52 weeks")
%                 title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
% 
%                 errorbar(x,y,barError,'k', 'linestyle', 'none')
%                 if k == 1;
%                     text(-0.5, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
%                 end
%                 hold off
%         end
%     end
% end


end

figure(1)
hold on


% Get handle to all axes created by subplot
allAxes = findall(gcf, 'Type', 'axes');

% Apply font size to each subplot
for k = 1:length(allAxes)
    set(allAxes(k), 'FontSize', 8);
end


% Sort them in the order they were created (subplot order)
allAxes = flipud(allAxes);  % MATLAB stores them in reverse order

% Get Y-limits from the 5th panel
yLimitsPanel5 = ylim(allAxes(5));

% Apply same limits to panels 10 and 15
ylim(allAxes(10), yLimitsPanel5);
ylim(allAxes(15), yLimitsPanel5);

% Create an invisible axes that spans the whole figure
axLegend = axes('Position',[0 0 1 1],'Visible','off');
hold(axLegend, 'on');

% --- Color Legend ---
colorLabels = {'ifc = 20', 'ifc = 40', 'ifc = 60', 'ifc = 80', 'ifc = 100'};
colorHandles = gobjects(length(fig1Colors),1);
for c = 1:length(fig1Colors)
    colorHandles(c) = plot(axLegend, nan, nan, '-', 'Color', fig1Colors(c,:), 'LineWidth', 2);
end

% --- Line Style Legend ---
styleLabels = {"none","pirf","pentox","pentox & pirf"};
styleHandles = gobjects(length(lineStyles),1);
for s = 1:length(lineStyles)
    styleHandles(s) = plot(axLegend, nan, nan, lineStyles{s}, 'Color', [0 0 0], 'LineWidth', 2);
end

% Combine handles: colors first, then styles
allHandles = [colorHandles; styleHandles];

% Make labels a uniform string array (avoids mixed-type cell issues)
labels = [string(colorLabels), string(styleLabels)];

% Create combined legend at bottom of the entire figure (target the legend axes explicitly)
lgd = legend(axLegend, allHandles, labels, ...
    'Orientation', 'horizontal', 'Location', 'southoutside','Fontsize',8);
%lgd.Title.String = 'Color = IFC | Line Style = 52-week treatment';
lgd.Box = 'off';

% Force two rows: first row = colors, second row = styles
lgd.NumColumns = max(length(colorHandles), length(styleHandles));

cols = numReporters-1;
for r = 1:3
    % Find the first subplot in this row
    idx = (r-1)*cols + 1;
    ax = allAxes(idx);

    % Add text to the left side of the row
    text(ax, -0.6, 0.5, ResultsString(r), ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 8);

end



figname = strcat('PlotBSAll');
%saveas(gcf,strcat(figname, '.png'));

fig= gcf;

% Adjust based on figure's aspect ratio
widthInches = 7.5;
heightInches = 5;

% Get current size in inches
figPos = get(fig, 'Position');
set(fig, 'Units', 'Inches');



% Set figure size
set(fig, 'Position', [1, 1, widthInches, heightInches]);
set(fig, 'PaperUnits', 'Inches');
set(fig, 'PaperSize', [widthInches, heightInches]);
figPos = get(fig, 'Position');
set(fig, 'PaperPositionMode', 'manual');
fig = gcf;

%figname = 'test';
exportgraphics(fig,strcat(figname, '.png'),'Resolution',600)


% % Get handles to all open figures
% figHandles = findall(0, 'Type', 'figure');
% 
% % Loop through and save each as a .fig file
% for i = 1:length(figHandles)
%     savefig(figHandles(i), sprintf('Figure_%d.fig', i));
% end

warning('on', 'all')