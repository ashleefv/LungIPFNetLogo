clear all
close all

csv_filename = 'spreadsheet.csv';
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

figure(1)
ReporterNumber = 1;
timesteps = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber};
ReporterNumber = 2;
total_world_collagen = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber};
% should add legend with DisplayName across runs
plot(timesteps,total_world_collagen)
xlabel('timesteps')
ylabel('total world collagen')

figure(2)
ReporterNumber = 3;
percent_pixel_collagen = RunData{:,ReporterNumber:numReporters:finalColIndexStart-numReporters+ReporterNumber};
% should add legend with DisplayName across runs
plot(timesteps,percent_pixel_collagen)
xlabel('timesteps')
ylabel('percent pixel collagen')

RunParams{:,1}
for rowIndex = 2:numRunParams+1
    % Extract the row as a cell array
    rowData = table2array(RunParams(rowIndex, 2:end));
    
    % Find unique values in the row
    uniqueValues = unique(rowData);
    
    % Display results
    disp(strjoin(['Unique values in row'  num2str(rowIndex) 'for' string(RunParams{rowIndex,1})]))
    disp(uniqueValues);
end


% [A B C D E F G H I J K L M N O ...
%    P Q R S T U V W X Y Z ...
%    AA AB AC AD] = csvimport('csv_filename', 'columns',{'step1', 'total_world_collagen1', 'percent-pixel-collagen1',...
%    'step2', 'total_world_collagen2', 'percent-pixel-collagen2', 'step3', 'total_world_collagen3', 'percent-pixel-collagen3'...
%    'step4', 'total_world_collagen4', 'percent-pixel-collagen4',...
%    'step5', 'total_world_collagen5', 'percent-pixel-collagen5',...
%    'step6', 'total_world_collagen6', 'percent-pixel-collagen6', ...
%    'step7', 'total_world_collagen7', 'percent-pixel-collagen7', ...
%    'step8', 'total_world_collagen8', 'percent-pixel-collagen8',...
%    'step9', 'total_world_collagen9', 'percent-pixel-collagen9', ...
%    'step10', 'total_world_collagen10', 'percent-pixel-collagen10'});


% tt = tiledlayout(1,numberRuns); 
% 
% nexttile(tt);

