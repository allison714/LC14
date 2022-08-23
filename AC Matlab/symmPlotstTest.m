function symmPlotstTest(stimName, timeX, respResp, out, genotypes, specificEpoch, epochTitlePH)
% Created 08.2021 by AC based off RT's code 'easyBarStats', tons of help from RT and GS
% Subplot 1: Walking, 2: Turning of symm epochs, 3,4: t-test
% RT:  Signed-rank is used when the data is paired and rank-sum when not
% paired (i.e. data is provided as a cell array rather than as a matrix).
% -this is in 'easyBarStatsSymm.m'

%% Set up for saving the image
saveDate = datestr(now, 'mmddyy');
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
% set(gca,'TickLabelInterpreter',interpreterStr);
ax = gca;
ax.YLabel.FontSize = labelFontSize;
ax.XLabel.FontSize = labelFontSize;
ax.LineWidth = 2;

%% --- 08.30.21 edit ---
% A. Epoch Title
placeHolder = out{1,1}.inputs.params;
% placeHolderTest = placeHolder{1,1}(25).epochName % Test: change the parenthesis value to change epoch name
epochTot = size(out{1,1}.inputs.params{1,1});
% --- this next part is only needed since it is a string
epochTitle = textscan(epochTitlePH,'%s','Delimiter',',')';
% ---
epochTitle = epochTitle{1,1};
epochTitle = epochTitle(2:end);
% for future use, just change '.epochName' to whatever
if length(char('sinMir_VcontFreq_rot_lam30_C025_180Hz')) == 37
    a = 1;
elseif stimName ~= char('sinMir_VcontFreq_rot_lam30_C025_180Hz')
    a = 0;
end
for aa = 1:epochTot(2)
    if size(placeHolder{1,1})== [1, 33] & a == 1
        epochTitle = [];
        epochTitle(aa) = placeHolder{1,1}(aa).temporalFrequency;
    else
        epochTitle(aa) = cellstr(placeHolder{1,1}(aa).epochName);
    end
end
if length(char('sinMir_VcontFreq_rot_lam30_C025_180Hz')) ~= 37 & a ~= 1 % test this with RSB, put breakpoint and make sure epochTitle changes '_' -> ' '
    epochTitle = regexprep(epochTitle(2:end), '_', ' '); % replace '_' with ' '
end
% B. Duration
for aa = 1:epochTot(2)
    tEpochs(aa) = placeHolder{1,1}(aa).duration;
end
tEpochs = tEpochs(2:end);
% this next part is necessary to reduce total -> total / 2 when combining L/R
tEpochs = tEpochs(1:2:end);
% ---
if tEpochs(specificEpoch) < 0.500001 * 60
    plotLength = 3.5; % (s)
else
    plotLength = (tEpochs(specificEpoch) / 60) + 2.5; % 2.5 s = 0.5 s Before epoch + 2.5 s after epoch
end
% ---

% --- AC ---
%% Subplot 1: Walking
% first epoch in subplot 1
subplot(8,2,[1:4])
hold on % I forgot if I actually need this line...test later
timeXshort = timeX(timeX<plotLength); % length of epoch + s before and after
PlotXvsY(timeXshort,permute(respResp.meanwalkresp(timeX<plotLength,specificEpoch,:),[1,3,2]),...
    'error',permute(respResp.semwalkresp(timeX<plotLength,specificEpoch,:),[1,3,2])); % input
% vertical and horizontal lines
PlotConstLine(0,1);
PlotConstLine(0,2);
PlotConstLine(tEpochs(specificEpoch)/60,2); % input
ylabel('Walking (deg/s)');
title([epochTitle(specificEpoch*2-1),'+', epochTitle(specificEpoch*2)])
legend(genotypes);
legend boxoff;


%% Subplot 2: Turning
subplot(8,2,[7:10])
hold on
timeXshort = timeX(timeX<plotLength);
PlotXvsY(timeXshort,permute(respResp.meanturnresp(timeX<plotLength,specificEpoch,:),[1,3,2]),...
    'error',permute(respResp.semturnresp(timeX<plotLength,specificEpoch,:),[1,3,2])); % input (turn)
PlotConstLine(0,1);
PlotConstLine(0,2);
PlotConstLine(tEpochs(specificEpoch)/60,2); % input
ylabel('Turning (deg/s)');

legend(genotypes);
legend boxoff;
% ---
% --- RT ---
%% Subplot 3: SEM walking
subplot(8,2,[13,15])
for gg = 1:3
    thisIndFly = out{gg}.analysis{1}.indFly;
    nFly = length(thisIndFly);
    meanwalk = [];
    for ff = 1:nFly
        % pull out individual fly results (in cell)
        thisFlyData = thisIndFly{ff}.p8_averagedRois.snipMat;
        % convert a cell into a matrix (easier to work on)
        thisFlyMat = cell2mat(permute(thisFlyData,[2,1,3]));
        
        meanwalk(ff,:) = mean(thisFlyMat(timeX>0 & timeX<(tEpochs(specificEpoch)/60),specificEpoch,2)); % (x,y,turn/walk) walk = 2
        
    end
    meanrespcell{gg} = meanwalk;
end

easyBarStatsSymm(meanrespcell, specificEpoch, 'conditionNames',genotypes,'newFigure',0);
% easyBarStatsPrint(specificEpoch, stimName, meanrespcell,'conditionNames',genotypes,'newFigure',0);
ylabel('Walking (deg/s)')
title(sprintf('Walking Stats'))
hold off

%% Subplot 4: SEM turning
subplot(8,2,[14,16])
for gg = 1:3
    thisIndFly = out{gg}.analysis{1}.indFly;
    nFly = length(thisIndFly);
    meanturn = [];
    for ff = 1:nFly
        % pull out individual fly results (in cell)
        thisFlyData = thisIndFly{ff}.p8_averagedRois.snipMat;
        % convert a cell into a matrix (easier to work on)
        thisFlyMat = cell2mat(permute(thisFlyData,[2,1,3]));
        
        meanturn(ff,:) = mean(thisFlyMat(timeX>0 & timeX<(tEpochs(specificEpoch)/60),specificEpoch,1)); % (x,y,turn/walk) turn = 1
        
    end
    meanrespcell{gg} = meanturn;
end

easyBarStatsSymm(meanrespcell, specificEpoch, 'conditionNames',genotypes,'newFigure',0);
ylabel('Turning (deg/s)')
title(sprintf('Turning Stats'))
hold off
% ---
% --- AC ---
sg = sgtitle(sprintf('%s, Epoch %d', regexprep(stimName, '_', ' '), specificEpoch));
sg.FontSize = 24;

filename = sprintf('%s_%s_symmBA_%d.png', saveDate, stimName, specificEpoch);
saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior', filename),'png') % change to your folder ***
end
% ---