clear all
close all
warning('off','all');

%% All the patients tested
%ResultsPath = {"BehaviorSpaceResults\Results-V10T31-019-A1-080326","BehaviorSpaceResults\Results-V10T31-015-C1-080326","BehaviorSpaceResults\Results-V10T31-015-D1-080326"};
ResultsPath = {"BehaviorSpaceResults\Results-V10T31-019-A1-080826-10Reps","BehaviorSpaceResults\Results-V10T31-015-C1-080826-10Reps","BehaviorSpaceResults\Results-V10T31-015-D1-080826-10Reps"};
ResultsString = {"A","C","D"};
numPatches = 101^2;
%Replicates = 3;
Replicates = 10;
numberRuns = Replicates*20;
numReporters = 6;
numRunParams = 4;
storeY = zeros(5,length(ResultsPath),numReporters,numRunParams,Replicates); %k ifc index, z case index, i reporter index,  m treatment number,: rep
for z = 1:length(ResultsPath)
%% read in data for one patient starting world
csv_filename =  string(ResultsPath(z))+'\spreadsheet.csv';
name = readtable(csv_filename,Range = "A3:A4")

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
size(RunParams);

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

TreatmentGroups = 4;
colorCycling = Replicates*TreatmentGroups;
figColors = [
    [124 80 164]/255; % purple
    0.2 0.4 0.8;        % dark blue
    1.0 0.8 0.0;        % gold
    1.0 0.4 0.0;        % dark orange
    0.8 0.0 0.0;        % red
];

plotOrder = [4 5 2 3 6];
ReporterLabels = {'total collagen', '% collagen', 'fibroblasts', 'myofibroblasts', 'max collagen'};
for p = 1:length(plotOrder)
    i = plotOrder(p);
    figure(1)
    subplot(length(ResultsPath),numReporters-1,(z-1)*(numReporters-1) + p);
    ReporterNumber = i;
    reporterValues = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber};
    % should add legend with DisplayName across runs
    
    for r = 1:numberRuns
        % Determine which line style to use
        styleIndex = mod(floor((r-1)/Replicates), length(lineStyles)) + 1;
        currentStyle = lineStyles{styleIndex};

        % Determine color (change every 12 runs)
        colorIndex = floor((r-1)/colorCycling) + 1;
        currentColor = figColors(colorIndex, :);
        size(reporterValues);
    
        % Plot each run with its style
        plot(time, reporterValues(:, r), 'LineStyle', currentStyle,'Color', currentColor, 'LineWidth', 0.5);

        % diagnosing which D cases have 1 fibroblast remaining at 52 weeks
        % if i ==5 && z ==3
        %     if reporterValues(end, r) == 59
        %         r
        %     end
        % end
        hold on;
    end
    hold off;

    xlim([xmin xmax])
    if i == 5
        yticks(0:20:100)
        set(gca,'XGrid','off','YGrid','on')
    end
    % if i == 3
    %     if z == 1
    %         ylim = [20, 35];
    %     elseif z == 2
    %         ylim = [40, 55];
    %     elseif z == 3
    %         ylim = [65, 80];
    %     end
    % end
    xlabel('Time (weeks)');
    ylabel(ReporterLabels{i-1})

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

    if rowIndex == 5
        numReps = length(uniqueValues);
    end
