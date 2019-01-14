function klPlotAspectColor(Task)

close all; clearvars -except Task
maxSaccTime = 800;
% 
if isfield(Task,'IsRepeat') && any(isfinite(Task.IsRepeat))
    Task = klCutTask(Task,Task.IsRepeat==0);
end

colormap = [.8 .2 .2;... Red
    .2 .8 .2;... Green
    .8 .8 .2;... Yellow
    .8 .2 .8;... Magenta
    .2 .8 .8]; % Cyan
vSize=[1.0,1.1,1.2,1.3,1.4,2.0]; hSize = 1./vSize;
s=nunique(Task.SingletonColor);
d=nunique(Task.DistractorColor);
s(ismember(s,5)) = [];
d(ismember(d,5)) = [];
for is = 1:length(s)
    for id = 1:length(d)
        for i = 0:5
            colorRTs(is,i+1,id) = nanmedian(Task.SRT(Task.Correct==1 & Task.SingletonDiff==i & Task.SingletonColor==s(is) & Task.DistractorColor==d(id)));
            colorStd(is,i+1,id) = nanstd(Task.SRT(Task.Correct==1 & Task.SingletonDiff==i & Task.SingletonColor==s(is) & Task.DistractorColor==d(id)))./sqrt(sum(Task.Correct==1 & Task.SingletonDiff==i & Task.SingletonColor==s(is) & Task.DistractorColor==d(id)));
            colorPercSacc(is,i+1,id) = sum(Task.SRT < maxSaccTime & Task.EndStimLoc==Task.TargetLoc & Task.Abort==0 & Task.SingletonColor==s(is) & Task.DistractorColor==d(id) & Task.SingletonDiff==i)/sum(Task.Abort==0 & Task.DistractorColor==d(id) & Task.SingletonColor==s(is) & Task.SingletonDiff==i);
        end
    end
end

% Now we should identify easy and hard color trials
if isfield(Task,'HardColor')
    isHardColor = Task.HardColor;
else
    isHardColor = nan(length(Task.SingletonColor),1);
    for is = 1:length(s)
        switch s(is)
            case 0 % Red, magenta (3) = hard     Now: 2
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,2)) = 1;%3)) = 1;
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,[1])) = 0;%,4])) = 0;
            case 1 % Green, cyan (4) = hard      Now: 9
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,9)) = 1;%4)) = 1;
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,0)) = 0;%[0,3])) = 0;
            case 3 % Magenta, red (0) = hard     Now: 7
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,0)) = 1;
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,[1,4])) = 0;
            case 4 % Cyan, green (1) = hard      Now: 8
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,1)) = 1;
                isHardColor(Task.SingletonColor==s(is) & ismember(Task.DistractorColor,[0,3])) = 0;
        end
    end
end

% dPrime = @(hits,falseAlarms) norminv(hits)-norminv(falseAlarms);
% [allRTs, allStd, allPercSacc, allDPrime] = deal(nan(2,6));
% for i = 0:5
%     for ii = 0:1
%         if sum(Task.SingletonDiff==i) > 20
%             allRTs(ii+1,i+1) = nanmean(Task.SRT(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==ii));
%             allStd(ii+1,i+1) = nanstd(Task.SRT(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==ii))./sqrt(sum(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==ii));
%             allPercSacc(ii+1,i+1) = sum(Task.SRT < maxSaccTime & Task.EndStimLoc==Task.TargetLoc & Task.Abort==0 & Task.SingletonDiff==i & isHardColor==ii)/sum(Task.Abort==0 & Task.SingletonDiff==i & isHardColor==ii);
%             allDPrime(ii+1,i+1) = dPrime(allPercSacc(ii+1,i+1),allPercSacc(ii+1,1));
%         end
%     end
% end


dPrime = @(hits,falseAlarms) norminv(hits)-norminv(falseAlarms);
[allRTs, allStd, allPercSacc, allDPrime] = deal(nan(2,6));
for i = 0:5
    for ii = 0:1
        if sum(Task.SingletonDiff==i) > 20
            allRTs(ii+1,i+1) = nanmean(Task.SRT(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==ii));
            allStd(ii+1,i+1) = nanstd(Task.SRT(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==ii))./sqrt(sum(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==ii));
            allPercSacc(ii+1,i+1) = sum(Task.SRT < maxSaccTime & Task.Correct==1 & Task.Abort==0 & Task.SingletonDiff==i & isHardColor==ii)/sum(Task.Abort==0 & Task.SingletonDiff==i & isHardColor==ii);
%             allPercSacc(ii+1,i+1) = sum(Task.SRT < maxSaccTime & Task.EndStimLoc==Task.TargetLoc & Task.Abort==0 & Task.SingletonDiff==i & isHardColor==ii)/sum(Task.Abort==0 & Task.SingletonDiff==i & isHardColor==ii);
            allDPrime(ii+1,i+1) = dPrime(allPercSacc(ii+1,i+1),allPercSacc(ii+1,1));
        end
    end
end


