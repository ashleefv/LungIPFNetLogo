clear all
close all
warning('off', 'all')
% This version is adapted to work with the NetLogo code optimized for
% running Behavior Space, corresponding to this commit on github: 
% https://github.com/ashleefv/ICERMNetLogo/commit/a0b8ae5171888be032ab3d1acba9402dfe68d1c1

folder{1} = 'BehaviorSpaceResults\Results-V10T03-280-A1-101525';
folder{2} = 'BehaviorSpaceResults\Results-V19S23-092-C1-101525';
folder{3} = 'BehaviorSpaceResults\Results-V10T03-279-D1-101525';
selectedset = [60+49, 49:3:60, 60+50, 50:3:60, 60+51, 51:3:60];

cols = 5;   % number of columns
rows = 3;   % number of rows

cases = {'A','C','D'};

% Labels
replicateLabels = {"Rep. 1","Rep. 2","Rep. 3"};
treatmentLabels = {"Initial time", ...
    "52 weeks of treatment: none", ...
    "52 weeks of treatment: pirf", ...
    "52 weeks of treatment: pentox", ...
    "52 weeks of treatment: pentox and pirf"};

for z = 1:3
files = dir(fullfile(folder{z}, 'world*.csv'));
% Sort to ensure consistent order

fileNames = natsortfiles({files.name}); %File Exchange