end
treatmentLabel = {"untreated", "pirf", "pentox", "     pentox & pirf"};
for rowIndex = 2    
    % Extract the row as a cell array
    rowData = table2array(RunParams(rowIndex, 2:end));

    % Find unique values in the row
    uniqueValues = unique(rowData);

    for i = [2 3 numReporters]% 2:numReporters; don't further process final numbers of fibroblasts or myofibroblasts
        ReporterNumber = i;
        for k = 1:length(uniqueValues)
            figure(1+(i-1))
            subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            hold on
            % Determine color (change every k value)
            colorIndex = k;
            currentColor = figColors(colorIndex, :);
            matchingIndices = find(ismember(rowData,uniqueValues(k) ) );
            reporterValues = RunData{:,(matchingIndices-1)*numReporters+ReporterNumber};
            for r = 1:Replicates*TreatmentGroups
                % Determine which line style to use
                styleIndex = mod(floor((r-1)/Replicates), length(lineStyles)) + 1;
                currentStyle = lineStyles{styleIndex};
                plot(time,reporterValues(:, r),'LineStyle', currentStyle,'Color', currentColor, 'LineWidth', 0.5)
            end
            if i == 2 % gray constant slopes
                temp = rowData(matchingIndices);
                ifc = temp(1);
                grayColor = [.7 .7 .7];
                X10(1) = reporterValues(1, 1);
                X5(1) = reporterValues(1, Replicates*TreatmentGroups);
                for tt = 2:length(time)
                    X10(tt) = X10(tt-1)+10*ifc;
                    X5(tt) = X5(tt-1)+5*ifc;
                end
                plot(time, X10,'Color',grayColor,'LineStyle','-', 'LineWidth', 0.5)
                plot(time, X5,'Color',grayColor,'LineStyle','-', 'LineWidth', 0.5)
            end
            xlim([xmin xmax])
            xlabel('Time (weeks)')
            ReporterLabels{3-1} = '% collagen';
            ylabel(ReporterLabels{i-1})
            %title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
            hold off
            % if i == 2
            %     figure(5)
            %     subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            %     hold on
            %     % Determine color (change every k value)
            %     colorIndex = k;
            %     currentColor = figColors(colorIndex, :);
            %     matchingIndices = find(ismember(rowData,uniqueValues(k) ) );
            %     reporterValues = RunData{:,(matchingIndices-1)*numReporters+ReporterNumber};
            %     for r = 1:Replicates*TreatmentGroups
            %         % Determine which line style to use
            %         styleIndex = mod(floor((r-1)/Replicates), length(lineStyles)) + 1;
            %         currentStyle = lineStyles{styleIndex};
            %         % plot(time(2:end),(reporterValues(2:end, r)-reporterValues(1:end-1, r))./(time(2:end)-time(1:end-1)),'LineStyle', currentStyle,'Color', currentColor, 'LineWidth', 0.5)
            %         plot(time(2:end),(reporterValues(2:end, r)-reporterValues(1:end-1, r)),'LineStyle', currentStyle,'Color', currentColor, 'LineWidth', 0.5)
            %     end
            %     xlim([xmin xmax])
            %     xlabel('Time (weeks)')
            %     ylabel([ReporterLabels{i-1} ' slope'])                
            % end
            

            % figure((numReporters-1) + i)
            % subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            % hold on
            % 
            % statistics on replicates. Using the known structure of the
            % data with the replicates being sequential

            numTreatments = size(reporterValues,2)/numReps;
            mean_reporterValues = zeros(size(reporterValues,1),numTreatments);
            std_reporterValues = zeros(size(reporterValues,1),numTreatments);
            % % co = orderedcolors("gem");

            for m = 1:numTreatments              
                indices = (m-1)*(numReps)+[1:numReps];
                Delta_mean_reporterValues(:,m) = mean((reporterValues(:,indices)-reporterValues(1,indices)),2);
                Delta_std_reporterValues(:,m) = std((reporterValues(:,indices)-reporterValues(1,indices)),0,2);
                mean_reporterValues(:,m) = mean(reporterValues(:,indices),2);
                std_reporterValues(:,m) = std(reporterValues(:,indices),0,2);
                storeY(k,z,i,m,:) = reporterValues(end,indices);
                % % Plot mean curve
                % styleIndex = m;
                % currentStyle = lineStyles{styleIndex};
                % meanHandles(m) = plot(time, mean_reporterValues(:,m),'LineStyle', currentStyle, 'Color', currentColor, 'LineWidth', 3,'DisplayName',strcat('Mean of ', string(treatmentLabel(m))));
                % xlim([xmin xmax])
            end
            % legend(meanHandles, 'Location', 'best');
            % for m = 1:numTreatments   
            %     indices = (m-1)*(numReps)+[1:numReps];
            %     styleIndex = m;
            %     currentStyle = lineStyles{styleIndex};
            %     plot(time,reporterValues(:,indices),'LineStyle', currentStyle, 'Color', currentColor, 'LineWidth', 0.5,'HandleVisibility', 'off');
            %     xlim([xmin xmax])
            % end
            % 
            % % Labels and formatting
            % xlabel('Time (weeks)');
            % ylabel(ReporterLabels{i-1})
            % 
            % title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
            % hold off
            % 
            figure(2*(numReporters-1) + i)
            subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            hold on
            if i == 3
                y = Delta_mean_reporterValues(end,:);
                barError = Delta_std_reporterValues(end,:);
            else
                y = mean_reporterValues(end,:);
                barError = std_reporterValues(end,:);
            end
              
            % storeY(k,z,i,:) = y;
            b = bar(y, 'FaceColor', 'flat');
            hold on
            x = b.XData;

            numBars = numel(y);
            x = 1:numBars;


            % % Get the default color order
            % colors = get(gca, 'ColorOrder');
            % numColors = size(colors, 1);
            % 
            % % Set each bar to a different color from the color order
            % for s = 1:length(y)
            %     b.FaceColor = 'flat';         % Enable individual coloring
            %     b.CData(s,:) = colors(mod(s-1, numColors)+1, :);
            % end

            % Base color for the treatment group (from your palette)
            % If each subset corresponds to one treatment family, pick its base color.
            % Example: use figColors(k,:) as base color for this subset k
            baseColor = figColors(k, :);    % adjust if you want a different mapping
            
            % Desired intensity factors for bars (1, 0.75, 0.5, 0.25)
            intensity = [1.0, 0.75, 0.5, 0.25];
            
            % Ensure we only use as many factors as bars present
            intensity = intensity(1:numBars);
            
            % --- LIGHTER variant (towards white): c_out = 1 - (1 - c_in)*pct ---
            scaledColors = zeros(numBars, 3);
            for s = 1:numBars
                pct = intensity(s);
                scaledColors(s, :) = 1 - (1 - baseColor) * pct;
            end
            
            % Assign per-bar colors
            b.CData = scaledColors;


            if z == length(ResultsPath)
                % Set custom x-axis labels
                xticks(x);
                xticklabels(treatmentLabel);
                xtickangle(90);  % Optional: rotate labels for readability
            else
                xticks(x);
                xticklabels({});
            end
            if i == 2
                yticks([0:2:10]*1e6)
            elseif i == 3
                %yticks([0 25:10:75])
                yticks([0:3:15])
            else
                yticks(0:2500:12500)
            end
            ReporterLabels{3-1} = "\Delta % collagen";
            ylabel({ReporterLabels{i-1}; " at 52 weeks"})
            %title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))

            errorbar(x,y,barError,'k', 'linestyle', 'none')
            
            if i == 6
                yRange = [0 11566];
                ylim(yRange)%determined later as the max over all panels
                %% ANOVA + Tukey-Kramer

                allData = [];
                groupLabels = [];
                ylimTop = yRange(2);
                for g = 1:4
            
                    temp = squeeze(storeY(k,z,i,g,:));
            
                    allData = [allData; temp(:)];
            
                    groupLabels = [groupLabels;
                                   repmat(g,length(temp),1)];
            
                end
            
                [pAnova,~,stats] = anova1(allData,groupLabels,'off');
            
                if pAnova < 0.05
            
                    results = multcompare(stats,...
                                          'CType','tukey-kramer',...
                                          'Display','off');
            
                    % Keep only comparisons against untreated (group 1)
                    untreatedComparisons = results(results(:,1)==1,:);
                    nSig = sum(untreatedComparisons(:,6) < 0.05);
                    countSig = 0;
                    
                    annotationBottom = 0.78*ylimTop;
                    annotationHeight = 0.18*ylimTop;
            
                    for r = 1:size(untreatedComparisons,1)
            
                        treatment = untreatedComparisons(r,2);
                        pval = untreatedComparisons(r,6);
            
                        if pval < 0.05
                            countSig = countSig + 1;
                            % Significance label
                            if pval < 0.001
                                label = '***';
                            elseif pval < 0.01
                                label = '**';
                            else
                                label = '*';
                            end
            
                            if nSig == 2
                                yPos = annotationBottom + ...
                                    (countSig)*(annotationHeight/(3-1));
                            elseif nSig == 3
                                yPos = annotationBottom + ...
                                    (countSig-1)*(annotationHeight/(nSig-1));
                            end
                            
                            tickHeight = 0.01*ylimTop;
                            
                            % horizontal bar
                            plot([1 treatment], ...
                                 [yPos yPos], ...
                                 'k', ...
                                 'LineWidth',0.75)
                            
                            % left tick
                            plot([1 1], ...
                                 [yPos-tickHeight yPos], ...
                                 'k', ...
                                 'LineWidth',0.75)
                            
                            % right tick
                            plot([treatment treatment], ...
                                 [yPos-tickHeight yPos], ...
                                 'k', ...
                                 'LineWidth',0.75)
                            
                            % significance symbols
                            text(mean([1 treatment]), ...
                                 yPos + 0.01*ylimTop, ...
                                 label, ...
                                 'HorizontalAlignment','center', ...
                                 'FontSize',8)
                        end
            
                    end
            
                end
            
            end

            hold off
            % % %% Deltas
            % figure(3*(numReporters-1) + i)
            % temp = rowData(matchingIndices);
            % ifc = temp(1);
            % subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
            % hold on
            % y = (mean_reporterValues(end,:)-mean_reporterValues(1,:));%/ifc/length(time);
            % %barError = std_reporterValues(end,:);
            % 
            % b = bar(y, 'FaceColor', 'flat');
            % hold on
            % x = b.XData;
            % 
            % numBars = numel(y);
            % x = 1:numBars;
            % 
            % 
            % % % Get the default color order
            % % colors = get(gca, 'ColorOrder');
            % % numColors = size(colors, 1);
            % % 
            % % % Set each bar to a different color from the color order
            % % for s = 1:length(y)
            % %     b.FaceColor = 'flat';         % Enable individual coloring
            % %     b.CData(s,:) = colors(mod(s-1, numColors)+1, :);
            % % end
            % 
            % % Base color for the treatment group (from your palette)
            % % If each subset corresponds to one treatment family, pick its base color.
            % % Example: use figColors(k,:) as base color for this subset k
            % baseColor = figColors(k, :);    % adjust if you want a different mapping
            % 
            % % Desired intensity factors for bars (1, 0.75, 0.5, 0.25)
            % intensity = [1.0, 0.75, 0.5, 0.25];
            % 
            % % Ensure we only use as many factors as bars present
            % intensity = intensity(1:numBars);
            % 
            % % --- LIGHTER variant (towards white): c_out = 1 - (1 - c_in)*pct ---
            % scaledColors = zeros(numBars, 3);
            % for s = 1:numBars
            %     pct = intensity(s);
            %     scaledColors(s, :) = 1 - (1 - baseColor) * pct;
            % end
            % 
            % % Assign per-bar colors
            % b.CData = scaledColors;
            % 
            % 
            % if z == 3
            %     % Set custom x-axis labels
            %     xticks(x);
            %     xticklabels(treatmentLabel);
            %     xtickangle(90);  % Optional: rotate labels for readability
            % else
            %     xticks(x);
            %     xticklabels({});
            % end
            % if i == 2
            %     yticks([0:2:10]*1e6)
            % elseif i == 3
            %     %yticks([0 25:10:75])
            %     yticks([0:3:15])
            % else
            %     yticks([0:2500:12500])
            % end
            % ylabel({"% \Delta"; ReporterLabels{i-1}; " at 52 weeks"})
            % %title(string(RunParams{rowIndex,1})+ ' = ' + num2str(uniqueValues(k)))
            % 
            % %errorbar(x,y,barError,'k', 'linestyle', 'none')
            % hold off
            % 
           
        end
    end


