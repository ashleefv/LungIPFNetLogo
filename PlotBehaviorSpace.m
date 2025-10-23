clear all
close all

%% All the patients tested
ResultsPath = {"BehaviorSpaceResults\Results-V101T03-279-A1-101525","BehaviorSpaceResults\Results-V101T03-279-C1-101525","BehaviorSpaceResults\Results-V101T03-279-D1-101525"};
ResultsString = {"A1","C1","D1"};
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

ReporterLabels = {'total world collagen', 'percent pixel collagen', 'number of fibroblasts', 'number of myofibroblasts', 'max pixel collagen'};
for i = 2:numReporters
    figure(1)
    subplot(length(ResultsPath),numReporters-1,(z-1)*(numReporters-1) + (i-1));
    ReporterNumber = i;
    reporterValues = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber};
    % should add legend with DisplayName across runs
    plot(time,reporterValues)
    xlim([xmin xmax])
    xlabel('Time (weeks)');
    ylabel(ReporterLabels{i-1})
    if i == 2;
        text(-0.3, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
    end
end
% 
%% Process the experimental conditions
RunParams{:,1};
for rowIndex = 2:numRunParams+1
    % Extract the row as a cell array
    rowData = table2array(RunParams(rowIndex, 2:end));

    % Find unique values in the row
    uniqueValues = unique(rowData);

    % Display results
    disp(strjoin(['Unique values in row'  num2str(rowIndex) 'for' string(RunParams{rowIndex,1})]))
    disp(uniqueValues);

    if rowIndex == 5;
        numReps = length(uniqueValues);
    end
end
treatmentLabel = {" treatment: pentox off, pirf off", " treatment: pentox off, pirf on", " treatment: pentox on, pirf off", " treatment: pentox on, pirf on"};
for rowIndex = 2    
    % Extract the row as a cell array
    rowData = table2array(RunParams(rowIndex, 2:end));

    % Find unique values in the row
    uniqueValues = unique(rowData);

    for i = 2:numReporters
        ReporterNumber = i;
        for k = 1:length(uniqueValues)
            figure(1+(i-1))
            subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            hold on
            matchingIndices = find(ismember(rowData,uniqueValues(k) ) );
            reporterValues = RunData{:,(matchingIndices-1)*numReporters+ReporterNumber};
            plot(time,reporterValues)
            xlim([xmin xmax])
            xlabel('Time (weeks)')
            ylabel(ReporterLabels{i-1})
            title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
            %legend('-DynamicLegend');
            if k == 1;
                text(-0.5, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
            end
            hold off

            figure((numReporters-1) + i)
            subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            hold on

            % statistics on replicates. Using the known structure of the
            % data with the replicates being sequential

            numTreatments = size(reporterValues,2)/numReps;
            mean_reporterValues = zeros(size(reporterValues,1),numTreatments);
            std_reporterValues = zeros(size(reporterValues,1),numTreatments);
            co = orderedcolors("gem");
            for m = 1:numTreatments              
                indices = (m-1)*(numReps)+[1:numReps];
                mean_reporterValues(:,m) = mean(reporterValues(:,indices),2);
                std_reporterValues(:,m) = std(reporterValues(:,indices),0,2);
                % Plot mean curve
                meanHandles(m) = plot(time, mean_reporterValues(:,m), 'color', co(m,:), 'LineWidth', 3,'DisplayName',strcat('Mean of ', string(treatmentLabel(m))));
                xlim([xmin xmax])
            end
            legend(meanHandles, 'Location', 'best');
            for m = 1:numTreatments   
                indices = (m-1)*(numReps)+[1:numReps];
                plot(time,reporterValues(:,indices),'color', co(m,:), 'LineWidth', 0.5,'HandleVisibility', 'off');
                xlim([xmin xmax])
            end

            % Labels and formatting
            xlabel('Time (weeks)');
            ylabel(ReporterLabels{i-1})

            title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
            if k == 1;
                text(-0.5, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
            end
            hold off

            if i == 2 || i == 3 || i == 6 % don't make bar graphs for final numbers of fibroblasts or myofibroblasts
                figure(2*(numReporters-1) + i)
                subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
                hold on
                y = mean_reporterValues(end,:);
                barError = std_reporterValues(end,:);
    
                b = bar(y);
                hold on
                x = b.XData;
        
                % Get the default color order
                colors = get(gca, 'ColorOrder');
                numColors = size(colors, 1);
    
                % Set each bar to a different color from the color order
                for s = 1:length(y)
                    b.FaceColor = 'flat';         % Enable individual coloring
                    b.CData(s,:) = colors(mod(s-1, numColors)+1, :);
                end
    
    
                % Set custom x-axis labels
                xticks(x);
                xticklabels(treatmentLabel);
                xtickangle(45);  % Optional: rotate labels for readability
                ylabel(ReporterLabels{i-1} + " after 52 weeks")
                title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
    
                errorbar(x,y,barError,'k', 'linestyle', 'none')
                if k == 1;
                    text(-0.5, 0.5, string(ResultsString(z)), 'Units', 'normalized', 'FontWeight', 'Normal')
                end
                hold off
            end
        end
    end
end


end
% % Get handles to all open figures
% figHandles = findall(0, 'Type', 'figure');
% 
% % Loop through and save each as a .fig file
% for i = 1:length(figHandles)
%     savefig(figHandles(i), sprintf('Figure_%d.fig', i));
% end