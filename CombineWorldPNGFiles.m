clear all
close all

folder{1} = 'BehaviorSpaceResults\Results-V10T03-280-A1-101525';
folder{2} = 'BehaviorSpaceResults\Results-V19S23-092-C1-101525';
folder{3} = 'BehaviorSpaceResults\Results-V10T03-279-D1-101525';
cases = {'A','C','D'};


for z = 1:3
figure
files = dir(fullfile(folder{z}, '*.png'));
% Sort to ensure consistent order

fileNames = natsortfiles({files.name}); %File Exchange


cols = 5;   % number of columns
rows = 3;   % number of rows

% Read first image to get dimensions
img = imread(fullfile(folder{z}, fileNames{1}));


% Define border thickness (in pixels)
border = 5;

% Add black border around the image
imgWithBorder = padarray(img, [border border], 0, 'both');

[h, w, c] = size(imgWithBorder);


% Preallocate canvas
canvas = uint8(255 * ones(rows*h, cols*w, c)); % white background

% Labels
replicateLabels = {"Rep. 1","Rep. 2","Rep. 3"};
treatmentLabels = {"Initial time", ...
    "52 weeks of treatment: none", ...
    "52 weeks of treatment: pirf", ...
    "52 weeks of treatment: pentox", ...
    "52 weeks of treatment: pentox and pirf"};

% Generate labels (a), (b), … up to (o)
labels = arrayfun(@(k) sprintf('(%c)', 'a'+(k-1)), 1:rows*cols, 'UniformOutput', false);

selectedset = [60+49, 49:3:60, 60+50, 50:3:60, 60+51, 51:3:60];
for k = 1:length(selectedset)
    img = imread(fullfile(folder{z}, fileNames{selectedset(k)}));
    imgWithBorder = padarray(img, [border border], 0, 'both');
    % Add label in top-left corner
    %imgWithLabel = insertText(imgWithBorder, [5 5], labels{k}, ...
    %'FontSize', 36, 'BoxOpacity', 0, 'TextColor', 'black');

    % Compute position
    row = floor((k-1)/cols);
    col = mod((k-1), cols);

    yStart = row*h + 1;
    yEnd   = (row+1)*h;
    xStart = col*w + 1;
    xEnd   = (col+1)*w;

    canvas(yStart:yEnd, xStart:xEnd, :) = imgWithBorder;
end

imshow(canvas);

% Add replicate labels on left edge
for r = 1:rows
    yPos = (r-0.5)*h; % halfway down each row
    text(-80, yPos, replicateLabels{r}, ...
        'FontSize', 20, 'Color', 'black', ...
        'HorizontalAlignment','left', 'VerticalAlignment','middle');
end

% Add treatment labels above each column
for c = 1:cols
    xPos = (c-0.5)*w; % halfway across each column
    text(xPos, -30, treatmentLabels{c}, ...
        'FontSize', 20, 'Color', 'black',  ...
        'HorizontalAlignment','center', 'VerticalAlignment','top');
end
%imwrite(canvas, ['figure_grid' cases{z} '.png']);

% Save figure with labels
saveas(gcf, ['figure_grid' cases{z} '.png']);
end