end

     %% Reporter ratio
            figure(20)
            for k = 1:length(uniqueValues)
                matchingIndices = find(ismember(rowData,uniqueValues(k) ) );
                temp = rowData(matchingIndices);
                ifc = temp(1);
                subplot(length(ResultsPath),length(uniqueValues),(z-1)*length(uniqueValues) + k);
                hold on

                for m = 1:4
                    yplot(m) = mean(storeY(k,z,2,m,:)./(storeY(k,z,3,m,:)*numPatches/100));
                    barError(m) = std(storeY(k,z,2,m,:)./(storeY(k,z,3,m,:)*numPatches/100));
                end

    
                b = bar(yplot, 'FaceColor', 'flat');
                hold on
                x = b.XData;
    
                numBars = numel(y);
                x = 1:numBars;

    
                % Base color for the treatment group (from your palette)
                % If each subset corresponds to one treatment family, pick its base color.
                % Example: use figColors(k,:) as base color for this subset k
                baseColor = figColors(k, :);    % adjust if you want a different mapping
    
                % Desired intensity factors for bars (1, 0.75, 0.5, 0.25)
                intensity = [1.0, 0.75, 0.5, 0.25];
    
                % Ensure we only use as many factors as bars present
                intensity = intensity(1:numBars);
    
                % --- LIGHTER variant (towards white): c_out = 1 - (1 - c_in)*pct ---
                scaledColors = zeros(numBars, 3);
                for s = 1:numBars
                    pct = intensity(s);
                    scaledColors(s, :) = 1 - (1 - baseColor) * pct;
                end
    
                % Assign per-bar colors
                b.CData = scaledColors;
                errorbar(x,yplot,barError,'k', 'linestyle', 'none')    
    
                if z == length(ResultsPath)
                    % Set custom x-axis labels
                    xticks(x);
                    xticklabels(treatmentLabel);
                    xtickangle(90);  % Optional: rotate labels for readability
                else
                    xticks(x);
                    xticklabels({});
                end
              
                yticks(0:625:2500) 
                ylabel({"average collagen"; "at 52 weeks"})

                hold off
            end
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

