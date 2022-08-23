stim = 'sinMir_VcontFreq_rot_lam30_C025_180Hz';
% Genotype of your flies
genotypes = {'AC_LC14_+','emptysplit_shi','LC14_shi'};
% Get the path t the data directory on your computer
sysConfig = GetSystemConfiguration;
% concatenate those to create the path

% Your analysis file (you can pass multiple analysis function names as a
% cell)
% "PlotTimeTraces" clips out peri-stimulus turning and walking speed time
% traces, averages over repetitions / flies, and plot group mean time traces
% with standard error around it.
% Other analysis functions can be found under analysis/analysisFiles
analysisFiles={'PlotTimeTraces'};
% Prepare input arguments for RunAnalysis function
args = {'analysisFile',analysisFiles,...
    'dataPath','',...
    'combOpp',1}; % combine left/right symmetric parameters? (defaulted to 1)
%%
out = {};
for gg = 1:3
    dataPath = [sysConfig.dataPath,'/',genotypes{gg},'/',stim];
    args{4} = dataPath;
    out{gg} = RunAnalysis(args{:});
    thisIndFly = out{gg}.analysis{1}.indFly;
    nFly = length(thisIndFly);
end

%% Post processing
timeX = out{1}.analysis{1}.timeX/1000;
meanturnresp = [];
semturnresp  = [];
meanwalkresp = [];
semwalkresp  = [];

for gg = 1:3
    % stack turning results together -- 3rd dimension = genotypes
    meanturnresp(:,:,gg) = out{gg}.analysis{1}.respMatPlot(:,:,1);
    semturnresp(:,:,gg)  = out{gg}.analysis{1}.respMatSemPlot(:,:,1);
    % for walking...
    meanwalkresp(:,:,gg) = out{gg}.analysis{1}.respMatPlot(:,:,2);
    semwalkresp(:,:,gg)  = out{gg}.analysis{1}.respMatSemPlot(:,:,2);
end

%% visualize optomotor turning results
% curtail timeX
contrast = ones(16,1)*0.25;
contrast(1:2) = 1;
temporalf = [16,0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32];


%% Turning Plots all 16 epochs
figure('units','normalized','outerposition',[0 0 1 1]);
for ii = 1:2
    subplot(4,4,ii)
    hold on
    timeXshort = timeX(timeX<2);
    PlotXvsY(timeXshort,permute(meanturnresp(timeX<2,ii,:),[1,3,2]),...
        'error',permute(semturnresp(timeX<2,ii,:),[1,3,2]));
    PlotConstLine(0,1);
    PlotConstLine(0,2);
    PlotConstLine(0.25,2);
    % ConfAxis('labelX','time (s)','labelY','turning (deg/s)','figLeg',genotypes,'fTitle',sprintf('ROI %d', ii));
    title(sprintf('Contrast = %d, f_{temporal} = %.2f', contrast(ii), temporalf(ii)))
    xlabel('time (s)')
    ylabel('turning (deg/s)')
    legend('LC14 / +','ES > Shi', 'LC14 > Shi')
    legend('boxoff')
end

for i = 3:length(meanturnresp(1,:,1))
    subplot(4,4,i)
    hold on
    timeXshort = timeX(timeX<2);
    PlotXvsY(timeXshort,permute(meanturnresp(timeX<2,i,:),[1,3,2]),...
        'error',permute(semturnresp(timeX<2,i,:),[1,3,2]));
    PlotConstLine(0,1);
    PlotConstLine(0,2);
    PlotConstLine(1,2);
    %     ConfAxis('labelX','time (s)','labelY','turning (deg/s)','figLeg',genotypes,'fTitle','');
    title(sprintf('Contrast = %.2f, f_{temporal} = %.2f', contrast(i), temporalf(i)))
    xlabel('time (s)')
    ylabel('turning (deg/s)')
    legend('LC14 / +','ES > Shi', 'LC14 > Shi')
    legend('boxoff')
    sgtitle('Turning Response')
end
%%
time = datestr(now, 'mmddyy');
filename = sprintf('%s_turn_sinMir_VcontFreq_rot_lam30_C025_180hz_03.png',time);
saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior', filename),'png')

%% walking Plots all 16 epochs
figure('units','normalized','outerposition',[0 0 1 1]);
for ii = 1:2
    subplot(4,4,ii)
    hold on
    timeXshort = timeX(timeX<2);
    PlotXvsY(timeXshort,permute(meanwalkresp(timeX<2,ii,:),[1,3,2]),...
        'error',permute(semwalkresp(timeX<2,ii,:),[1,3,2]));
    PlotConstLine(0,1);
    PlotConstLine(0,2);
    PlotConstLine(0.25,2);
    % ConfAxis('labelX','time (s)','labelY','walking (deg/s)','figLeg',genotypes,'fTitle',sprintf('ROI %d', ii));
    title(sprintf('Contrast = %d, f_{temporal} = %.2f', contrast(ii), temporalf(ii)))
    xlabel('time (s)')
    ylabel('walking (deg/s)')
    legend('LC14 / +','ES > Shi', 'LC14 > Shi')
    legend('boxoff')
    sgtitle('Walking Response')
