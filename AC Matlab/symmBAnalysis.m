clc; clear all; close all; saveDate = datestr(now, 'mmddyy'); % for save file name in 'symmPlotstTest.m'
%%
% Future edits: Location of dlg boxes, dropbox + typing input
%
% Allison Cairns 08.2021
% Walking and Turing Plots: 0.5 s Before epoch + epoch duration + 2.5 s after epoch
% first step: make sure 'combOpp'= 1 to make epochs symmetric
% Your paramfile must either have Stimulus.duration or
% Stimulus.temporalFrequency as a field in your paramfile for this to work

% Dialog Box
prompt = {'What is the Paramfile Title? '}
dlgTitle = 'Paramfile Title';
boxDims = [1 50;];
presetInput = {'sinMir_VcontFreq_rot_lam30_C025_180Hz'};

% Dialog Box Answers
stimName = char(inputdlg(prompt,dlgTitle,boxDims,presetInput));

%% Dialog Box
prompt = {'How many epochs are there? (i.e. 3 epochs = [apostrophe 1,2,3 apostrophe]'}
dlgTitle = 'Follow Format';
boxDims = [1 50;];
presetInput = {['']}; % preallocate
if length(stimName) == length(char('RegressiveSlowingBattery1'))
    if stimName == char('RegressiveSlowingBattery1')
        presetInput = {['1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24']};
    end
elseif length(stimName) == length(char('sinMir_VcontFreq_rot_lam30_C025_180Hz'))
    if stimName == char('sinMir_VcontFreq_rot_lam30_C025_180Hz')
        presetInput = {['1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36']};
    end % continue to add to this
elseif length(stimName) == length(char('Bars_Abrupt_01'))
    if stimName == char('Bars_Abrupt_01')
        presetInput = {['1,2,3,4,5,6,7,8,9,10']};
    end % continue to add to this
elseif length(stimName) == length(char('Bars_Squares_AC_01'))
    if stimName == char('Bars_Squares_AC_01')
        presetInput = {['1,2,3,4,5,6']};
    end % continue to add to this
end

%% Dialog Box Answers
epochTitlePH = char(inputdlg(prompt,dlgTitle,boxDims,presetInput));

%% --- Ryosuke's code ---
% Genotype of your flies
genotypes = {'AC_LC14_+','emptysplit_shi','LC14_shi'};
% Get the path t the data directory on your computer
sysConfig = GetSystemConfiguration;
% concatenate those to create the path

% Your analysis file (you can pass multiple analysis function names as a cell)
% "PlotTimeTraces" clips out peri-stimulus turning and walking speed time
% traces, averages over repetitions / flies, and plot group mean time traces
% with standard error around it.
% Other analysis functions can be found under analysis/analysisFiles
analysisFiles={'PlotTimeTraces'};
% Prepare input arguments for RunAnalysis function
args = {'analysisFile',analysisFiles,...
    'dataPath','',...
    'combOpp',1}; % combine left/right symmetric parameters? (defaulted to 1)***

out = {};
% gg: number of genotypes
for gg = 1:3
    dataPath = [sysConfig.dataPath,'/',genotypes{gg},'/',stimName];
    args{4} = dataPath;
    out{gg} = RunAnalysis(args{:});
end
close all
genotypes = regexprep(genotypes, '_', ' > '); % depending on what your genotype is alter or block this line, I replace '_' with '>' for plot labels
genotypes(1) = cellstr('LC14 / +'); % ---------------input *** (specific to using '/' block this line if your don't use that)
%% Post processing
timeX = out{1}.analysis{1}.timeX/1000;
respResp = {};
respResp.meanturnresp = [];
respResp.semturnresp  = [];
respResp.meanwalkresp = [];
respResp.semwalkresp  = [];

for gg = 1:3
    % stack turning results together -- 3rd dimension = genotypes
    respResp.meanturnresp(:,:,gg) = out{gg}.analysis{1}.respMatPlot(:,:,1);
    respResp.semturnresp(:,:,gg)  = out{gg}.analysis{1}.respMatSemPlot(:,:,1);
    % for walking...
    respResp.meanwalkresp(:,:,gg) = out{gg}.analysis{1}.respMatPlot(:,:,2);
    respResp.semwalkresp(:,:,gg)  = out{gg}.analysis{1}.respMatSemPlot(:,:,2);
end
% ---
%%
% % TEST: One epoch
% specificEpoch = 4;
% symmPlotstTest(stimName, timeX, respResp, out, genotypes, specificEpoch, epochTitlePH) % ...PH: place holder
%%
% for loop of all epochs
for jj = 1:length(respResp.meanturnresp(1,:,1))
    specificEpoch = jj;
    symmPlotstTest(stimName, timeX, respResp, out, genotypes, specificEpoch, epochTitlePH);
end