% Fix % collagen A limits
ylim(allAxes(4), [20 80]);
yticks(allAxes(4), 20:15:80);
% Fix % collagen C limits
ylim(allAxes(9), [20 80]);
yticks(allAxes(9), 20:15:80);
% Fix % collagen D limits
ylim(allAxes(14), [20 80]);
yticks(allAxes(14), 20:15:80);

% Create an invisible axes that spans the whole figure
axLegend = axes('Position',[0 0 1 1],'Visible','off');
hold(axLegend, 'on');

% --- Color Legend ---
colorLabels = {'ifc = 20', 'ifc = 40', 'ifc = 60', 'ifc = 80', 'ifc = 100'};
colorHandles = gobjects(length(figColors),1);
for c = 1:length(figColors)
    colorHandles(c) = plot(axLegend, nan, nan, '-', 'Color', figColors(c,:), 'LineWidth', 0.5);
end

% --- Line Style Legend ---
styleLabels = {"untreated","pirf","pentox","pentox & pirf"};
styleHandles = gobjects(length(lineStyles),1);
for s = 1:length(lineStyles)
    styleHandles(s) = plot(axLegend, nan, nan, lineStyles{s}, 'Color', [0 0 0], 'LineWidth', 0.5);
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
for r = 1:length(ResultsPath)
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
exportgraphics(fig,strcat(figname, '.png'),'Resolution',600, 'ContentType', 'vector')

