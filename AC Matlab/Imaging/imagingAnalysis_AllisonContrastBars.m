% imagingAnalysis_AllisonContrastBars
% I used RT's template from Google Drive and altered it for my paramfile
% 'AllisonContrastBars'

%% 1. Search the database for paths for data to analyze

sensor = 'GC6f';
cellType = 'LC14';
flyEye = ''; % leave empty unless you do surgeries on both eyes
surgeon = 'Allison';
stim  = 'AllisonContrastBars01';
dP = [19]; % input this into datapath so .pngs save with proper title name
% *** Note: if there are more ts change the rows/ columns of
% subplots to accomodate > 80

% this should return a cell array with paths to the data (on server)
% make sure your sysConfig.csv is correctly pointing to the path of the
% database / servers

%% Garrett Sager helped me with this part:
dataPath_all = GetPathsFromDatabase(cellType,stim,sensor,flyEye,surgeon);

dataPath = cell( length(dP), 1 );

count = 0;
for i = 1 : length(dataPath_all)
    if any( i == dP )
%         we want this fly
        count = count + 1;
        dataPath{count} = dataPath_all{ i };
    end
    
end

%% 2. Define analysis parameters
% Use a watershed algorithm to define ROIs based on time-averaged frames
% and restrict that manually to neuropils you care etc.
roiExtractionFile = 'WatershedRegionRestrictedRoiExtraction';
roiRegion = 'lobula';

% Thresholding on correlations between multiple repetitions of probe
% stimuli (defaulted at r = .4). This will pass ROIs that were consistently
% responding to the probe regardless of HOW they were responding
roiSelectionFile  = '';
% input selectROIbyProbeCorrelationGeneric above

% Just plot average time traces
analysisFiles = {'PlotTimeTraces'};

% input argument for analysis function
% Most of them are unused but here to make defaults explicit
args = {'analysisFile',analysisFiles,...
    'dataPath',dataPath,... % go to line 5 to change this so .png titles stay consistent
    'roiExtractionFile',roiExtractionFile,...
    'roiSelectionFile',roiSelectionFile,...
    'forceRois',0,... % set to 1 to redo ROI extraction
    'individual',1,...
    'backgroundSubtractMovie', 1,... % see manual for these
    'backgroundSubtractByRoi', 0,...
    'calcDFOverFByRoi',1,...
    'combOpp',0,...
    'epochsForIdentificationForFly',1,...
    'roiRestrictionRegion',roiRegion,...
    'epochsForSelectivity',{'dummy'},...
    'stimulusResponseAlignment',0,...
    'reassignEpochs','',...
    'noTrueInterleave',0,...
    'perRoiDfOverFCalcFunction','CalculatedDeltaFOverFByROI',...
    'overallCorrelationThresh',0.4,... % only use pre-stimulus probe correlation for selection (usually enough)
    'corrToThirdThresh',-2};
a = RunAnalysis(args{:});

%% 3. Postprocessing
% "a" struct contains the results of all analysis. What it contains depends
% on the analysisFile you specify. See the manual for details


%load('Z:\2p_microscope_data\+;LC14AD_UASGC6f;LC14DBD_+\AllisonContrastBars01\2021\06_24\16_58_21\stimulusData\stimdata.mat')
% figure;
% subplot(3,1,1)
% % plot( stimData(:,3) )
% subplot(3,1,[2:3])
% plot(a.analysis{1}.respMatPlot);
% xlabel('time (s)')
% ylabel('delta F/ F')
% saveas(gcf,sprintf('epochROI_00%d.png', dP))