for k = 1:length(selectedset)
csv_filename = [folder{z} '\'  fileNames{selectedset(k)}];% 'BehaviorSpaceResults\Results-V10T03-280-A1-101525\worldBefore-51.csv';%'worldAfter-49.csv';
GlobalVars = readtable(csv_filename,Range="A9:BH10",FileType="spreadsheet");

turtlesStartRow = 13;
turtlesEndRow = turtlesStartRow+GlobalVars.initial_fibroblast_cells;
turtlesDataCoords = ['A', num2str(turtlesStartRow),':R',num2str(turtlesEndRow)];
Turtles = readtable(csv_filename ,Range=turtlesDataCoords,FileType="spreadsheet");

patchesStartRow = turtlesEndRow  + 3;
patchesEndRow = patchesStartRow + (GlobalVars.max_pxcor-GlobalVars.min_pxcor+1)*(GlobalVars.max_pycor-GlobalVars.min_pycor+1);
patchesDataCoords = ['A', num2str(patchesStartRow),':O',num2str(patchesEndRow)];
Patches = readtable(csv_filename ,Range=patchesDataCoords,FileType="spreadsheet");

x = Patches.pxcor;
y = Patches.pycor;
QuantNameString = 'total\_patch\_collagen';
patchquantity = Patches.total_patch_collagen;
%plotPatchQuantity(x,y,patchquantity,QuantNameString)

% Compute position
figure(z)
subplot(rows,cols,k)
if k <=5 
    title(treatmentLabels{k})
end
% Add replicate labels on left edge
if mod(k,cols) == 1
    ylabel(replicateLabels{floor(k/cols)+1},'FontWeight','bold');
end
hold on
plotPatchQuantityWithCollagenBoundary(x,y,patchquantity,QuantNameString,Patches.pcolor)
hold off

% Save figure with labels
saveas(gcf, ['collagen_grid' cases{z} '.png']);

QuantNameString = 'patch\_tgfbeta';
patchquantity = Patches.patch_tgfbeta;
%plotPatchQuantity(x,y,patchquantity,QuantNameString)

% Compute position
figure(3+z)
subplot(rows,cols,k)
if k <=5 
    title(treatmentLabels{k})
end
% Add replicate labels on left edge
if mod(k,cols) == 1
    ylabel(replicateLabels{floor(k/cols)+1},'FontWeight','bold');
end
hold on
plotPatchQuantityWithCollagenBoundary(x,y,patchquantity,QuantNameString,Patches.pcolor)
hold off

% Save figure with labels
saveas(gcf, ['tgf_grid' cases{z} '.png']);

% QuantNameString = 'pcolor';
% patchquantity = Patches.pcolor;
% plotPatchQuantity(x,y,patchquantity,QuantNameString)

% colormatrix = zeros(length(Patches.pcolor),3);
% for i = 1:length(Patches.pcolor)
%     if Patches.pcolor(i) == 117
%         colormatrix(i,:) = [124 80 164]./255;
%     elseif Patches.pcolor(i) == 115
%         colormatrix(i,:) = [176 150 200]./255;
%     else
%         colormatrix(i,:) = [255 255 255]./255;
%     end
% end

%mymap = [176 150 200; 124 80 164; 255 255 255]./255;

%QuantNameString = 'colormatrix';
%patchquantity = colormatrix;
%plotPatchQuantity(x,y,patchquantity,QuantNameString)

end



end
warning('on', 'all')

function plotPatchQuantity(x,y,patchquantity,QuantNameString)
x_unique = unique(x);
y_unique = unique(y);

% Initialize matrix to hold values
Z = nan(length(y_unique), length(x_unique));  % Preallocate with NaNs

% Fill Z with value for each (x, y) patch 
for i = 1:length(x_unique)
    for j = 1:length(y_unique)
        % Find indices matching current patch
        idx = (x == x_unique(i)) & (y == y_unique(j));
        
        % If there are values, compute the mean
        if any(idx)
            Z(j, i) = patchquantity (idx);
        end
    end
end

% Create meshgrid for plotting
[X, Y] = meshgrid(x_unique, y_unique);

% Plot the surface
figure;
surf(X, Y, Z);
shading flat;  % No interpolation
colorbar;
xlabel('X');
ylabel('Y');
zlabel(QuantNameString);
title([QuantNameString, ' at Patches']);
view(3);
figure;
imagesc(x_unique, y_unique, Z);
axis xy; % so y increases upward
xlabel('X');
ylabel('Y');
title([QuantNameString, ' at Patches']);

widthInches = 5.5;
heightInches = 5;
fig = gcf;
% Get current size in inches
set(fig, 'Units', 'Inches');
figPos = get(fig, 'Position');


% Set figure size
set(fig, 'Position', [1, 1, widthInches, heightInches]);
set(fig, 'PaperUnits', 'Inches');
set(fig, 'PaperSize', [widthInches, heightInches]);
figPos = get(fig, 'Position');
set(fig, 'PaperPositionMode', 'manual');
colorbar;
s.EdgeColor = 'none';

end

function plotPatchQuantityWithCollagenBoundary(x,y,patchquantity,QuantNameString,patchcolor)
x_unique = unique(x);
y_unique = unique(y);

% Initialize matrix to hold values
Z = nan(length(y_unique), length(x_unique));  % Preallocate with NaNs

% Compute patch_tgfbeta for each (x, y) patch with collagen
for i = 1:length(x_unique)
    for j = 1:length(y_unique)
        % Find indices matching current patch
        idx = (x == x_unique(i)) & (y == y_unique(j));
        
        % If there are values, compute the mean
        if any(idx)
            if patchcolor(idx) > 9.9
                Z(j, i) = patchquantity(idx);
            else 
                Z(j, i) = NaN;
            end
        end
    end
end


% Pad Z to prevent pcolor from cutting off last row/column
Zpad = [Z nan(size(Z,1),1); nan(1,size(Z,2)+1)];

% max(max(Z))

% Create meshgrid for padded data
[X, Y] = meshgrid([x_unique; x_unique(end)+1], [y_unique; y_unique(end)+1]);



% Plot using pcolor
if strcmp(QuantNameString, 'patch\_tgfbeta')
    initialTGFbeta = 5000;
    s = pcolor(X, Y, Zpad/initialTGFbeta);
    edges = [0 0.05 0.1 0.33 0.66 1 2 3 4];
    % Define discrete color edges and colors

colors = [
    0.8 0.9 1.0;  % light blue
    0.6 0.8 1.0;
    0.4 0.6 0.9;
    0.2 0.4 0.8;  % dark blue
   % 1.0 1.0 0.6;  % yellow
    1.0 0.8 0.0;  % gold
    1.0 0.4 0.0;  % dark orange
    0.8 0.0 0.0;  % red
    0 0 0; % black
];
else
    s = pcolor(X, Y, Zpad);
    edges = [1  500 1000 5000 7500 10000 12000];
    
    % Define discrete color edges and colors

colors = [
    [176 150 200]./255; % light purple
    %0.6 0.8 1.0;
    %0.4 0.6 0.9;
    0.2 0.4 0.8;  % dark blue
    1.0 1.0 0.6;  % yellow
    1.0 0.8 0.0;  % orange
    1.0 0.4 0.0;  % dark orange
    0.8 0.0 0.0;  % red
];

end
s.EdgeColor = 'none'; % Remove grid lines
shading flat; % No interpolation



% xlabel('X');
% ylabel('Y');
%title([QuantNameString, ' at Patches']);

% % Add colorbar with label
% cb = colorbar;
% title(cb, QuantNameString);
% clim([0, 4])
set(gca, 'XTickLabel', {},'YTickLabel', {}); 

axis equal tight;git stat



% Apply discrete colormap to main plot
colormap(gca, colors);
caxis([edges(1) edges(end)]);

    % Remove default colorbar
    colorbar('off');

    % Create horizontal custom colorbar below plot
    cbAx = axes('Position',[0.1 0.05 0.8 0.05]); % adjust position
    hold(cbAx,'on');

    for i = 1:length(edges)-1
        xLeft = edges(i);
        xRight = edges(i+1);
        patch([xLeft xRight xRight xLeft], [0 0 1 1], colors(i,:), 'EdgeColor', 'k');
    end

    axis(cbAx,[edges(1) edges(end) 0 1]);
    set(cbAx,'YTick',[], ...
        'XTick',edges, ...
        'FontWeight','bold'); 

    if strcmp(QuantNameString, 'patch\_tgfbeta')
    xlabel(cbAx, [QuantNameString '/initialSourceTGFbeta'], 'FontWeight','bold');
    else
       xlabel(cbAx, QuantNameString, 'FontWeight','bold');
    end


widthPixels = 505;
heightPixels = 505;
% ax = gca;
% % Get current size in Pixels
% set(ax, 'Units', 'Pixels');
% axPos = get(ax, 'Position');
% 
% 
% % Set axis size
% set(ax, 'Position', [1, 1, widthPixels, heightPixels]);
% set(ax, 'PaperUnits', 'Pixels');
% set(ax, 'PaperSize', [widthPixels, heightPixels]);
% axPos = get(ax, 'Position');
% set(ax, 'PaperPositionMode', 'manual');


end

% if patchquantity == colormatrix
%     mymap = [176 150 200; 124 80 164; 255 255 255]./255;
%     colormap(mymap)
% end
