cutTask = klCutTask(Task,Task.Abort==0);% & Task.IsRepeat == 0);

legStr = {};

%% Start identifying easy trials
% Identify pro trials with a red singleton
pre = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[0]) & cutTask.HardColor==0);
% Get the running average
spre = klRunningAvv2((cutTask.EndStimLoc(pre)==cutTask.TargetLoc(pre))',50);
if ~isempty(pre)
    legStr{length(legStr)+1} = 'Pro Red Easy';
end

% Identify pro trials with a red singleton
poe = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[2]) & cutTask.HardColor==0);
% Get the running average
spoe = klRunningAvv2((cutTask.EndStimLoc(poe)==cutTask.TargetLoc(poe))',50);
if ~isempty(poe)
    legStr{length(legStr)+1} = 'Pro Orange Easy';
end

% Identify pro trials with a red singleton
pge = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[1]) & cutTask.HardColor==0);
% Get the running average
spge = klRunningAvv2((cutTask.EndStimLoc(pge)==cutTask.TargetLoc(pge))',50);
if ~isempty(pge)
    legStr{length(legStr)+1} = 'Pro Green Easy';
end

% Identify pro trials with a red singleton
pye = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[9]) & cutTask.HardColor==0);
% Get the running average
spye = klRunningAvv2((cutTask.EndStimLoc(pye)==cutTask.TargetLoc(pye))',50);
if ~isempty(pye)
    legStr{length(legStr)+1} = 'Pro Yellow Easy';
end

% Identify pro trials with a red singleton
pme = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[3,7]) & cutTask.HardColor==0);
% Get the running average
spme = klRunningAvv2((cutTask.EndStimLoc(pme)==cutTask.TargetLoc(pme))',50);
if ~isempty(pme)
    legStr{length(legStr)+1} = 'Pro Magenta Easy';
end

% Identify pro trials with a red singleton
pce = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[4,8]) & cutTask.HardColor==0);
% Get the running average
spce = klRunningAvv2((cutTask.EndStimLoc(pce)==cutTask.TargetLoc(pce))',50);
if ~isempty(pce)
    legStr{length(legStr)+1} = 'Pro Cyan Easy';
end

% Identify pro trials with a red singleton
cre = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[0]) & cutTask.HardColor==0);
% Get the running average
scre = klRunningAvv2(cutTask.Correct(cre)',50);
if ~isempty(cre)
    legStr{length(legStr)+1} = 'Catch Red Easy';
end

% Identify pro trials with a red singleton
coe = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[2]) & cutTask.HardColor==0);
% Get the running average
scoe = klRunningAvv2(cutTask.Correct(coe)',50);
if ~isempty(coe)
    legStr{length(legStr)+1} = 'Catch Orange Easy';
end

% Identify pro trials with a red singleton
cge = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[1]) & cutTask.HardColor==0);
% Get the running average
scge = klRunningAvv2(cutTask.Correct(cge)',50);
if ~isempty(cge)
    legStr{length(legStr)+1} = 'Catch Green Easy';
end

% Identify pro trials with a red singleton
cye = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[9]) & cutTask.HardColor==0);
% Get the running average
scye = klRunningAvv2(cutTask.Correct(cye)',50);
if ~isempty(cye)
    legStr{length(legStr)+1} = 'Catch Yellow Easy';
end

% Identify pro trials with a red singleton
cme = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[3,7]) & cutTask.HardColor==0);
% Get the running average
scme = klRunningAvv2(cutTask.Correct(cme)',50);
if ~isempty(cme)
    legStr{length(legStr)+1} = 'Catch Magenta Easy';
end

% Identify pro trials with a red singleton
cce = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[4,8]) & cutTask.HardColor==0);
% Get the running average
scce = klRunningAvv2(cutTask.Correct(cce)',50);
if ~isempty(cce)
    legStr{length(legStr)+1} = 'Catch Cyan Easy';
end

%% Now for hard trials
% Identify pro trials with a red singleton
prh = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[0]) & cutTask.HardColor==1);
% Get the running average
sprh = klRunningAvv2((cutTask.EndStimLoc(prh)==cutTask.TargetLoc(prh))',50);
if ~isempty(prh)
    legStr{length(legStr)+1} = 'Pro Red Hard';
end

% Identify pro trials with a red singleton
poh = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[2]) & cutTask.HardColor==1);
% Get the running average
spoh = klRunningAvv2((cutTask.EndStimLoc(poh)==cutTask.TargetLoc(poh))',50);
if ~isempty(poh)
    legStr{length(legStr)+1} = 'Pro Red Hard';
end

% Identify pro trials with a red singleton
pgh = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[1]) & cutTask.HardColor==1);
% Get the running average
spgh = klRunningAvv2((cutTask.EndStimLoc(pgh)==cutTask.TargetLoc(pgh))',50);
if ~isempty(pgh)
    legStr{length(legStr)+1} = 'Pro Green Hard';
end

% Identify pro trials with a red singleton
pyh = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[9]) & cutTask.HardColor==1);
% Get the running average
spyh = klRunningAvv2((cutTask.EndStimLoc(pyh)==cutTask.TargetLoc(pyh))',50);
if ~isempty(pyh)
    legStr{length(legStr)+1} = 'Pro Green Hard';
end

% Identify pro trials with a red singleton
pmh = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[3,7]) & cutTask.HardColor==1);
% Get the running average
spmh = klRunningAvv2((cutTask.EndStimLoc(pmh)==cutTask.TargetLoc(pmh))',50);
if ~isempty(pmh)
    legStr{length(legStr)+1} = 'Pro Magenta Hard';
end

% Identify pro trials with a red singleton
pch = find(ismember(cutTask.TrialType,'pro') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[4,8]) & cutTask.HardColor==1);
% Get the running average
spch = klRunningAvv2((cutTask.EndStimLoc(pch)==cutTask.TargetLoc(pch))',50);
if ~isempty(pch)
    legStr{length(legStr)+1} = 'Pro Cyan Hard';
end

% Identify pro trials with a red singleton
crh = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[0]) & cutTask.HardColor==1);
% Get the running average
scrh = klRunningAvv2(cutTask.Correct(crh)',50);
if ~isempty(crh)
    legStr{length(legStr)+1} = 'Catch Red Hard';
end

% Identify pro trials with a red singleton
coh = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[2]) & cutTask.HardColor==1);
% Get the running average
scoh = klRunningAvv2(cutTask.Correct(coh)',50);
if ~isempty(coh)
    legStr{length(legStr)+1} = 'Catch Red Hard';
end

% Identify pro trials with a red singleton
cgh = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[1]) & cutTask.HardColor==1);
% Get the running average
scgh = klRunningAvv2(cutTask.Correct(cgh)',50);
if ~isempty(cgh)
    legStr{length(legStr)+1} = 'Catch Green Hard';
end

% Identify pro trials with a red singleton
cyh = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[9]) & cutTask.HardColor==1);
% Get the running average
scyh = klRunningAvv2(cutTask.Correct(cyh)',50);
if ~isempty(cyh)
    legStr{length(legStr)+1} = 'Catch Green Hard';
end

% Identify pro trials with a red singleton
cmh = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[3,7]) & cutTask.HardColor==1);
% Get the running average
scmh = klRunningAvv2(cutTask.Correct(cmh)',50);
if ~isempty(cmh)
    legStr{length(legStr)+1} = 'Catch Magenta Hard';
end

% Identify pro trials with a red singleton
cch = find(ismember(cutTask.TrialType,'catch') & cutTask.Congruent==0 & ismember(cutTask.SingletonColor,[4,8]) & cutTask.HardColor==1);
% Get the running average
scch = klRunningAvv2(cutTask.Correct(cch)',50);
if ~isempty(cch)
    legStr{length(legStr)+1} = 'Catch Cyan Hard';
end

%% Get plots ready
legStr = [{'Trial Start Times CDF','Average Trial Rate'},legStr,{'Chance'}];

figure(); hold on;
plot(cutTask.AlignTimes(isfinite(cutTask.AlignTimes))./60000,(1:sum(isfinite(cutTask.AlignTimes)))./sum(isfinite(cutTask.AlignTimes)),'color','k','linewidth',1);
plot([cutTask.AlignTimes(find(isfinite(cutTask.AlignTimes),1)),cutTask.AlignTimes(find(isfinite(cutTask.AlignTimes),1,'last'))]./60000,[0,1],'color','k','linewidth',1,'linestyle',':');
plot(cutTask.AlignTimes(pre)./60000,spre,'color',[.8 .2 .2],'linewidth',3);
plot(cutTask.AlignTimes(poe)./60000,spoe,'color',[.84 .45 .1],'linewidth',3);
plot(cutTask.AlignTimes(pge)./60000,spge,'color',[.2 .8 .2],'linewidth',3);
plot(cutTask.AlignTimes(pye)./60000,spye,'color',[.56 .64 .28],'linewidth',3);
plot(cutTask.AlignTimes(pme)./60000,spme,'color',[.8 .2 .8],'linewidth',3);
plot(cutTask.AlignTimes(pce)./60000,spce,'color',[.2 .8 .8],'linewidth',3);
plot(cutTask.AlignTimes(cre)./60000,scre,'color',[.8 .2 .2],'linewidth',1);
plot(cutTask.AlignTimes(coe)./60000,scoe,'color',[.84 .45 .1],'linewidth',1);
plot(cutTask.AlignTimes(cge)./60000,scge,'color',[.2 .8 .2],'linewidth',1);
plot(cutTask.AlignTimes(cye)./60000,scye,'color',[.56 .64 .28],'linewidth',1);
plot(cutTask.AlignTimes(cme)./60000,scme,'color',[.8 .2 .8],'linewidth',1);
plot(cutTask.AlignTimes(cce)./60000,scce,'color',[.2 .8 .8],'linewidth',1);
plot(cutTask.AlignTimes(prh)./60000,sprh,'color',[.8 .2 .2],'linewidth',3,'linestyle',':');
plot(cutTask.AlignTimes(poh)./60000,spoh,'color',[.84 .45 .1],'linewidth',3,'linestyle',':');
plot(cutTask.AlignTimes(pgh)./60000,spgh,'color',[.2 .8 .2],'linewidth',3,'linestyle',':');
plot(cutTask.AlignTimes(pyh)./60000,spyh,'color',[.56 .64 .28],'linewidth',3,'linestyle',':');
plot(cutTask.AlignTimes(pmh)./60000,spmh,'color',[.8 .2 .8],'linewidth',3,'linestyle',':');
plot(cutTask.AlignTimes(pch)./60000,spch,'color',[.2 .8 .8],'linewidth',3,'linestyle',':');
plot(cutTask.AlignTimes(crh)./60000,scrh,'color',[.8 .2 .2],'linewidth',1,'linestyle',':');
plot(cutTask.AlignTimes(coh)./60000,scoh,'color',[.84 .45 .1],'linewidth',1,'linestyle',':');
plot(cutTask.AlignTimes(cgh)./60000,scgh,'color',[.2 .8 .2],'linewidth',1,'linestyle',':');
plot(cutTask.AlignTimes(cyh)./60000,scyh,'color',[.56 .64 .28],'linewidth',1,'linestyle',':');
plot(cutTask.AlignTimes(cmh)./60000,scmh,'color',[.8 .2 .8],'linewidth',1,'linestyle',':');
plot(cutTask.AlignTimes(cch)./60000,scch,'color',[.2 .8 .8],'linewidth',1,'linestyle',':');
set(gca,'YLim',[0,1],'box','off','tickdir','out','ticklength',get(gca,'ticklength').*3,'YTick',0:.25:1,'YTickLabel',0:25:100);
plot([0,max(get(gca,'XLim'))],[.125,.125],'color',[138,43,226]./256,'linewidth',2);
legend(legStr,'location','southwest');
xlabel('Time (minutes)'); ylabel('Percent Correct');