clear all
close all
addpath(genpath('natsortfiles'));
folder{1} = 'BehaviorSpaceResults\Results-V10T03-280-A1-101525';
folder{2} = 'BehaviorSpaceResults\Results-V19S23-092-C1-101525';
folder{3} = 'BehaviorSpaceResults\Results-V10T03-279-D1-101525';
cases = {'a) Case A','b) Case C','c) Case D'};
outputDPI = 600;

cols = 5;                 % columns per row
rows_per_case = 3;        % rows per condition
total_rows = rows_per_case * numel(cases);

% Labels
replicateLabels = {"Rep. 1","Rep. 2","Rep. 3"};
treatmentLabels = {"Initial time", ...
    "52 weeks: none", ...
    "52 weeks: pirf", ...
    "52 weeks: pentox", ...
    "52 weeks: pentox & pirf"}; % note: '&' literal
% Your selection indices per condition (length must equal rows_per_case*cols)
selectedset = [60+49, 49:3:60, 60+50, 50:3:60, 60+51, 51:3:60];
assert(numel(selectedset)==rows_per_case*cols, ...
    'selectedset must have %d entries', rows_per_case*cols);

% ------------------------------
% Establish base image size from the first folder
% ------------------------------
files1 = dir(fullfile(folder{1}, '*.png'));
fileNames1 = natsortfiles({files1.name});
if isempty(fileNames1)
    error('No PNG files found in %s', folder{1});
end
sample = imread(fullfile(folder{1}, fileNames1{1}));

% Border around each tile (in pixels)
border = 3;

% Ensure 3-channel consistency for the canvas
if size(sample,3)==1
    sample = repmat(sample, 1,1,3);
end
sampleB = padarray(sample, [border border], 0, 'both');
[h0, w0, c] = size(sampleB);

% ------------------------------
% Preallocate big canvas (white background)
% ------------------------------
separator_height = 12;  % e.g., 6–12 px looks clean
n_separators = numel(cases) - 1;
H = total_rows * h0 + n_separators * separator_height;
W = cols * w0;

canvas = uint8(255 * ones(H, W, c, 'like', sample));

% ------------------------------
% Fill the canvas with images from each condition
% ------------------------------
for z = 1:numel(cases)
    files = dir(fullfile(folder{z}, '*.png'));
    fileNames = natsortfiles({files.name});
    if numel(fileNames) < max(selectedset)
        error('Folder %s does not contain enough images for selectedset.', folder{z});
    end

    for k = 1:numel(selectedset)
        idx = selectedset(k);
        img = imread(fullfile(folder{z}, fileNames{idx}));

        % Ensure RGB
        if size(img,3) ~= c
            if size(img,3)==1
                img = repmat(img, 1,1,c);
            else
                % Fallback: convert to 3 channels by truncation or padding
                tmp = uint8(255 * ones(size(img,1), size(img,2), c, 'like', img));
                tmp(:,:,1:min(size(img,3),c)) = img(:,:,1:min(size(img,3),c));
                img = tmp;
            end
        end

        % Add black border
        imgB = padarray(img, [border border], 0, 'both');

        % If dims differ slightly, center-pad to [h0, w0] to avoid resampling blur
        [h, w, ~] = size(imgB);
        if h~=h0 || w~=w0
            dh = max(0, h0 - h);
            dw = max(0, w0 - w);
            imgB = padarray(imgB, [floor(dh/2) floor(dw/2)], 255, 'pre');
            imgB = padarray(imgB, [ceil(dh/2)  ceil(dw/2)],  255, 'post');
            imgB = imgB(1:h0, 1:w0, :);  % guard against overshoot
        end

        % Compute placement in the big canvas
        local_row  = floor((k-1) / cols);      % 0..(rows_per_case-1)
        col        = mod((k-1), cols);         % 0..(cols-1)
        global_row = (z-1)*rows_per_case + local_row;      % 0..(total_rows-1)
        block_offset = (z-1) * separator_height;           % extra rows above this block

        yStart = global_row*h0 + 1 + block_offset;
        yEnd   = (global_row+1)*h0     + block_offset;
        xStart = col*w0 + 1;
        xEnd   = (col+1)*w0;

        canvas(yStart:yEnd, xStart:xEnd, :) = imgB;
    end
end



% After this, display and annotate as before

% ------------------------------
% Display once and annotate (preserves font sizes)
% ------------------------------
fig = figure('Units','inches', 'Position',[1 1 7.5 11], 'Color','w', 'Visible','on'); % set 'off' for headless
ax = axes(fig);
imshow(canvas, 'Parent', ax); 
axis(ax, 'off'); 
hold(ax, 'on');

% Make the top margin visible for column headers
set(ax, 'YDir', 'reverse');   % make explicit (imshow sets reverse by default)
xlim(ax, [1 W]);
ylim(ax, [-100 H]);            % extend above the image for header space

% Column headers (top, once)
for ccol = 1:cols
    xPos = (ccol - 0.5) * w0;
    text(ax, xPos, -100, treatmentLabels{ccol}, ...
         'FontSize', 6, 'Color','k', ...
         'HorizontalAlignment','center', 'VerticalAlignment','top', ...
         'Interpreter','none');
end

% Left-side replicate labels for each row (Rep. 1/2/3 repeating per block)
for gRow = 1:total_rows
    r_local = mod(gRow-1, rows_per_case) + 1;
    yPos = (gRow - 0.5) * h0;
    text(ax, -25, yPos, replicateLabels{r_local}, ...
         'FontSize', 6, 'Color','k', ...
         'HorizontalAlignment','right', 'VerticalAlignment','middle', ...
         'Interpreter','none');
end

% Optional: left condition labels ('A','C','D') at the top of each 3-row block
% ------------------------------
% Condition labels OUTSIDE the image block (upper-left)
% ------------------------------
x_left = -250;   % left of canvas (similar to replicate label offset)
y_offset = 0;  % place label 20 px ABOVE the block

for z = 1:numel(cases)
    % Top of this 3-row block
    y_top_block = (z-1)*rows_per_case*h0 + 1;

    % Final label position outside the block
    text(ax, x_left, y_top_block + y_offset, cases{z}, ...
         'FontSize', 6, 'Color', 'k', ...
         'HorizontalAlignment','left', 'VerticalAlignment','top', ...
         'Interpreter','none');
end


% ------------------------------
% Export once at high resolution
% ------------------------------
exportgraphics(fig, 'figure_grid_A+C+D.png', 'Resolution', outputDPI);
disp('Saved: figure_grid_A+C+D.png');

% Optional vector-friendly copy (keeps text vectorized)
% exportgraphics(fig, 'figure_grid_A+C+D.pdf');   % uncomment if desired