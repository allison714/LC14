clc; clear all; close all;
%% Template analysis script
% Keep analysis script in a directory separate from psycho5 and ideally
% create your own local git repository to keep track of them

%% Running "RunAnalysis"
% RunAnalysis is the outermost wrapper function for data analysis both for
% behavior and imaging data. It expects "analysisFile" and "dataPath"
% arguments at least. 

% Name of your stimulus
stim = 'sinMir_VcontFreq_rot_lam30_C025_180Hz';
% Genotype of your flies
% LC14_shi, AC_LC14_+, emptysplit_shi
genotype = 'emptysplit_shi';
% Get the path to the data directory on your computer
sysConfig = GetSystemConfiguration;
% concatenate those to create the path
dataPath = [sysConfig.dataPath,'/',genotype,'/',stim];

% Your analysis file (you can pass multiple analysis function names as a
% cell)
% "PlotTimeTraces" clips out peri-stimulus turning and walking speed time
% traces, averages over repetitions / flies, and plot group mean time traces
% with standard error around it.
% Other analysis functions can be found under analysis/analysisFiles
analysisFiles={'PlotTimeTraces'};


% Prepare input arguments for RunAnalysis function
args = {'analysisFile',analysisFiles,...
        'dataPath',dataPath,...
        'combOpp',0}; % combine left/right symmetric parameters? (defaulted to 1)

% Run the thing
out = RunAnalysis(args{:}); % a = out


% Post processing
% The output variable ("out" here) is a struct with input and analysis
% fileds.
% out.analysis is a cell array that has a cell for each analysis function
% you provided (here we only fed it with "PlotTimeTraces" so it only has
% out.analysis{1}).
% 
% In case of "PlotTimeTraces", out.analysis{1} has following fields:
% respMatPlot: Mean time traces that were plotted by the function.
%              Shaped like (time points)x(epoch numbers)x({turning, walking})
% respMatSemPlot: Standard error of mean around respMatPlot.
% timeX: A vector converting timepoints to actual time (in ms) relative to
%        stimulus onsets.
% indFly: Data from individual flies before averaging. A #fly long struct
%         array with a bunch of intermediate variables in it.

%% Turning: For example, you can replot only some of the epochs you care like this:
timeX = out.analysis{1}.timeX/1000; % converting ms to s
meanmat = out.analysis{1}.respMatPlot;
semmat  = out.analysis{1}.respMatSemPlot;
% Use in-house prettier plot functions for visualization...
figure; hold on
% set(gcf, 'position', get(0, 'Screensize'));
%------test
% % % p5 = out.analysis{1,1}.indFly{1,1}.p5_selectedEpochs.snipMat
% % % respMatPlot_2_ = out.analysis{1}.respMatPlot(:,:,2);
% % % p5 = cell2mat(permute(p5,[3,2,1]));
% % % imagesc(p6mat(:,:,3));

    % showing only first three epochs
PlotXvsY(timeX,meanmat(:,1:2,2),'error',semmat(:,1:2,2)); % turning
PlotConstLine(0,1); % horizontal 0 line
PlotConstLine(0,2); % vertical 0 line
ConfAxis('labelX','time (s)','labelY','Angular velocity (deg/s)')
hold off

%--------

% % showing only first three epochs
% PlotXvsY(timeX,meanmat(:,1,1),'error',semmat(:,1,1)); % turning
% PlotConstLine(0,1); % horizontal 0 line
% PlotConstLine(0,2); % vertical 0 line
% ConfAxis('labelX','time (s)','labelY','Angular velocity (deg/s)')
%%
% %% Walking: Or you can plot time-averaged responses by fly like this...
nFly = length(out.analysis{1}.indFly); % the number of flies
% % pull out individual fly data
% indmat = [];
% for ff = 1:nFly
%     % needs some reformatting from cell to matrix...
%     thisFlyMat = cell2mat(permute(out.analysis{1}.indFly{ff}.p8_averagedRois.snipMat,[3,1,2]));
%     indmat(:,:,ff) = thisFlyMat(:,:,1); % only care about turning here...
% end
% average over time (for 3 s, for example)
% integmat = permute(mean(indmat(timeX>0 & timeX<3, :, :),1),[3,2,1]);
% visualize them
% easyBar(integmat,'connectPaired',1);