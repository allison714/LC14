%% 1. Search the database for paths for data to analyze

sensor = 'GC6f';
cellType = 'LC14';
flyEye = ''; % leave empty unless you do surgeries on both eyes
surgeon = 'Allison';
stim  = 'Bars_Abrupt_001';
dP = 8;




% this should return a cell array with paths to the data (on server)
% make sure your sysConfig.csv is correctly pointing to the path of the
% database / servers
dataPath = GetPathsFromDatabase(cellType,stim,sensor,flyEye,surgeon);

%% 2. Define analysis parameters
% Use a watershed algorithm to define ROIs based on time-averaged frames
% and restrict that manually to neuropils you care etc.
roiExtractionFile = 'WatershedRegionRestrictedRoiExtraction';
roiRegion = 'lobula';

% Thresholding on correlations between multiple repetitions of probe
% stimuli (defaulted at r = .4). This will pass ROIs that were consistently
% responding to the probe regardless of HOW they were responding
roiSelectionFile  = '';


% Just plot average time traces
analysisFiles = {'PlotTimeTraces'};

% input argument for analysis function
% Most of them are unused but here to make defaults explicit
args = {'analysisFile',analysisFiles,...
    'dataPath',dataPath{dP},...
    'roiExtractionFile',roiExtractionFile,...
    'roiSelectionFile',roiSelectionFile,...
    'forceRois',0,... % set to 1 to redo ROI extraction
    'individual',1,...
    'backgroundSubtractMovie', 0,... % see manual for these
    'backgroundSubtractByRoi', 1,...
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


figure;
plot(a.analysis{1}.respMatPlot);

% Pull out Trial-averaged but not ROI-averaged responses (from Fly #1)
p6 = a.analysis{1}.indFly{1}.p6_averagedTrials.snipMat;
% permute dimensions so that the dimension of epochs are the third
% dimension
p6 = permute(p6,[3,2,1]);
% Convert a cell array to a matrix so that it's easier to plot
% p6mat should be a 3D matrix with time x ROI x epoch dimensions
p6mat = cell2mat(p6);
% for example, visualize the dF/F responses of all ROIs to epoch #1
m = ones(1,10);
m = m*60;
m(2:2:10) = m(2:2:10) *-1;
o = 1:10;

o(1:2:7) = -120:30:-30;
o(2:2:8) = 120:-30:30;
o(9) = -135;
o(10) = 135;
%%
figure('units','normalized','outerposition',[0 0 1 1]);
for n = 1:10
    subplot(5,2,n)   
    imagesc(p6mat(:,:,n));
    title(sprintf('theta = %d, v = %d', o(n),m(n)))
    xlabel('ROI')
    ylabel('t')
    sgtitle(sprintf('DataPath{%d}', dP))
end
%%
savetime = datestr(now, 'mmddyy');
filename = sprintf('%s_BarsAbrupt_dP.png',savetime,dP);
saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Imaging', filename),'png')
% imagesc(p6mat(:,:,1));

%%
% 10 epochs
% alternating + - 60
% x = - + 120, 90, 60, 30, 135
