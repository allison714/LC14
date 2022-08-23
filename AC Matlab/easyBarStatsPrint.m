function easyBarStatsPrint(stimName, specificEpoch, meanrespcell, M,varargin)
%% Created 8/8/20 easyBar but with stats
%% Run ranksum when not paired, signrank when connectPaired==1

% assume paired comparison by default
connectPaired =  1;

% if input is cell, assume it is not paired
if iscell(M)
    Mnew = nan(max(cellfun(@length,M)),length(M));
    for ii = 1:length(M)
        Mnew(1:length(M{ii}(:)),ii) = M{ii}(:);
    end
    M = Mnew;
    connectPaired = 0;
end
   
numCol = size(M,2);
newFigure = 1;
plotMedian = 0;
doSignrank = 0;

% plot colors
colors = colormap('lines');
colors = colors(1:numCol,:);
conditionNames = {};


for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if isempty(conditionNames)
    for ii=1:numCol
        conditionNames{ii} = ['condition #',num2str(ii)];
    end
end

if newFigure == 1
    MakeFigure;
end
if plotMedian
    meanM = nanmedian(M,1);
else
    meanM = nanmean(M,1);
end
semM  = nanstd(M,[],1)/sqrt(size(M,1));
% draw bars
b = bar(1:numCol,meanM,'LineStyle','none','FaceColor','flat'); hold on
% draw error bars
e = errorbar(1:numCol,meanM',semM','CapSize',0);
e.Color = [0,0,0];
e.Marker = 'none';
e.LineStyle = 'none';

% prepare scatter positions
sbar = scatterBar(M);
% prepare statistics
pval = ones(numCol,1);

% connect paired data points
if connectPaired == 1
    % figure out the original order of the data
    correspMat = zeros(size(M));
    for ii = 1:size(M,2)
        for jj = 1:size(M,1)
            correspMat(jj,ii) = find(sbar(:,2,ii) == M(jj,ii));
        end
    end
    % reorder sbar
    for ii = 1:size(sbar,3)
        sbar(:,:,ii) = sbar(correspMat(:,ii),:,ii);
    end
    
    for ii = 1:size(sbar,1)
        plot(permute(sbar(ii,1,:),[3,1,2])+1,permute(sbar(ii,2,:),[3,1,2]),'color',[1,1,1]*0.8);
    end
end


% prettification
matlabversionstr = version;
for ii = 1:numCol
    % change colors
    if str2double(matlabversionstr(1:3))>9.2
        b.CData(ii,:) = (colors(ii,:)+1)/2; % make bars brighter
    else
        set(b(1),'FaceAlpha',0.5);
        set(b(1),'FaceColor',[0.5,0.5,0.5]);
    end
    % add individual data
    scatter(sbar(:,1,ii)+1,sbar(:,2,ii),40,'filled','MarkerFaceColor',colors(ii,:),'MarkerEdgeColor','none');
    if doSignrank==1
        pval(ii) = signrank(M(:,ii));
        text(ii,max(M(:))*1.2,num2str(pval(ii)),'HorizontalAlignment','center');
    end
end
% do all to all test
pvals = zeros(size(M,2),size(M,2));
for ii = 1:size(M,2)
    for jj = 1:size(M,2)
        if connectPaired==1
            pvals(ii,jj) = signrank(M(:,ii)-M(:,jj));
        else
            pvals(ii,jj) = ranksum(M(:,ii),M(:,jj));
        end
    end
end
hold on
if abs(max(M(:)))>abs(min(M(:)))
    yloc = max(M(:))/2;
else
    yloc = min(M(:))/2;
end

text(0,yloc,num2str(pvals,3));

% %-----Allison Edit 08/27/21 -------
% if pvals(3,1) < 0.05 && pvals(2,1) < 0.05
%     sprintf('%s_epoch_%d has p-vals of %d and %d', stimName, specificEpoch,pvals(3,1),pvals(2,1))
% end
% %----------------------------------

% prettification
xlim([0,numCol+1]);
%ylim([min(0,min(M(:))),max(M(:))]*1.2);
box off
b.BaseLine.LineStyle = 'none';
PlotConstLine(0)
set(gca,'XTick',1:numCol,'XTickLabels',conditionNames);
if numCol>5
    set(gca,'XTickLabelRotation',45);
end
ConfAxis
end