for i = [2 3 numReporters]% 2:numReporters; don't further process final numbers of fibroblasts or myofibroblasts
    figure(1+(i-1))
    hold on

    % Get handle to all axes created by subplot
    allAxes = findall(gcf, 'Type', 'axes');
    
    % Apply font size to each subplot
    for k = 1:length(allAxes)
        set(allAxes(k), 'FontSize', 8);
    end

    % Sort them in the order they were created (subplot order)
    allAxes = flipud(allAxes);  % MATLAB stores them in reverse order
    
  
    if i == 2 
            % Get Y-limits from the 10th panel
            yLimitsPanel10 = ylim(allAxes(10));

        % Apply same limits to all panels
        for k = 1:length(allAxes)
            ylim(allAxes(k), yLimitsPanel10);
        end
    end
    if i == 3
        yLimitsPanel =[20 80];

        % Apply same limits to all panels
        for k = 1:length(allAxes)
            ylim(allAxes(k), yLimitsPanel);
        end
    end
    if i == 6 
        % Get Y-limits from the 3rd panel
        yLimitsPanel = 0;
        for p = 1:15
            yLimitsPanel = max(yLimitsPanel,ylim(allAxes(p)));
        end
        % Apply same limits to all panels
        for k = 1:length(allAxes)
            ylim(allAxes(k), yLimitsPanel);
        end
    end

    % Create an invisible axes that spans the whole figure
    axLegend = axes('Position',[0 0 1 1],'Visible','off');
    hold(axLegend, 'on');
    
    % --- Color Legend ---
    colorLabels = {'ifc = 20', 'ifc = 40', 'ifc = 60', 'ifc = 80', 'ifc = 100'};
    colorHandles = gobjects(length(figColors),1);
    for c = 1:length(figColors)
        colorHandles(c) = plot(axLegend, nan, nan, '-', 'Color', figColors(c,:), 'LineWidth', 0.5);
    end
    
    % --- Line Style Legend ---
    styleLabels = {"untreated","pirf","pentox","pentox & pirf"};
    styleHandles = gobjects(length(lineStyles),1);
    for s = 1:length(lineStyles)
        styleHandles(s) = plot(axLegend, nan, nan, lineStyles{s}, 'Color', [0 0 0], 'LineWidth', 0.5);
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
    for r = 1:length(ResultsPath)
        % Find the first subplot in this row
        idx = (r-1)*cols + 1;
        ax = allAxes(idx);
        if i == 6
        % Add text to the left side of the row
        text(ax, -0.9, 0.5, ResultsString(r), ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 8);
        else
            % Add text to the left side of the row
             text(ax, -0.6, 0.5, ResultsString(r), ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 8);
        end

    
    end

    ReporterLabels{3-1} = 'percent collagen';
    figname = strcat('PlotBSforEachifc',ReporterLabels{i-1});
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
    exportgraphics(fig,strcat(figname, '.png'),'Resolution',600, 'ContentType', 'vector')

    figure(2*(numReporters-1) + i)

    hold on

    % Get handle to all axes created by subplot
    allAxes = findall(gcf, 'Type', 'axes');
    
    % Apply font size to each subplot
    for k = 1:length(allAxes)
        set(allAxes(k), 'FontSize', 8);
    end

    % Sort them in the order they were created (subplot order)
    allAxes = flipud(allAxes);  % MATLAB stores them in reverse order
    
    if i == 2 
            % Get Y-limits from the 10th panel
            yLimitsPanel10 = ylim(allAxes(10));

        % Apply same limits to all panels
        for k = 1:length(allAxes)
            ylim(allAxes(k), yLimitsPanel10);
        end
    end
    if i == 3
        yLimitsPanel =[0 15];

        % Apply same limits to all panels
        for k = 1:length(allAxes)
            ylim(allAxes(k), yLimitsPanel);
        end
    end
    if i == 6 
        % Get Y-limits from the 3rd panel
        yLimitsPanel = 0;
        for p = 1:15
            yLimitsPanel = max(yLimitsPanel,ylim(allAxes(p)));
        end

        % Apply same limits to all panels
        for k = 1:length(allAxes)
            ylim(allAxes(k), yLimitsPanel);
        end
    end

    % Create an invisible axes that spans the whole figure
    axLegend = axes('Position',[0 0 1 1],'Visible','off');
    hold(axLegend, 'on');
    
    % --- Color Legend ---
    colorLabels = {'ifc = 20', 'ifc = 40', 'ifc = 60', 'ifc = 80', 'ifc = 100'};
    colorHandles = gobjects(length(figColors),1);
    for c = 1:length(figColors)
        colorHandles(c) = plot(axLegend, nan, nan, '-', 'Color', figColors(c,:), 'LineWidth', 0.5);
    end
    
  
    
    % Combine handles: colors first, then styles
    allHandles = colorHandles;
    
    % Make labels a uniform string array (avoids mixed-type cell issues)
    labels = string(colorLabels);
    
    % Create combined legend at bottom of the entire figure (target the legend axes explicitly)
    lgd = legend(axLegend, allHandles, labels, ...
        'Orientation', 'horizontal', 'Location', 'southoutside','Fontsize',8);
    %lgd.Title.String = 'Color = IFC | Line Style = 52-week treatment';
    lgd.Box = 'off';

    
    cols = numReporters-1;
    for r = 1:length(ResultsPath)
        % Find the first subplot in this row
        idx = (r-1)*cols + 1;
        ax = allAxes(idx);
        % Add text to the left side of the row
        if i == 6
        text(ax, -1.3, 0.5, ResultsString(r), ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 8);
        else
            % Add text to the left side of the row
             text(ax, -0.8, 0.5, ResultsString(r), ...
            'Units', 'normalized', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 8);
        end

    
    end
    ReporterLabels{3-1} = 'percent collagen';
    figname = strcat('PlotBSbargraphsforEachifc',ReporterLabels{i-1});
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
    exportgraphics(fig,strcat(figname, '.png'),'Resolution',600, 'ContentType', 'vector')

   

