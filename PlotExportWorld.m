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

QuantNameString = 'patch\_tgfbeta';
patchquantity = Patches.patch_tgfbeta;
plotPatchQuantity(x,y,patchquantity,QuantNameString)

function plotPatchQuantity(x,y,patchquantity,QuantNameString)
x_unique = unique(x);
y_unique = unique(y);

% Initialize matrix to hold averaged values
Z = nan(length(y_unique), length(x_unique));  % Preallocate with NaNs

% Compute average patch_tgfbeta for each (x, y) grid point
for i = 1:length(x_unique)
    for j = 1:length(y_unique)
        % Find indices matching current grid point
        idx = (x == x_unique(i)) & (y == y_unique(j));
        
        % If there are values, compute the mean
        if any(idx)
            Z(j, i) = mean(patchquantity (idx));
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
title(['Average', QuantNameString, ' at Grid Points']);
view(3);
figure;
heatmap(Z)
end