% A_wo = rmmissing(A);
% for i = 1:length(A_wo)
%     step1(i)=str2num(A_wo{i});
% end
% 
% D_wo = rmmissing(D);
% for i = 1:length(D_wo)
%     step2(i)=str2num(D_wo{i});
% end
% 
% G_wo = rmmissing(G);
% for i = 1:length(G_wo)
%     step3(i)=str2num(G_wo{i});
% end
% 
% J_wo = rmmissing(J);
% for i = 1:length(J_wo)
%     step4(i)=str2num(J_wo{i});
% end
% 
% 
% step5 = M';
% 
% P_wo = rmmissing(P);
% for i = 1:length(P_wo)
%     step6(i)=str2num(P_wo{i});
% end
% 
% S_wo = rmmissing(S);
% for i = 1:length(S_wo)
%     step7(i)=str2num(S_wo{i});
% end
% 
% V_wo = rmmissing(V);
% for i = 1:length(V_wo)
%     step8(i)=str2num(V_wo{i});
% end
% 
% Y_wo = rmmissing(Y);
% for i = 1:length(Y_wo)
%     step9(i)=str2num(Y_wo{i});
% end
% 
% AB_wo = rmmissing(AB);
% for i = 1:length(AB_wo)
%     step10(i)=str2num(AB_wo{i});
% end
% 
% 
% 
% %% Pixel
% pixel1_wo = rmmissing(C);
% for j = 1:length(pixel1_wo)
%     pixel1(j)=str2num(pixel1_wo{j});
% end
% 
% pixel2_wo = rmmissing(F);
% for j = 1:length(pixel2_wo)
%     pixel2(j)=str2num(pixel2_wo{j});
% end
% 
% pixel3_wo = rmmissing(I);
% for j = 1:length(pixel3_wo)
%     pixel3(j)=str2num(pixel3_wo{j});
% end
% 
% pixel4_wo = rmmissing(L);
% for j = 1:length(pixel4_wo)
%     pixel4(j)=str2num(pixel4_wo{j});
% end
% 
% pixel5 =O';
% % pixel5_wo = rmmissing(O);
% % for j = 1:length(pixel5_wo)
% %     pixel5(j)=str2num(pixel5_wo{j});
% % end
% 
% pixel6_wo = rmmissing(R);
% for j = 1:length(pixel6_wo)
%     pixel6(j)=str2num(pixel6_wo{j});
% end
% 
% pixel7_wo = rmmissing(U);
% for j = 1:length(pixel7_wo)
%     pixel7(j)=str2num(pixel7_wo{j});
% end
% 
% pixel8_wo = rmmissing(X);
% for j = 1:length(pixel8_wo)
%     pixel8(j)=str2num(pixel8_wo{j});
% end
% 
% pixel9_wo = rmmissing(AA);
% for j = 1:length(pixel9_wo)
%     pixel9(j)=str2num(pixel9_wo{j});
% end
% 
% pixel10_wo = rmmissing(AD);
% for j = 1:length(pixel10_wo)
%     pixel10(j)=str2num(pixel10_wo{j});
% end
% 
% 
% 
% 
% total1_wo = rmmissing(B);
% for j = 1:length(total1_wo)
%     total1(j)=str2num(total1_wo{j});
% end
% 
% total2_wo = rmmissing(E);
% for j = 1:length(total2_wo)
%     total2(j)=str2num(total2_wo{j});
% end
% 
% total3_wo = rmmissing(H);
% for j = 1:length(total3_wo)
%     total3(j)=str2num(total3_wo{j});
% end
% 
% total4_wo = rmmissing(K);
% for j = 1:length(total4_wo)
%     total4(j)=str2num(total4_wo{j});
% end
% 
% total5= N;
% % for j = 1:length(total5_wo)
% %     total5(j)=str2num(total5_wo{j});
% % end
% 
% total6_wo = rmmissing(Q);
% for j = 1:length(total6_wo)
%     total6(j)=str2num(total6_wo{j});
% end
% 
% total7_wo = rmmissing(T);
% for j = 1:length(total7_wo)
%     total7(j)=str2num(total7_wo{j});
% end
% 
% total8_wo = rmmissing(W);
% for j = 1:length(total8_wo)
%     total8(j)=str2num(total8_wo{j});
% end
% 
% total9_wo = rmmissing(Z);
% for j = 1:length(total9_wo)
%     total9(j)=str2num(total9_wo{j});
% end
% 
% total10_wo = rmmissing(AC);
% for j = 1:length(total10_wo)
%     total10(j)=str2num(total10_wo{j});
% end
 

% figure(1)

% plot(step1,pixel1,'LineWidth',2)
% hold on
% plot(step2,pixel2,'LineWidth',2)
% plot(step3,pixel3,'LineWidth',2)
% plot(step4,pixel4,'LineWidth',2)
% plot(step5,pixel5,'LineWidth',2)
% plot(step6,pixel6,'LineWidth',2)
% plot(step7,pixel7,'LineWidth',2)
% plot(step8,pixel8,'LineWidth',2)
% plot(step9,pixel9,'LineWidth',2)
% plot(step10,pixel10,'LineWidth',2)
% grid on

% figure(2)
%  plot(step1,total1,'LineWidth',2)
% hold on
% plot(step2,total2,'LineWidth',2)
% plot(step3,total3,'LineWidth',2)
% plot(step4,total4,'LineWidth',2)
% plot(step5,total5,'LineWidth',2)
% plot(step6,total6,'LineWidth',2)
% plot(step7,total7,'LineWidth',2)
% plot(step8,total8,'LineWidth',2)
% plot(step9,total9,'LineWidth',2)
% plot(step10,total10,'LineWidth',2)
% grid on