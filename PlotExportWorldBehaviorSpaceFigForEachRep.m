
clear all; close all; warning('off','all');
addpath(genpath('natsortfiles'));

folder{1} = 'BehaviorSpaceResults\Results-V10T03-280-A1-101525';
folder{2} = 'BehaviorSpaceResults\Results-V19S23-092-C1-101525';
folder{3} = 'BehaviorSpaceResults\Results-V10T03-279-D1-101525';
cases = {'A','C','D'};
%ifc = 100 and the sets correspond to the behavior space run numbers with
%the first 60 being "worldAfter" files and the second 60 being "worldBefore" files saved as .png and .csv 
selectedset = [60+49, 49:3:60, 60+50, 50:3:60, 60+51, 51:3:60];
selectedmatrix = [60+49, 49:3:60; 60+50, 50:3:60; 60+51, 51:3:60];
cols = 5; rows = 3; reps = 3;
replicateLabels = {"Rep1","Rep2","Rep3"};
rowLabels = {"NetLogo World","Patch collagen value","Patch TGF\beta value"};
treatmentLabels = {"Initial time","52 weeks: none","52 weeks: pirf","52 weeks: pentox","52 weeks: pentox & pirf"};

% Fixed colorbar settings
collagenEdges = [1 500 1000 2500 5000 7500 10000]; % 12000
collagenColors = [
    [176 150 200]./255; % light purple
    0.2 0.4 0.8;        % dark blue
    1.0 1.0 0.6;        % yellow
    1.0 0.8 0.0;        % orange
    1.0 0.4 0.0;        % dark orange
    0.8 0.0 0.0;        % red
];

tgfEdges = [0 0.01 0.05 0.10 0.5 0.75 1 2];
tgfColors = [
    0.8 0.9 1.0;  % light blue
    0.6 0.8 1.0;
    0.4 0.6 0.9;
    0.2 0.4 0.8;  % dark blue
    1.0 0.8 0.0;  % gold
    1.0 0.4 0.0;  % dark orange
    0.8 0.0 0.0;  % red
   % 0 0 0;        % black
];


