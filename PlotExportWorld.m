clear all
close all
csv_filename = '1_Healthy_Lung_World_code world.csv';
GlobalVars = readtable(csv_filename ,Range="A9:AX10");

turtlesStartRow = 13;
turtlesEndRow = turtlesStartRow+GlobalVars.initial_fibroblast_cells;
turtlesDataCoords = ['A', num2str(turtlesStartRow),':R',num2str(turtlesEndRow)];
Turtles = readtable(csv_filename ,Range=turtlesDataCoords);

patchesStartRow = turtlesEndRow  + 3;
patchesEndRow = patchesStartRow + (GlobalVars.max_pxcor-GlobalVars.min_pxcor+1)*(str2num(GlobalVars.max_pycor{1})-GlobalVars.min_pycor+1);
patchesDataCoords = ['A', num2str(patchesStartRow),':R',num2str(patchesEndRow)];
Patches = readtable(csv_filename ,Range=patchesDataCoords);

x = Patches.pxcor;
y = Patches.pycor;
QuantNameString = 'total\_patch\_collagen';
patchquantity = Patches.total_patch_collagen;
plotPatchQuantity(x,y,patchquantity,QuantNameString)

plotPatchQuantityWithCollagenBoundary(x,y,patchquantity,QuantNameString,Patches.pcolor)

QuantNameString = 'patch\_tgfbeta';
patchquantity = Patches.patch_tgfbeta;
plotPatchQuantity(x,y,patchquantity,QuantNameString)

plotPatchQuantityWithCollagenBoundary(x,y,patchquantity,QuantNameString,Patches.pcolor)
% QuantNameString = 'pcolor';
% patchquantity = Patches.pcolor;
% plotPatchQuantity(x,y,patchquantity,QuantNameString)

colormatrix = zeros(length(Patches.pcolor),3);
for i = 1:length(Patches.pcolor)
    if Patches.pcolor(i) == 117
        colormatrix(i,:) = [176 150 200]./255;
    elseif Patches.pcolor(i) == 115
        colormatrix(i,:) = [124 80 164]./255;
    else
        colormatrix(i,:) = [255 255 255]./255;
    end
end

mymap = [176 150 200; 124 80 164; 255 255 255]./255;

QuantNameString = 'colormatrix';
patchquantity = colormatrix;
plotPatchQuantity(x,y,patchquantity,QuantNameString)


function plotPatchQuantity(x,y,patchquantity,QuantNameString)
x_unique = unique(x);
y_unique = unique(y);

% Initialize matrix to hold averaged values
Z = nan(length(y_unique), length(x_unique));  % Preallocate with NaNs

% Compute average patch_tgfbeta for each (x, y) patch
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
xlabel('X Coordinate');
ylabel('Y Coordinate');
zlabel(QuantNameString);
title([QuantNameString, ' at Patches']);
view(3);
figure;
s=pcolor(X, Y, Z);
xlabel('X Coordinate');
ylabel('Y Coordinate');
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

% Initialize matrix to hold averaged values
Z = nan(length(y_unique), length(x_unique));  % Preallocate with NaNs
cumulative_number_alveoli_spread = 0;
% Compute average patch_tgfbeta for each (x, y) patch
for i = 1:length(x_unique)
    for j = 1:length(y_unique)
        % Find indices matching current patch
        idx = (x == x_unique(i)) & (y == y_unique(j));
        
        % If there are values, compute the mean
        if any(idx)
            if patchcolor(idx) >9.9
                Z(j, i) = patchquantity (idx);
            else 
                Z(j, i) = NaN;
                if patchquantity (idx) > 0
                    cumulative_number_alveoli_spread = cumulative_number_alveoli_spread + 1 ;
                end
            end
        end
    end
end


cumulative_number_alveoli_spread
% Create meshgrid for plotting
[X, Y] = meshgrid(x_unique, y_unique);


figure;
s=pcolor(X, Y, Z);
xlabel('X Coordinate');
ylabel('Y Coordinate');
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

mymap = [176 150 200; 124 80 164; 255 255 255]./255;
colormap(mymap)