end

figure(20)
%average collagen
hold on

% Get handle to all axes created by subplot
allAxes = findall(gcf, 'Type', 'axes');

% Apply font size to each subplot
for k = 1:length(allAxes)
    set(allAxes(k), 'FontSize', 8);
end

% Sort them in the order they were created (subplot order)
allAxes = flipud(allAxes);  % MATLAB stores them in reverse order


    % Apply same limits to all panels
    for k = 1:length(allAxes)
        ylim(allAxes(k), [0 3000]); 
        yticks(allAxes(k),0:600:3000)
    end
    % for k = 6:length(allAxes)
    %     ylim(allAxes(k), [0 3000]);
    %     yticks(0:625:1250)
    % end


% Create an invisible axes that spans the whole figure
axLegend = axes('Position',[0 0 1 1],'Visible','off');
hold(axLegend, 'on');

% --- Color Legend ---
colorLabels = {'ifc = 20', 'ifc = 40', 'ifc = 60', 'ifc = 80', 'ifc = 100'};
colorHandles = gobjects(length(figColors),1);
for c = 1:length(figColors)
    colorHandles(c) = plot(axLegend, nan, nan, '-', 'Color', figColors(c,:), 'LineWidth', 0.5);
end



% Combine handles: colors first, then styles
allHandles = colorHandles;

% Make labels a uniform string array (avoids mixed-type cell issues)
labels = [string(colorLabels)];

% Create combined legend at bottom of the entire figure (target the legend axes explicitly)
lgd = legend(axLegend, allHandles, labels, ...
    'Orientation', 'horizontal', 'Location', 'southoutside','Fontsize',8);
%lgd.Title.String = 'Color = IFC | Line Style = 52-week treatment';
lgd.Box = 'off';


cols = 5;
for r = 1:length(ResultsPath)
    % Find the first subplot in this row
    idx = (r-1)*cols + 1;
    ax = allAxes(idx);
    % Add text to the left side of the row
    text(ax, -1.3, 0.5, ResultsString(r), ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 8);

end
figname = strcat('PlotBSbargraphsforEachifc','average collagen');
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
exportgraphics(fig,strcat(figname, '.png'),'Resolution',600, 'ContentType', 'vector')

warning('on', 'all')