end

for i = 3:length(meanwalkresp(1,:,1))
    subplot(4,4,i)
    hold on
    timeXshort = timeX(timeX<2);
    PlotXvsY(timeXshort,permute(meanwalkresp(timeX<2,i,:),[1,3,2]),...
        'error',permute(semwalkresp(timeX<2,i,:),[1,3,2]));
    PlotConstLine(0,1);
    PlotConstLine(0,2);
    PlotConstLine(1,2);
    %     ConfAxis('labelX','time (s)','labelY','walking (deg/s)','figLeg',genotypes,'fTitle','');
    title(sprintf('Contrast = %.2f, f_{temporal} = %.2f', contrast(i), temporalf(i)))
    xlabel('time (s)')
    ylabel('walking (deg/s)')
    legend('LC14 / +','ES > Shi', 'LC14 > Shi')
    legend('boxoff')
end
filename = sprintf('%s_walk_sinMir_VcontFreq_rot_lam30_C025_180hz_03.png',time);
saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior', filename),'png')










%% Compare time-averaged responses across genotypes
meanrespcell = {};
for gg = 1:3
    thisIndFly = out{gg}.analysis{1}.indFly;
    nFly = length(thisIndFly);
    meanturn = [];
    for ff = 1:nFly
        % pull out individual fly results (in cell)
        thisFlyData = thisIndFly{ff}.p8_averagedRois.snipMat;
        % convert a cell into a matrix (easier to work on)
        thisFlyMat = cell2mat(permute(thisFlyData,[2,1,3]));
        meanturn(ff,:) = mean(thisFlyMat(timeX>0 & timeX<0.5,12,1));
    end
    meanrespcell{gg} = meanturn;
end

% easyBar(meanrespcell,'conditionNames',genotypes);
% ylabel('turning (deg/s)')

easyBarStats(meanrespcell,'conditionNames',genotypes);
ylabel('turning (deg/s)')

%% for loop cycling through epochs
meanrespcell = {};
a = {};
ee = 16 ; % epoch #
time = datestr(now, 'mmddyy');
for ii = 1:ee
    for gg = 1:3
        thisIndFly = out{gg}.analysis{1}.indFly;
        nFly = length(thisIndFly);
        meanwalk = [];
        for ff = 1:nFly
            % pull out individual fly results (in cell)
            thisFlyData = thisIndFly{ff}.p8_averagedRois.snipMat;
            % convert a cell into a matrix (easier to work on)
            thisFlyMat = cell2mat(permute(thisFlyData,[2,1,3]));
            
            meanwalk(ff,:) = mean(thisFlyMat(timeX>0 & timeX<0.5,ii,2));
            
        end
        meanrespcell{gg} = meanwalk;
    end
    %         subplot(8,2,ii)
    %         tiledlayout(4,4)
    %         nexttile
    easyBarStats(meanrespcell,'conditionNames',genotypes);
    title(sprintf('Epoch %d: Contrast = %.2f, f_{temporal} = %.2f' , ii, contrast(ii), temporalf(ii)))
    ylabel('walking (deg/s)')
    %
        filename = sprintf('%s_sinMir_epoch_%d.png',time,ii);
        saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior', filename),'png')
end
%%

%% for loop cycling through epochs
meanrespcell = {};
a = {};
ee = 16 ; % epoch #
time = datestr(now, 'mmddyy');
for ii = 1:ee
    for gg = 1:3
        thisIndFly = out{gg}.analysis{1}.indFly;
        nFly = length(thisIndFly);
        meanturn = [];
        for ff = 1:nFly
            % pull out individual fly results (in cell)
            thisFlyData = thisIndFly{ff}.p8_averagedRois.snipMat;
            % convert a cell into a matrix (easier to work on)
            thisFlyMat = cell2mat(permute(thisFlyData,[2,1,3]));
            
            meanturn(ff,:) = mean(thisFlyMat(timeX>0 & timeX<0.5,ii,1));
            
        end
        meanrespcell{gg} = meanturn;
    end
    %         subplot(8,2,ii)
    %         tiledlayout(4,4)
    %         nexttile
    easyBarStats(meanrespcell,'conditionNames',genotypes);
    title(sprintf('Epoch %d: Contrast = %.2f, f_{temporal} = %.2f' , ii, contrast(ii), temporalf(ii)))
    ylabel('turning (deg/s)')
    %
        filename = sprintf('%s_sinMir_turn_epoch_%d.png',time,ii);
        saveas( gcf,fullfile('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior', filename),'png')
end




% tiledlayout(1,2)
% a = openfig('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior\080421_sinMir_epoch_6.fig')
% b = openfig('C:\Users\labuser\Documents\LC14\Allison_Repo\AC_Behavior\080421_sinMir_epoch_6.fig')
% nexttile
% plot(a)
% nexttile
% plot(b)
%