for z = 1:3
    files = dir(fullfile(folder{z}, '*.png'));
    fileNames = natsortfiles({files.name});

    if z == 1
        r = 1;
        cols = 2;
        figure(r)
        fig = gcf;
        set(fig,'Units','normalized','Position',[0 0 1 1]);
        
        % Row 1: PNG images from NetLogo worlds
        rowNumber = 1;
        for k = 1:cols        
            subplot(rows, cols, (rowNumber-1)*cols+k);
            img = imread(fullfile(folder{z}, fileNames{selectedmatrix(r,k)}));
            imshow(img);
            axis off;
            title(treatmentLabels{k},'FontWeight', 'normal');
        end

        
        % Legend axis below row 1
        legendAx = axes('Position',[0.20 0.65 0.60 0.05]); % adjust Y for below row 1
        hold(legendAx,'on');

      
        % Define colors
        lightPurple = [176 150 200]/255;
        darkPurple  = [124 80 164]/255;
        orangeMarker = [246 166 115]/255;
        greenMarker  = [120 197 174]/255;
        

        % Layout parameters (normalized to legend axis)
        patchWidth = 0.075;     % HALF the previous width (was ~0.15)
        patchHeightTop = [0.60 0.60 0.95 0.95];   % top row patch Y coords
        patchHeightBot = [0.05 0.05 0.40 0.40];   % bottom row patch Y coords
        textOffsetX   = 0.02;   % gap between patch and label
        textSize      = 6;      % slightly smaller font for compact legend
        
        % Column anchors (left edges) for two items per row
        colLefts = [0.02, 0.52];  % adjust to center under your subplots
        
        % --- Row 1: Initial collagen, New collagen ---
        % Initial collagen
        xL = colLefts(1); xR = xL + patchWidth;
        patch([xL xR xR xL], patchHeightTop, lightPurple, 'EdgeColor','k');
        text(xR + textOffsetX, 0.78, 'Initial collagen', 'FontSize', textSize, 'VerticalAlignment','middle');
        
        % New collagen
        xL = colLefts(2); xR = xL + patchWidth;
        patch([xL xR xR xL], patchHeightTop, darkPurple, 'EdgeColor','k');
        text(xR + textOffsetX, 0.78, 'New collagen', 'FontSize', textSize, 'VerticalAlignment','middle');
        
        % --- Row 2: Fibroblast cells, Myofibroblast cells ---
        % Fibroblast cells
        xL = colLefts(1); xR = xL + patchWidth;
        patch([xL xR xR xL], patchHeightBot, orangeMarker, 'EdgeColor','k');
        text(xR + textOffsetX, 0.23, 'Fibroblast cells', 'FontSize', textSize, 'VerticalAlignment','middle');
        
        % Myofibroblast cells
        xL = colLefts(2); xR = xL + patchWidth;
        patch([xL xR xR xL], patchHeightBot, greenMarker, 'EdgeColor','k');
        text(xR + textOffsetX, 0.23, 'Myofibroblast cells', 'FontSize', textSize, 'VerticalAlignment','middle');
        
        axis(legendAx,[0 1 0 1]);
        axis(legendAx,'off');
        hold(legendAx,'off');

        
        % patch data from csv files
        for k = 1:cols
            csv_filename = [folder{z} '\' fileNames{selectedmatrix(r,k)}(1:end-4) '.csv'];
            GlobalVars = readtable(csv_filename,Range="A9:BH10",FileType="spreadsheet");
            turtlesStartRow = 13;
            turtlesEndRow = turtlesStartRow+GlobalVars.initial_fibroblast_cells;
            patchesStartRow = turtlesEndRow+3;
            patchesEndRow = patchesStartRow+(GlobalVars.max_pxcor-GlobalVars.min_pxcor+1)*(GlobalVars.max_pycor-GlobalVars.min_pycor+1);
            patchesDataCoords = ['A', num2str(patchesStartRow),':O',num2str(patchesEndRow)];
            Patches = readtable(csv_filename,Range=patchesDataCoords,FileType="spreadsheet");

            % Row 2: Collagen plots
            rowNumber = 2;            
            subplot(rows, cols, (rowNumber-1)*cols+k);
            plotPatchQuantityWithCollagenBoundary(Patches.pxcor,Patches.pycor,Patches.total_patch_collagen,'total\_patch\_collagen',Patches.pcolor,collagenEdges,collagenColors);

            if k == 2

                % Add collagen colorbar below row 2
                cbAx = axes('Position',[0.14 0.38 0.75 0.02]); % adjust Y for below row 2
                hold(cbAx,'on');
                for i = 1:length(collagenEdges)-1
                    patch([collagenEdges(i) collagenEdges(i+1) collagenEdges(i+1) collagenEdges(i)], [0 0 1 1], collagenColors(i,:), 'EdgeColor', 'k');
                end
                axis(cbAx,[collagenEdges(1) collagenEdges(end) 0 1]);
                set(cbAx,'YTick',[], 'XTick',collagenEdges,'fontsize',6);
                xtickangle(cbAx, 0);
            end

            % Row 3: TGF-beta plots
            rowNumber = 3;
            subplot(rows, cols, (rowNumber-1)*cols+k);
            plotPatchQuantityWithCollagenBoundary(Patches.pxcor,Patches.pycor,Patches.patch_tgfbeta,'patch\_tgfbeta',Patches.pcolor,tgfEdges,tgfColors);
            
            if k == 2

                % Add TGF-beta colorbar below row 3
                cbAx = axes('Position',[0.14 0.08 0.75 0.02]); % adjust Y for bottom
                hold(cbAx,'on');
                for i = 1:length(tgfEdges)-1
                    patch([tgfEdges(i) tgfEdges(i+1) tgfEdges(i+1) tgfEdges(i)], [0 0 1 1], tgfColors(i,:), 'EdgeColor', 'k');
                end
                axis(cbAx,[tgfEdges(1) tgfEdges(end) 0 1]);
                set(cbAx,'YTick',[], 'XTick',tgfEdges,'fontsize',6);
                %xlabel(cbAx,'patch\_tgfbeta/initialSourceTGFbeta','fontsize',8);
                xtickangle(cbAx, 90);


            end
        end

        % Add row labels as annotations (outside subplots)
        annotation('textbox', [0.02 0.78 0.08 0.05], 'String', rowLabels{1}, ...
            'FontSize', 10, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'EdgeColor', 'none');
        
        annotation('textbox', [0.02 0.48 0.08 0.05], 'String', rowLabels{2}, ...
            'FontSize', 10,  'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'EdgeColor', 'none');
        
        annotation('textbox', [0.02 0.18 0.08 0.05], 'String', rowLabels{3}, ...
            'FontSize', 10,  'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'EdgeColor', 'none');

        figname = strcat('combined_gridZoom_', cases{z}, replicateLabels{r});
        %saveas(gcf,strcat(figname, '.png'));

        fig= gcf;

        % Adjust based on figure's aspect ratio
        widthInches = 5;
        heightInches = 7.5;
        
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
        close all
    end

    cols = 5; rows = 3; reps = 3;
    for r = 1:reps
        figure(r)
        fig = gcf;
        set(fig,'Units','normalized','Position',[0 0 1 1]);

        % Row 1: PNG images from NetLogo worlds
        rowNumber = 1;
        for k = 1:cols        
            subplot(rows, cols, (rowNumber-1)*cols+k);
            img = imread(fullfile(folder{z}, fileNames{selectedmatrix(r,k)}));
            imshow(img);
            axis off;
            title(treatmentLabels{k},'FontWeight', 'normal');
        end


        % Legend axis below row 1
        legendAx = axes('Position',[0.14 0.65 0.77 0.04]); % adjust Y for below row 1
        hold(legendAx,'on');

        % Define colors
        lightPurple = [176 150 200]/255;
        darkPurple  = [124 80 164]/255;
        orangeMarker = [246 166 115]/255;
        greenMarker  = [120 197 174]/255;

        % Draw color blocks
        patch([0 0.05 0.05 0],[0.5 0.5 1 1], lightPurple, 'EdgeColor','k');
        text(0.06, 0.75, 'Initial collagen', 'FontSize',8);

        patch([0.25 0.3 0.3 0.25],[0.5 0.5 1 1], darkPurple, 'EdgeColor','k');
        text(0.31, 0.75, 'New collagen', 'FontSize',8);

        patch([0.5 0.55 0.55 0.5],[0.5 0.5 1 1], orangeMarker, 'EdgeColor','k');
        text(0.56, 0.75, 'Fibroblast cells', 'FontSize',8);

        patch([0.75 0.8 0.8 0.75],[0.5 0.5 1 1], greenMarker, 'EdgeColor','k');
        text(0.81, 0.75, 'Myofibroblast cells', 'FontSize',8);

        axis(legendAx,[0 1 0 1]);
        axis off;

        % patch data from csv files
        for k = 1:cols
            csv_filename = [folder{z} '\' fileNames{selectedmatrix(r,k)}(1:end-4) '.csv'];
            GlobalVars = readtable(csv_filename,Range="A9:BH10",FileType="spreadsheet");
            turtlesStartRow = 13;
            turtlesEndRow = turtlesStartRow+GlobalVars.initial_fibroblast_cells;
            patchesStartRow = turtlesEndRow+3;
            patchesEndRow = patchesStartRow+(GlobalVars.max_pxcor-GlobalVars.min_pxcor+1)*(GlobalVars.max_pycor-GlobalVars.min_pycor+1);
            patchesDataCoords = ['A', num2str(patchesStartRow),':O',num2str(patchesEndRow)];
            Patches = readtable(csv_filename,Range=patchesDataCoords,FileType="spreadsheet");

            % Row 2: Collagen plots
            rowNumber = 2;            
            subplot(rows, cols, (rowNumber-1)*cols+k);
            plotPatchQuantityWithCollagenBoundary(Patches.pxcor,Patches.pycor,Patches.total_patch_collagen,'total\_patch\_collagen',Patches.pcolor,collagenEdges,collagenColors);

            if k == 5

                % Add collagen colorbar below row 2
                cbAx = axes('Position',[0.14 0.38 0.75 0.02]); % adjust Y for below row 2
                hold(cbAx,'on');
                for i = 1:length(collagenEdges)-1
                    patch([collagenEdges(i) collagenEdges(i+1) collagenEdges(i+1) collagenEdges(i)], [0 0 1 1], collagenColors(i,:), 'EdgeColor', 'k');
                end
                axis(cbAx,[collagenEdges(1) collagenEdges(end) 0 1]);
                %xtickformat('%1.1e')
                set(cbAx,'YTick',[], 'XTick',collagenEdges,'fontsize',6);
                xtickangle(cbAx, 0);
            end

            % Row 3: TGF-beta plots
            rowNumber = 3;
            subplot(rows, cols, (rowNumber-1)*cols+k);
            plotPatchQuantityWithCollagenBoundary(Patches.pxcor,Patches.pycor,Patches.patch_tgfbeta,'patch\_tgfbeta',Patches.pcolor,tgfEdges,tgfColors);

            if k == 5

                % Add TGF-beta colorbar below row 3
                cbAx = axes('Position',[0.14 0.08 0.75 0.02]); % adjust Y for bottom
                hold(cbAx,'on');
                for i = 1:length(tgfEdges)-1
                    patch([tgfEdges(i) tgfEdges(i+1) tgfEdges(i+1) tgfEdges(i)], [0 0 1 1], tgfColors(i,:), 'EdgeColor', 'k');
                end
                axis(cbAx,[tgfEdges(1) tgfEdges(end) 0 1]);
                set(cbAx,'YTick',[], 'XTick',tgfEdges,'fontsize',6);
                %xlabel(cbAx,'patch\_tgfbeta/initialSourceTGFbeta','fontsize',8);
                xtickangle(cbAx, 90);


            end
        end

        % Add row labels as annotations (outside subplots)
        annotation('textbox', [0.02 0.78 0.08 0.05], 'String', rowLabels{1}, ...
            'FontSize', 10, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'EdgeColor', 'none');

        annotation('textbox', [0.02 0.48 0.08 0.05], 'String', rowLabels{2}, ...
            'FontSize', 10,  'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'EdgeColor', 'none');

        annotation('textbox', [0.02 0.18 0.08 0.05], 'String', rowLabels{3}, ...
            'FontSize', 10,  'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'EdgeColor', 'none');

        figname = strcat('combined_grid_', cases{z}, replicateLabels{r});
        %saveas(gcf,strcat(figname, '.png'));

        fig= gcf;

        % Adjust based on figure's aspect ratio
        widthInches = 7.5;
        heightInches = 3.6; %to compact the vertical spacing

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
        exportgraphics(fig,strcat(figname, '_compact.png'),'Resolution',600)
%        exportgraphics(fig,strcat(figname, '.pdf'),'Resolution',600)
    end
    close all
end
warning('on', 'all')

% =============================
% Combine compact Rep 1–3 panels
% =============================
cases = {'A','C','D'};
repLetters = {'a) Rep. 1','b) Rep. 2','c) Rep. 3'};      % labels for each replicate
outputDPI = 600;

for z = 1:numel(cases)
    ims = cell(1,3);
    % Read compact per-replicate images
    for r = 1:3
        fname = sprintf('combined_grid_%sRep%d_compact.png', cases{z}, r);
        if ~isfile(fname)
            error('Expected file not found: %s. Make sure Step 1 exported compact images.', fname);
        end
        ims{r} = imread(fname);
    end

    % Normalize widths so they tile cleanly (preserve aspect ratio)
    targetW = min(cellfun(@(I) size(I,2), ims));  % smallest width
    for r = 1:3
        if size(ims{r},2) ~= targetW
            ims{r} = imresize(ims{r}, [NaN, targetW]);  % requires Image Processing Toolbox
        end
    end

    % Create a tall figure (portrait) and tile 3 rows x 1 column
    fig = figure('Units','inches','Position',[1 1 7.5 11]); % ~letter portrait
    tl = tiledlayout(fig, 3, 1, 'TileSpacing','compact', 'Padding','compact');

    for r = 1:3
        ax = nexttile(tl);
        imshow(ims{r}, 'Parent', ax, 'Border', 'tight');
        axis(ax, 'off');

        % Add label in the upper-left corner of each image
        text(ax, 0.01, 0.99, repLetters{r}, ...
            'Units','normalized', ...
            'HorizontalAlignment','left', 'VerticalAlignment','top', ...
            'FontSize', 10, 'Color','k');
    end

    outname = sprintf('combined_grid_%s_Rep1-3_compact.png', cases{z});
    exportgraphics(fig, outname, 'Resolution', outputDPI);
    close(fig);
end

function plotPatchQuantityWithCollagenBoundary(x,y,patchquantity,QuantNameString,patchcolor,edges,colors)
    x_unique = unique(x); y_unique = unique(y);
    Z = nan(length(y_unique), length(x_unique));
    for i = 1:length(x_unique)
        for j = 1:length(y_unique)
            idx = (x==x_unique(i)) & (y==y_unique(j));
            if any(idx)
                if patchcolor(idx)>9.9
                    Z(j,i)=patchquantity(idx);
                else
                    Z(j,i)=NaN;
                end
            end
        end
    end
    Zpad=[Z nan(size(Z,1),1); nan(1,size(Z,2)+1)];
    [X,Y]=meshgrid([x_unique;x_unique(end)+1],[y_unique;y_unique(end)+1]);
    if strcmp(QuantNameString, 'patch\_tgfbeta')
        initialTGFbeta = 5000;
        s = pcolor(X, Y, Zpad/initialTGFbeta);
    else
        s=pcolor(X,Y,Zpad); 
    end
    s.EdgeColor='none'; 
    shading flat; axis equal tight; 
    set(gca,'XTickLabel',{},'YTickLabel',{});
    set(gca, 'XTick', [], 'YTick', [],'XColor', 'none','YColor','none')
    box off; % removes the box around the plot, 
    colormap(gca,colors); 
    caxis([edges(1) edges(end)]);
end
