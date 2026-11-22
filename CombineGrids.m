% =============================
% Combine compact 3 Rep panels
% =============================
cases = {'A','C','D'};
caseLetters = {'a) Case A','b) Case C','c) Case D'};
repLetters = {'a) Rep. #','b) Rep. #','c) Rep. #'};      % labels for each replicate
outputDPI = 600;
%want to generate figures with reps 2:4, 5:7, 8-10
repStartRanges = {2, 5, 8};
for p = 1:length(repStartRanges)
    repNum0 = repStartRanges{p}-1;
    for z = 1:numel(cases)
        ims = cell(1,3);
        % Read compact per-replicate images
        for r = 1:3
            repNum = repNum0+r;
            fname = sprintf('combined_grid_%sRep%d.png', cases{z}, repNum);
            if ~isfile(fname)
                error('Expected file not found: %s. Make sure Step 1 exported images.', fname);
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
            repNum = repNum0+r;
            ax = nexttile(tl);
            imshow(ims{r}, 'Parent', ax, 'Border', 'tight');
            axis(ax, 'off');
    
            % Add label in the upper-left corner of each image
            text(ax, 0.01, 0.99, strcat(repLetters{r}, num2str(repNum)), ...
                'Units','normalized', ...
                'HorizontalAlignment','left', 'VerticalAlignment','top', ...
                'FontSize', 10, 'Color','k');
        end
    
        outname = strcat('combined_grid_', cases{z}, '_Rep', num2str(repStartRanges{p}),'-',num2str(repNum),'_compact.png');
        exportgraphics(fig, outname, 'Resolution', outputDPI);
        close(fig);
    end
    
end

% combine rep 1 for each case
repNum = 1;
        ims = cell(1,3);
        % Read compact per-replicate images
        for r = 1:3
            fname = sprintf('combined_grid_%sRep%d.png', cases{r}, repNum);
            if ~isfile(fname)
                error('Expected file not found: %s. Make sure Step 1 exported images.', fname);
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
            text(ax, 0.01, 0.99, caseLetters{r}, ...
                'Units','normalized', ...
                'HorizontalAlignment','left', 'VerticalAlignment','top', ...
                'FontSize', 10, 'Color','k');
        end
    
        outname = strcat('combined_grid_ACD', '_Rep', num2str(repNum),'_compact.png');
        exportgraphics(fig, outname, 'Resolution', outputDPI);
        close(fig);


