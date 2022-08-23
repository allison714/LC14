function symmTurnRSB1(timeX, meanturnresp, semturnresp, genotypes, out, RSB1epoch1, RSB1epoch2, plotLength, RSB1title, tEpochs)
% Output figure with top subplot of symm, two below as R, L, then stats
% detailed notes on symmWalkRSB1
%% Set up for saving the image
savetime = datestr(now, 'mmddyy');
% make figure full screen
figure('units','normalized','outerposition',[0 0 1 1])
tickX = [];
tickY = [];
tickLabelX = [];
tickLabelY = [];
fTitle = [];
figLeg = cell(0,1);
labelX = [];
labelY = [];
rotateLabels = 0;
axisFontSize = 12;
labelFontSize = 14;
titleFontSize = 18;
useLatex = true;
set(gca,'FontSize',axisFontSize,'box','off','FontName','Arial');
set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0]);
set(findall(gca, 'Type', 'Line'),'LineWidth',2,'MarkerSize',8);
set(findall(gca, 'Type', 'ErrorBar'),'LineWidth',2,'MarkerSize',8);
%     set(gca,'TickLabelInterpreter',interpreterStr);
ax = gca;
ax.YLabel.FontSize = labelFontSize;
ax.XLabel.FontSize = labelFontSize;
ax.LineWidth = 2;

%% Subplot 1: R&L combined, first and second epoch combined
% first epoch in subplot 1
subplot(9,2,[1:4])
hold on % I forgot if I actually need this line...test later
timeXshort = timeX(timeX<plotLength); % length of epoch + s before and after
PlotXvsY(timeXshort,permute(meanturnresp(timeX<plotLength,RSB1epoch1,:),[1,3,2]),... % epoch
    'error',permute(semturnresp(timeX<plotLength,RSB1epoch1,:),[1,3,2])); % epoch
% vertical and horizontal lines
PlotConstLine(0,1);
PlotConstLine(0,2);
PlotConstLine(tEpochs(RSB1epoch1)/60,2);
hold on
% second epoch in subplot
PlotXvsY(timeXshort,permute(meanturnresp(timeX<plotLength,RSB1epoch2,:),[1,3,2]),... % epoch
    'error',permute(semturnresp(timeX<plotLength,RSB1epoch2,:),[1,3,2])); % epoch
ylabel('Turning (deg/s)');
title('Combined');
legend(genotypes);
legend boxoff;  

%% subplot 2: first epoch
subplot(9,2,[7,8])
hold on
timeXshort = timeX(timeX<plotLength);
PlotXvsY(timeXshort,permute(meanturnresp(timeX<plotLength,RSB1epoch1,:),[1,3,2]),... % epoch
    'error',permute(semturnresp(timeX<plotLength,RSB1epoch1,:),[1,3,2])); % epoch
PlotConstLine(0,1);
PlotConstLine(0,2);
PlotConstLine(tEpochs(RSB1epoch1)/60,2);
ylabel('turning (deg/s)');
title(RSB1title(RSB1epoch1));
legend(genotypes);
legend boxoff;  

%% subplot 3: second epoch
subplot(9,2,[11,12])
hold on
timeXshort = timeX(timeX<plotLength);
PlotXvsY(timeXshort,permute(meanturnresp(timeX<plotLength,RSB1epoch2,:),[1,3,2]),... % epoch
    'error',permute(semturnresp(timeX<plotLength,RSB1epoch2,:),[1,3,2])); % epoch
PlotConstLine(0,1);
PlotConstLine(0,2);
PlotConstLine(tEpochs(RSB1epoch1)/60,2);
ylabel('turning (deg/s)');
title(RSB1title(RSB1epoch2));
legend(genotypes);
legend boxoff; 

%% subplot 4: epoch 1&2 error bars
subplot(9,2,[15,18])
for gg = 1:3
    thisIndFly = out{gg}.analysis{1}.indFly;
    nFly = length(thisIndFly);
    meanturn = [];
    for ff = 1:nFly
        % pull out individual fly results (in cell)
        thisFlyData = thisIndFly{ff}.p8_averagedRois.snipMat;
        % convert a cell into a matrix (easier to work on)
        thisFlyMat = cell2mat(permute(thisFlyData,[2,1,3]));
        % Turning: z = 1, walking: z = 2
        meanturn(ff,:) = mean(thisFlyMat(timeX>0 & timeX<0.5,RSB1epoch2,1)); % epoch, !!!!!! 0.5? --------
        
    end
    meanrespcell{gg} = meanturn;
end
easyBarStats(meanrespcell,'conditionNames',genotypes,'newFigure',0);
ylabel('turning (deg/s)')
title(sprintf('Stats'))
hold off

%%
filename = sprintf('%s_RSB1_turn_%d_%d.png',savetime,RSB1epoch1,RSB1epoch2);
saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior', filename),'png')
end