%%
% Pull out Trial-averaged but not ROI-averaged responses (from Fly #1)
p6 = a.analysis{1}.indFly{1}.p6_averagedTrials.snipMat;
% permute dimensions so that the dimension of epochs are the third
% dimension
p6 = permute(p6,[3,2,1]);
% Convert a cell array to a matrix so that it's easier to plot
% p6mat should be a 3D matrix with time x ROI x epoch dimensions
p6mat = cell2mat(p6);

%% White Bars from theta -90:5:90
numROIs = length(p6(1,1,:));
theta = -90:5:90; % subtitle names
figure('units','normalized','outerposition',[0 0 1 1]);
for i = 1:numROIs/2
    subplot(8,5,i)
    imagesc(p6mat(:,:,i));
    title(sprintf('theta = %d', theta(i)))
    xlabel('ROI')
    ylabel('t')
end
sgtitle('White Bars')
saveas(gcf,sprintf('WhiteDeltaTheta_00%d.png', dP))

%% Black Bars from theta -90:5:90
figure('units','normalized','outerposition',[0 0 1 1]);
for ii = 1:numROIs/2
    subplot(8,5,ii)
    imagesc(p6mat(:,:,ii + numROIs/2));
    title(sprintf('theta = %d', theta(ii)))
    xlabel('ROI')
    ylabel('t')
end
sgtitle('Black Bars')
saveas(gcf,sprintf('BlackDeltaTheta_00%d.png', dP))

%% Comparison of white and black bars at the same position (theta)
figure('units','normalized','outerposition',[0 0 1 1]);
for iii = 1:numROIs/2
    subplot(8,5,iii)
    plot(a.analysis{1}.respMatPlot(:,iii));
    hold on
    plot(a.analysis{1}.respMatPlot(:,iii+numROIs/2));
    hold off
    title(sprintf('theta = %d', theta(iii)))
    % the plots were too small to insert a legend
    % legend('white','black', 'Location','best')
    sgtitle('White Bars (Blue), Black Bars (Red) at the same location (Theta)')
end
saveas(gcf,sprintf('B&WsameTheta_00%d.png', dP))

%% 4 plots per subplot: B&W and +/- theta
figure('units','normalized','outerposition',[0 0 1 1]);
theta2 = -90:5:0;
for iii = 1: round(numROIs/4)-1
    subplot(4,5,iii)
    plot(a.analysis{1}.respMatPlot(:,iii));
    hold on
    plot(a.analysis{1}.respMatPlot(:,1+numROIs/2-iii));
    hold on
    plot(a.analysis{1}.respMatPlot(:,numROIs/2+iii));
    hold on
    plot(a.analysis{1}.respMatPlot(:,1+numROIs-iii));
    hold off
    title(sprintf('theta = +/ %d', theta2(iii)))
    % this next section is for zeros (there will only be two)
    % **** remember to account for this when using other DataPaths
    subplot(4,5,iii+1)
    plot(a.analysis{1}.respMatPlot(:,numROIs/4+0.5)); % white bar, epoch 19
    hold on
    plot(a.analysis{1}.respMatPlot(:,numROIs - numROIs/4+0.5)); % black, epoch 56
    hold off
    title('theta = 0')
    sgtitle('White (- theta): Blue --- White (+ theta): Red --- Black (-): Yellow --- Black (+): Purple')
end
% saveas(gcf,sprintf('B&WsymmTheta_00%d.png', dP))
% %% Avg response v theta for White Bars
% figure;
% avga = 1:37;
% for v = 1:37 % white
%     avga(v) = mean(a.analysis{1}.respMatPlot(:,v));
%     plot(theta(v),avga(v),'*')
%     hold on
% end
% plot(theta,avga(1:37),'b')
% xlabel('theta')
% ylabel('avg delta f/ f')
% title('Avg response for White Bars')
% saveas(gcf,sprintf('avgWht_00%d.png', dP))
% %% Avg response v theta Black
% figure;
% for vi = 38:74 % black
%     avgb(vi) = mean(a.analysis{1}.respMatPlot(:,vi));
% end
% avgc = avgb(38:74)
% for vii = 1:37
%     plot(theta(vii),avgc(vii),'*')
%     hold on
% end
% plot(theta,avgc(1:37),'r')
% xlabel('theta')
% ylabel('avg delta f/ f')
% title('Avg response for Black Bars')
% saveas(gcf,sprintf('avgBlk_00%d.png', dP))
% %% Both avg overlap
% figure;
% plot(theta,avga(1:37),'b*-')
% hold on
% plot(theta,avgc(1:37),'r*-')
% xlabel('theta')
% ylabel('avg delta f/ f')
% title('Black and White Bars')
% hold on
% for vii = -90:5:90
%     xline(vii,':')
% end
%
% % saveas(gcf,sprintf('avgB&W_00%d.png', dP))
%
% %%
% % %% For example, you can replot only some of the epochs you care like this:
% % timeX = a.analysis{1,1}.timeX/1000; % converting ms to s
% % meanmat = a.analysis{1,1}.respMatPlot;
% % semmat  = a.analysis{1,1}.respMatSemPlot;
% % % Use in-house prettier plot functions for visualization...
% % MakeFigure; hold on
% % % showing only first three epochs
% % PlotXvsY(timeX,meanmat(:,1:3,1),'error',semmat(:,1:3,1));
% % PlotConstLine(0,1); % horizontal 0 line
% % PlotConstLine(0,2); % vertical 0 line
% % ConfAxis('labelX','time (s)','labelY','')

%%
% Plotting individual ROIs
ROIs = length(p6mat(1,:,1));
% theta = -90:5:90; % subtitle names
figure('units','normalized','outerposition',[0 0 1 1]);

for qq = 1:3
    for viii = 1:ROIs/2
        subplot(9,5,viii)
        plot(p6mat(:,viii,qq));
        %     title(sprintf('theta = %d', theta(i)))
        %     xlabel('ROI')
        %     ylabel('t')
        hold on
        yline(0,':')
        hold on
        xline(10,':')
        hold on
        xline(20,':')
        hold on
%         hold on
%         plot(p6mat(:,viii,qq));
%         hold off
    end
end
% sgtitle('White Bars')
% saveas(gcf,sprintf('WhiteDeltaTheta_00%d.png', dP))

%% ROI plot of Epochs vs time
test01 = permute(p6,[1,3,2]);
test01 = cell2mat(test01);
%%
figure('units','normalized','outerposition',[0 0 1 1]);
% White Bars // Troubleshoot for dP{5}, ROI = 113
position = [-90:5:90];
for ww = 1:30
    subplot(6,5,ww)
    imagesc(test01(:,1:38,ww));
    % xlabel('epochs 1-74')
    ylabel('')
    title(sprintf('ROI %d', ww))
    sgtitle('1')
        xticks([1:6:38])
        xticklabels({'-90','-60','-30','0','30','60','90'})
   
end
%
figure('units','normalized','outerposition',[0 0 1 1]);
for ww = 31:60
    subplot(6,5,ww-30)
    imagesc(test01(:,1:38,ww));
    % xlabel('epochs 1-74')
    ylabel('')
    title(sprintf('ROI %d', ww))
    sgtitle('2')
            xticks([1:6:38])
        xticklabels({'-90','-60','-30','0','30','60','90'})
end
figure('units','normalized','outerposition',[0 0 1 1]);
for ww = 61:74
    subplot(3,5,ww-60)
    imagesc(test01(:,1:38,ww));
    % xlabel('epochs 1-74')
    ylabel('')
    title(sprintf('ROI %d', ww))
    sgtitle('3')
            xticks([1:6:38])
        xticklabels({'-90','-60','-30','0','30','60','90'})
       
end
%%
figure('units','normalized','outerposition',[0 0 1 1]);
for ww = 91:120
    subplot(6,5,ww-90)
    imagesc(test01(:,1:38,ww));
    % xlabel('epochs 1-74')
    ylabel('')
    title(sprintf('ROI %d', ww))
    sgtitle('4')
            xticks([1:6:38])
        xticklabels({'-90','-60','-30','0','30','60','90'})
       
end
figure('units','normalized','outerposition',[0 0 1 1]);
for ww = 121:150
    subplot(6,5,ww-120)
    imagesc(test01(:,1:38,ww));
    % xlabel('epochs 1-74')
    ylabel('')
    title(sprintf('ROI %d', ww))
    sgtitle('5')
            xticks([1:6:38])
        xticklabels({'-90','-60','-30','0','30','60','90'})
end
% figure('units','normalized','outerposition',[0 0 1 1]);
% for ww = 151:length(p6mat(1,:,1))
%     subplot(round((length(p6mat(1,:,1))-149)/5),5,ww-150)
%     imagesc(test01(:,1:38,ww))
%     % xlabel('epochs 1-74')
%     ylabel('')
%     title(sprintf('ROI %d', ww))
%     sgtitle('6')
%             xticks([1:6:38])
%         xticklabels({'-90','-60','-30','0','30','60','90'})
% end
%% I messed up
% figure('units','normalized','outerposition',[0 0 1 1]);
% for uu = 1:3
%     %subplot(7,5,uu)
%     imagesc(test01(:,[33:74],uu));
%     hold on
%    % xlabel('epochs 1-74')
% %     ylabel('')
% %     title(sprintf('ROI %d,  theta = %d', uu, position(uu)))
% %     sgtitle('Black Bars')
% end