% t = {'Red Singleton','Green Singleton','Yellow Singleton','Magenta Singleton','Cyan Singleton'};
% figure();
% for is = 1:length(s)
%     sp(is)=subplot(2,length(s),is);
%     for id = 1:length(d)
%         errorbar(log2(vSize(2:end)./hSize(2:end)),colorRTs(is,2:end,id),colorStd(is,2:end,id),'color',colormap(d(id)+1,:)); hold on;
%     end
%     title(t{s(is)+1});
%     if is == 1, ylabel('Response Time (ms)'); end
% %     xlabel('log2(Aspect Ratio)');
% end
% linkaxes(sp,'y');
% 
% for is = 1:length(s)
%     sp(is) = subplot(2,length(s),is+length(s)); hold on;
%     for id = 1:length(d)
%         plot(log2(vSize./hSize),colorPercSacc(is,:,id),'color',colormap(d(id)+1,:));
%     end
% %     title(t{s(is)+1});
%     if is == 1, ylabel('Percent Saccades'); end
%     xlabel('log2(Aspect Ratio)');
%     
% end
% linkaxes(sp,'y');
allVars = whos('all*');
for iv = 1:length(allVars)
    eval(sprintf('pro%s=all%s(:,2:end);',allVars(iv).name(4:end),allVars(iv).name(4:end)));
end
allX = vSize./hSize;%log2(vSize./hSize);
proX = allX(2:end);

figure();
subplot(1,2,1); hold on;
errorbar(proX(isfinite(proRTs(1,:))),proRTs(1,isfinite(proRTs(1,:))),proStd(1,isfinite(proRTs(1,:))),'color','k');
errorbar(proX(isfinite(proRTs(2,:))),proRTs(2,isfinite(proRTs(2,:))),proStd(2,isfinite(proRTs(2,:))),'color',[.8 .2 .2]);
ylabel('Response Time (ms)');
xlabel('Aspect Ratio');
l=legend({'High Disc.','Low Disc.'}); set(l,'location','northeast');
subplot(1,2,2); hold on;
plot(allX(isfinite(allPercSacc(1,:))),allPercSacc(1,isfinite(allPercSacc(1,:))),'color','k');
plot(allX(isfinite(allPercSacc(2,:))),allPercSacc(2,isfinite(allPercSacc(2,:))),'color',[.8 .2 .2]);
ylabel('Percent Saccades');
xlabel('Aspect Ratio');

% Plot D Prime
figure(); 
subplot(1,2,1); hold on;
plot(allX(isfinite(allDPrime(1,:))),allDPrime(1,isfinite(allDPrime(1,:))),'color','k');
plot(allX(isfinite(allDPrime(2,:))),allDPrime(2,isfinite(allDPrime(2,:))),'color',[.8 .2 .2]);
xlabel('log2(Aspect Ratio)');
ylabel('d''');
l=legend({'High Disc.','Low Disc.'}); set(l,'location','southeast');
subplot(1,2,2); hold on;
plot(allDPrime(1,2:end),allRTs(1,2:end),'color','k');
plot(allDPrime(2,2:end),allRTs(2,2:end),'color',[.8 .2 .2]);
xlabel('d''');
ylabel('Response Time (ms)');

%% Plot RT distributions by aspect ratio
figure(); hold on;
% Get range of RTs
minRT = min(Task.SRT(Task.Abort==0 & Task.SingletonDiff > 0)); maxRT = max(Task.SRT(Task.Abort==0 & Task.SingletonDiff > 0));
rtX = linspace(floor(minRT),ceil(maxRT),200);
scaleVal = .075;
for i = 0:5
    %% Get easy ones
    % Get PDF using ksdensity
    tmpRTs = Task.SRT(Task.Correct==1 & Task.SingletonDiff == i & isHardColor==0);
    if any(isfinite(tmpRTs))
        [corrPDF, corrX] = ksdensity(tmpRTs,rtX);
        corrPDF = ((corrPDF./sum(corrPDF)).*(sum(Task.Correct==1 & Task.SingletonDiff==i & isHardColor==0)./sum(Task.Abort==0 & Task.SingletonDiff==i & isHardColor==0)))./scaleVal;
        corrPatchX = [corrX,fliplr(corrX)];
        corrPatchY = (-1.*[corrPDF,zeros(1,length(corrPDF))]) + i;%log2(vSize(i+1)./hSize(i+1));
        patch(corrPatchY,corrPatchX,[.3 .3 .3],'FaceAlpha',.5);
        plot([min(corrPatchY),max(corrPatchY)],[1,1].*nanmedian(Task.SRT(Task.Correct==1 & Task.SingletonDiff == i & isHardColor==0)),'color','k');
    end
        
    %% Get hard ones
    tmpRTs = Task.SRT(Task.Correct==1 & Task.SingletonDiff == i & isHardColor==1);
    if any(isfinite(tmpRTs))
        [errPDF, errX] = ksdensity(tmpRTs,rtX);
        errPDF = ((errPDF./sum(errPDF)).*(sum(Task.Correct==1 & isHardColor==1 & Task.SingletonDiff==i)./sum(Task.Abort==0 & Task.SingletonDiff==i & isHardColor==1)))./scaleVal;
        errPatchX = [errX,fliplr(errX)];
        errPatchY = [errPDF,zeros(1,length(errPDF))] + i;%log2(vSize(i+1)./hSize(i+1));
        patch(errPatchY,errPatchX,[.8 .2 .2],'FaceAlpha',.5);
        plot([min(errPatchY),max(errPatchY)],[1,1].*nanmedian(Task.SRT(Task.Correct==1 & Task.SingletonDiff == i & isHardColor==1)),'color',[.8 .2 .2]);
    end    
    
end
set(gca,'XLim',[-.5,5.5],'XTick',0:5,'YLim',[0,1000],'YTick',0:250:1000,'box','off','tickdir','out','ticklength',get(gca,'ticklength').*3);
% set(gca,'XLim',[-.1,2.5],'XTick',log2(0:5),'YLim',[0,1000],'YTick',0:250:100,'box','off','tickdir','out','ticklength',get(gca,'ticklength').*3);
xlabel('Aspect Ratio Index'); ylabel('Response Time (ms)');
title([Task.Subject(1:2),' ',Task.Date]);