function easyBar(M,varargin)

if iscell(M)
    Mnew = nan(max(cellfun(@length,M)),length(M));
    for ii = 1:length(M)
        Mnew(1:length(M{ii}(:)),ii) = M{ii}(:);
    end
    M = Mnew;
end
   
doSignrank = 0;
numCol = size(M,2);
newFigure = 1;
plotMedian = 0;

% plot colors
colors = colormap('lines');
conditionNames = {};
connectPaired =  0;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% repeat/trim color matrix if necessary
if size(colors,1)<numCol
    colors = repmat(colors,[ceil(numCol/size(colors,1)),1]);
end
colors = colors(1:numCol,:);

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
xlim([0,numCol+1]);
ylim([min(0,min(M(:))),max(M(:))]*1.2);
box off
b.BaseLine.LineStyle = 'none';
PlotConstLine(0)
set(gca,'XTick',1:numCol,'XTickLabels',conditionNames);
if numCol>5
    set(gca,'XTickLabelRotation',45);
end
ConfAxis
end