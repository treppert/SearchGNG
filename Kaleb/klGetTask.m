%% klGetTask creates a "Task" structure with stimulus and performance information for a given session
%
% "Task" and "Eyes" structures and contained calculations inspired by
% functions with similar purposes written by Wolf Zinke (PLX2mat.m)

function [Task, Eyes, PD, EEG, tdt] = klGetTask(sessName,varargin)

Eyes =0;
PD = 0;
EEG = 0;
tdt = 0;

tebaMount = '/mnt/schalllab';

% Set defaults
print = 1;
nPrint = 500;
fresh = 1;
rawDir = [tebaMount,'/data/Kaleb/antiSessions/'];%'/mnt/teba/data/Kaleb/antiSessions/';
% rawDir = '/mnt/teba/Users/Kaleb/proAntiRaw';
procDir = [tebaMount,'/Users/Kaleb/proAntiProcessed'];%'/mnt/teba/Users/Kaleb/proAntiProcessed/';
doSave = 0;
doLive = 0;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','print'}
            print = varargin{varStrInd(iv)+1};
        case {'-f','fresh'}
            fresh = varargin{varStrInd(iv)+1};
        case {'-r','rawDir','rawdir'}
            rawDir = varargin{varStrInd(iv)+1};
        case {'-proc'}
            procDir = varargin{varStrInd(iv)+1};
        case {'-s','save'}
            doSave = varargin{varStrInd(iv)+1};
        case {'-l','live'}
            doLive = varargin{varStrInd(iv)+1};
        case {'-obj'}
            tdt = varargin{varStrInd(iv)+1};
        case {'-e'}
            getEyes = varargin{varStrInd(iv)+1};
    end
end

if doLive
    if ~exist('tdt','var')
        tdt = SynapseLive();
    end
    sessName = tdt.BLOCK;
    doSave = 0;
end

if ~ismember(sessName(end),['/','\']), sessName(end+1) = filesep;  end
if ismember(rawDir(end),['/','\']), fileName = [rawDir,sessName]; else fileName = [rawDir,filesep,sessName]; end
if ismember(procDir(end),['/','\']), saveDir = [procDir,sessName]; else saveDir = [procDir,filesep,sessName]; end

if ~exist(saveDir,'file')
    mkdir(saveDir);
end


% Set some code identifiers
trStartCode = 1666;
trEndCode = 1667;
taskHeaders = 1500:1510;
mgHeader = 1502;
searchHeader = 1507;
capHeader = 1508;
antiHeader = 1509;
infoEndCode = 2999;
EV = TEMPO_EV_cosman_rig028;

behavDone = 0; eyesDone = 0;
% if exist(sprintf('%sBehav.mat',saveDir)) && ~fresh
%     load([saveDir,'/Behav.mat']);
%     if isfield(Task,'Good') && Task.Good==1
%         behavDone = 1;
%     end
% end
if exist(sprintf('%sEyes.mat',saveDir)) && ~fresh
    load([saveDir,'/Eyes.mat']);
    if isfield(Eyes,'Good') && Eyes.Good==1
        eyesDone = 1;
    end
end

switch lower(sessName(1))
    case 'd'
        pdStr = 'PD__';
        doEEG = 1;
        doUS = 1;
        doPD = 1;
        doInvert = 1;
    case 'l'
        pdStr = 'PhoR';
        doEEG = 0;
        doUS = 0;
        doPD = 1;
        doInvert = 0;
    case 'i'
        pdStr = 'PD__';
        doPD = 0;
        doEEG = 0;
        doUS = 0;
        doInvert = 1;
    otherwise
        pdStr = 'PhoR';
        doEEG = 0;
        doUS = 0;
        doPD = 0;
        doInvert = 0;
end


if doLive
    if ~exist('tdt','var')
        tdt = SynapseLive();
    end
    tdt.WHICHSTORE = {'EyeX','EyeY','Rewd','PD__','STRB'};
    
    % Hold on to old data
    oldData = tdt.data;
    % Get new data
    tdt.update;
    % Concatenate data structure
    if ~isempty(oldData)
        tdt.data = klCatStruct(oldData,tdt.data,1);
    end
    [tdtEvs,tdtEvTms] = klGetEvsLive(tdt.data);
%     if getEyes
%         Eyes = klGetEyesLive(tdt.data);
%     else
%         Eyes.Good = 0;
%     end
    if doInvert
        Eyes.X = tdt.data.streams.EyeY.data.*3;
        Eyes.Y = tdt.data.streams.EyeX.data.*(-3);
    else
        Eyes.X = tdt.data.streams.EyeX.data.*3;
        Eyes.Y = tdt.data.streams.EyeY.data.*(-3);
    end
    Eyes.Times = (0:(length(Eyes.X)-1)).*(1000/tdt.data.streams.EyeX.fs);
    Eyes.R = sqrt(Eyes.X.^2 + Eyes.Y.^2);
    eyeThRaw = klRad2Deg(atan(abs(Eyes.Y)./abs(Eyes.X)));
    eyeTh = nan(size(eyeThRaw));
    eyeTh(Eyes.X > 0 & Eyes.Y > 0) = eyeThRaw(Eyes.X > 0 & Eyes.Y > 0);
    eyeTh(Eyes.X < 0 & Eyes.Y > 0) = 180-eyeThRaw(Eyes.X < 0 & Eyes.Y > 0);
    eyeTh(Eyes.X < 0 & Eyes.Y < 0) = 180+eyeThRaw(Eyes.X < 0 & Eyes.Y < 0);
    eyeTh(Eyes.X > 0 & Eyes.Y < 0) = 360-eyeThRaw(Eyes.X > 0 & Eyes.Y < 0);
    Eyes.Theta = eyeTh;
    Eyes.Good = 1;
    
    clear eyeTh
    
    if doPD
        pdStream = tdt.data.streams.(pdStr).data;
        if length(pdStream)==length(Eyes.X)%pdRaw.streams.(pdStr).fs > 2000
            load('slowSamplingRate.mat');
            pdTime = (0:(length(pdStream)-1)).*(1/sampRate);
            pdRate = sampRate;
        else
            pdTime = (0:(length(pdStream)-1)).*(1/tdt.data.streams.(pdStr).fs);
            pdRate = tdt.data.streams.(pdStr).fs;
        end
    else
        pdStream = nan;
        pdTime = nan;
    end
    rwdStream = tdt.data.streams.Rewd.data;
    rwdTime = (0:(length(rwdStream)-1)).*(1/tdt.data.streams.Rewd.fs);
    
    usTime = pdTime; usStream = zeros(1,length(pdStream)); usRaw = [];
    
    EEG = [];
else
    % Get event codes and times
    [tdtEvs,tdtEvTms] = klGetEvsTDT(sessName,'-r',rawDir,'-proc',procDir);
    if ~any(tdtEvs > 6000 & tdtEvs < 7000)
        return
    end
    % Get Eye Positions
    if ~eyesDone
%         Eyes = klGetEyesTDT(sessName,'-r',rawDir,'-proc',procDir,'-s',doSave,'-i',doInvert);
    end
    
    if doEEG
%         EEG = klGetEEGTDT(sessName,'-r',rawDir,'-proc',procDir,'-s',doSave);
    else
        EEG = [];
    end
    
% %     pdRaw = TDTbin2mat(fullfile(rawDir,sessName),'TYPE',{'streams'},'STORE',{pdStr},'VERBOSE',0);
% %     pdStream = pdRaw.streams.(pdStr).data;
    % for some reason, pdTime, if turned into milliseconds, gives 0 dt
    % values which really mess with the saccade detector... I guess all of
    % this will need to be done post-detection
% %     if length(pdStream)==length(Eyes.X)%pdRaw.streams.(pdStr).fs > 2000
% %         load('slowSamplingRate.mat');
% %         pdTime = (0:(length(pdStream)-1)).*(1/sampRate);
% %         pdRate = sampRate;
% %     else
% %         pdTime = (0:(length(pdStream)-1)).*(1/pdRaw.streams.(pdStr).fs);
% %         pdRate = pdRaw.streams.(pdStr).fs;
% %     end
% %     if doUS
% %         usRaw = TDTbin2mat(fullfile(rawDir,sessName),'TYPE',{'streams'},'STORE',{'US__'},'VERBOSE',0);
% %         usStream = usRaw.streams.US__.data;
% %         usTime = (0:(length(usStream)-1)).*(1/usRaw.streams.US__.fs);
% %     else
% %         usTime = pdTime; usStream = zeros(1,length(pdStream)); usRaw = [];
% %     end
    
    % Get reward vector
% %     rwdRaw = TDTbin2mat(fullfile(rawDir,sessName),'TYPE',{'streams'},'STORE',{'Rewd'},'VERBOSE',0);
% %     try
% %         rwdStream = rwdRaw.streams.Rewd.data;
% %         rwdTime = (0:(length(rwdStream)-1)).*(1/rwdRaw.streams.Rewd.fs);
% %     catch
% %         rwdStream = nan(1,length(Eyes.X));
% %         rwdTime = Eyes.Times;
% %     end
% %     tdt = [];
end

% Find trial starts and ends
startInds = find(tdtEvs == trStartCode);
endInds = find(tdtEvs == trEndCode);
trHeadInds = find(ismember(tdtEvs,taskHeaders));

if isempty(trHeadInds)
    Task.Good = 0;
    Eyes.Good = 0;
    EEG.Good = 0;
    PD.Good = 0;
    return;
end

endInfoTmp = find(tdtEvs == infoEndCode);
endInfos = nan(1,length(trHeadInds));
trEnds = nan(1,length(trHeadInds));
for it = 1:(length(trHeadInds)-1)
    check = endInfoTmp(find(endInfoTmp > trHeadInds(it) & endInfoTmp < trHeadInds(it+1),1));
    checkEnd = endInds(find(endInds > trHeadInds(it) & endInds < trHeadInds(it+1),1));
    if ~isempty(check), endInfos(it) = check; else endInfos(it) = nan; end
    if ~isempty(checkEnd), trEnds(it) = checkEnd; else trEnds(it) = nan; end
end
check = endInfoTmp(find(endInfoTmp > trHeadInds(end),1));
checkEnd = endInds(find(endInds > trHeadInds(end),1));
if ~isempty(check), endInfos(it+1) = check; else endInfos(it+1) = nan; end
if ~isempty(checkEnd), trEnds(it+1) = checkEnd; else trEnds(it+1) = nan; end
trHeadInds(isnan(endInfos)) = [];
trEnds(isnan(endInfos)) = [];
endInfos(isnan(endInfos)) = [];

% Get the trial codes
nTrs = length(trHeadInds);%min([length(startInds),length(endInds)]);
for it = 1:nTrs
    trialCodes{it,1} = tdtEvs(trHeadInds(it):endInfos(it));
    trialTimes{it,1} = tdtEvTms(trHeadInds(it):endInfos(it));
end
dashes = strfind(sessName,'-');
if nTrs < 10
    Task.Subject = sessName(1:(dashes(1)-1));
    Task.Date = sessName((dashes(1)+1):(dashes(2)-1));
    Task.Good = 0;
    PD = [];
else
    % Get the trial headers
    trHeads = tdtEvs(trHeadInds);
    % Get unique task types
    uTasks = unique(trHeads(~isnan(trHeads)));
    clear nTr
    for i = 1:length(uTasks)
        nTr(i) = sum(trHeads==uTasks(i));
    end
    uTasks(nTr < 10) = [];
    trHeadInds(~ismember(trHeads,uTasks)) = [];
    trEnds(~ismember(trHeads,uTasks)) = [];
    trHeads(~ismember(trHeads,uTasks)) = [];
    % Now loop through them and run their respective analyses
    for it = 1:length(uTasks)
        fprintf('Decoding trials with header %d...\n',uTasks(it));
        switch uTasks(it)
            case mgHeader
                taskTmp{it} = klDecodeMG(trialCodes(trHeads==uTasks(it),1),trialTimes(trHeads==uTasks(it),1),EV,Eyes,'-p',print,'-np',nPrint);
            case antiHeader
%                 taskTmp{it} = klDecodeAnti(trialCodes(trHeads==uTasks(it),1),trialTimes(trHeads==uTasks(it),1),EV,Eyes,'-p',print,'-np',nPrint);
                taskTmp{it} = klDecodeAnti(trialCodes(trHeads==uTasks(it),1),trialTimes(trHeads==uTasks(it),1),EV,0,'-p',print,'-np',nPrint);
            case {searchHeader,capHeader}
                taskTmp{it} = klDecodeSearch(trialCodes(trHeads==uTasks(it),1),trialTimes(trHeads==uTasks(it),1),EV,Eyes,'-p',print,'-np',nPrint);
        end
    end

    Task = klMergeTask(taskTmp,trHeads);
    Task.error_names = {'False','Early','Late','FixBreak','HoldError','CatchErrorNoGo'};
    Task.trStarts = tdtEvTms(trHeadInds);
    Task.trEnds(isfinite(trEnds)) = tdtEvTms(trEnds(isfinite(trEnds)));
    Task.Good = 1;
    Task.Subject = sessName(1:(dashes(1)-1));
    Task.Date = sessName((dashes(1)+1):(dashes(2)-1));
    Task.fromEyes = ones(size(Task.SRT));
    
%     pdOn = klSaccDetectNew(pdStream,pdStream,pdTime,'-s',5,'-o',2,'-f',0);
%     pdOn = pdTime(pdStream > 75);
%     % Here's where we correct for the millisecond conversion
%     pdOn = pdOn.*1000;
%     pdMat = klPlaceEvents(Task,pdOn);
    
    if doLive, pdMat = nan; pdMatTime = nan;
    else
% %             [pdMat,pdMatTime] = klPlaceStream(Task,pdStream,'-p',[-2000,3000],'-s',pdRate);
    end
%     if any(isfinite(
% 
%     Task.FixSpotPD = nan(size(pdMat,1),1);
%     Task.TargOnPD = nan(size(pdMat,1),1);
%     
%     fixTmp = find(pdMat' > range(pdStream).*.5 & repmat(pdMatTime',1,size(pdMat,1)) < -100);
%     fixRow = mod(fixTmp,size(pdMat',1));
%     fixCol = floor(fixTmp./size(pdMat',1))+1;
%     [uFix,iFix] = unique(fixCol);
%     Task.FixSpotPD(uFix) = pdMatTime(fixRow(iFix))'+Task.AlignTimes(uFix);
%     Eyes.Times
%     targTmp = find(pdMat' > range(pdStream).*.5 & repmat(pdMatTime',1,size(pdMat,1)) > -200 & repmat(pdMatTime',1,size(pdMat,1)) < 200);
%     targRow = mod(targTmp,size(pdMat',1));
%     targCol = floor(targTmp./size(pdMat',1))+1;
%     [uTarg,iTarg] = unique(targCol);
%     Task.TargOnPD(uTarg) = pdMatTime(targRow(iTarg))'+Task.AlignTimes(uTarg);
% %     for it = 1:10%size(pdMat,1)
% % %         tmp = find(abs(pdOn-Task.FixSpotOn(it))==min(abs(pdOn-Task.FixSpotOn(it))));
% % %         if ~isempty(tmp), Task.FixSpotPD(it) = pdOn(tmp); end%-Task.AlignTimes(it); end
% % %         tmp = find(abs(pdOn-Task.AlignTimes(it))==min(abs(pdOn-Task.AlignTimes(it))));
% % %         if ~isempty(tmp), Task.TargOnPD(it)    = pdOn(tmp(1)); end%-Task.AlignTimes(it); end
% %         tmp = find(pdMat(it,:) > range(pdStream).*.5 & pdMatTime < -100);
% %         if ~isempty(tmp), Task.FixSpotPD(it) = pdMatTime(tmp(1)) + Task.AlignTimes(it); end
% %         tmp = find(pdMat(it,:) > range(pdStream).*.5 & pdMatTime > -200 & pdMatTime < 200);
% %         if ~isempty(tmp), Task.TargOnPD(it) = pdMatTime(tmp(1)) + Task.AlignTimes(it); end
% %     end
%     
%     
%     Task.AlignTimes = Task.StimOnsetToTrial + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.SaccEnd    = Task.SaccEnd          + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.Reward     = Task.Reward           + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.Tone       = Task.Tone             + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.RewardTone = Task.RewardTone       + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.ErrorTone  = Task.ErrorTone        + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.FixSpotOn  = Task.FixSpotOn        + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.FixSpotOff = Task.FixSpotOff       + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.StimOnset  = Task.StimOnsetToTrial + Task.StimOnsetToTrial - Task.TargOnPD; % should be all zero aferwards
%     Task.GoCue 		= Task.FixSpotOff;       + Task.StimOnsetToTrial; % - Task.TargOnPD;
%     Task.Fixation   = Task.Fixation         + Task.StimOnsetToTrial - Task.TargOnPD;
% %     Task.SRT        = Task.SRT              + Task.StimOnsetToTrial - Task.TargOnPD;
%     Task.FixSpotPD  = Task.FixSpotPD        - Task.TargOnPD;
%     Task.AlignTimes = Task.TargOnPD;
    
    % Get SRT and SaccEnd here from Eyes
% % %     if Eyes.Good
% % %         Task.SRT_TEMPO = Task.SRT;
% % %         % Create filter for Eye Position
% % %         f=designfilt('lowpassfir','FilterOrder',3,'PassbandFrequency',.00001,'SampleRate',1000/nanmean(diff(Eyes.Times)),'StopbandFrequency',50);
% % %         xFilt = filter(f,Eyes.X);
% % %         yFilt = filter(f,Eyes.Y);
% % %         
% % %         xMat = klPlaceStream(Task,xFilt);%,'-s',1000/nanmean(diff(Eyes.Times)));%Eyes.X);
% % %         [yMat, matTimes] = klPlaceStream(Task,yFilt);%,'-s',1000/nanmean(diff(Eyes.Times)));%Eyes.Y);
% % %         [rwdMat,rwdTimes] = klPlaceStream(Task,rwdStream);
% % %         printStr = [];
% % %         Task.RewardOn = nan(nTrs,1);
% % %         Task.RewardOff = nan(nTrs,1);
% % %         for it = 1:size(xMat,1)
% % %             if mod(it,100)==0
% % %                 fprintf(repmat('\b',1,length(printStr)));
% % %                 printStr = sprintf('Getting SRT for trial %d (of %d)...',it,size(xMat,1));
% % %                 fprintf(printStr);
% % %             end
% % %             [tmpStart,tmpEnd] = klSaccDetectNew(xMat(it,:),yMat(it,:),matTimes,'-f',f);
% % %             if any(tmpStart > 0) && ~isnan(tmpStart(1))
% % %                 Task.SRT(it) = tmpStart(find(tmpStart > 0,1)) - Task.GoCue(it);
% % %                 try Task.SaccEnd(it) = tmpEnd(find(tmpStart > 0,1)) - Task.GoCue(it); catch Task.SaccEnd(it) = nan; end
% % %                 Task.fromEyes(it) = 1;
% % %                 mnX = nanmean(xMat(it,matTimes >= Task.SRT(it)+50 & matTimes <= Task.SRT(it)+100));
% % %                 mnY = nanmean(yMat(it,matTimes >= Task.SRT(it)+50 & matTimes <= Task.SRT(it)+100));
% % %                 Task.EndX(it) = mnX; Task.EndY(it) = mnY;
% % %                 tmpLocs(:,1) = cos(klDeg2Rad(Task.StimLoc(it,:))).*Task.Eccentricity(it);
% % %                 tmpLocs(:,2) = sin(klDeg2Rad(Task.StimLoc(it,:))).*Task.Eccentricity(it);
% % %                 stmDist = klEucDist([mnX,mnY],tmpLocs);
% % %                 tmpDist = find(stmDist == min(stmDist),1);
% % %                 if ~isempty(tmpDist), Task.EndStimInd(it) = tmpDist; Task.EndStimLoc(it) = Task.StimLoc(it,Task.EndStimInd(it)); end
% % %                 Task.EndEcc(it)   = sqrt(mnY^2 + mnX^2);
% % %                 baseAngle = klRad2Deg(atan(abs(mnY)/abs(mnX)));
% % %                 if (mnX > 0) && (mnY > 0)
% % %                     Task.EndAngle(it) = baseAngle;
% % %                 elseif (mnX < 0) && (mnY > 0)
% % %                     Task.EndAngle(it) = 180-baseAngle;
% % %                 elseif (mnX < 0) && (mnY < 0)
% % %                     Task.EndAngle(it) = baseAngle + 180;
% % %                 elseif (mnX > 0) && (mnY < 0)
% % %                     Task.EndAngle(it) = 360-baseAngle;
% % %                 end
% % %             end
% % %             % Get reward times
% % %             if Task.Correct(it)==1 && any(rwdMat(it,:) > range(rwdStream).*.5)
% % %                 Task.RewardOn(it) = rwdTimes(find(rwdMat(it,:) > range(rwdStream).*.5,1));
% % %                 Task.RewardOff(it) = rwdTimes(find(rwdMat(it,:) < range(rwdStream).*.5 & rwdTimes > Task.RewardOn(it),1));
% % %             end
% % %         end
% % %     PD.matT             = pdMatTime;
% % %     PD.pdStream         = pdStream;
% % % %     PD.onMat    = pdMat;
% % %         
% % %     if doUS && ~doLive
% % %         [usMat,usT] = klPlaceStream(Task,usStream,'-s',1000/usRaw.streams.US__.fs,'-as',Task.StimOnsetToTrial);
% % %         Task.USStim = nan(size(usMat,1),1);
% % %         Task.StimTrial = nan(size(usMat,1),1);
% % %         usCrit = range(usStream).*.5+min(usStream);
% % %         for i = 1:size(usMat,1)
% % %             tmp = find(usMat(i,:) > usCrit,1);
% % %             if ~isempty(tmp)
% % %                 Task.USStim(i) = usT(tmp); 
% % %                 if Task.USStim(i) < 500% Task.Tone(i)%SRT(i)
% % %                     Task.StimTrial(i) = 1;
% % %                 else
% % %                     Task.StimTrial(i) = 0;
% % %                 end
% % %             else
% % %                 Task.USStim(i) = nan;
% % %                 Task.StimTrial(i) = 0;
% % %             end
% % % 
% % %         end
% % %     end
% % %     if print
% % %         fprintf('\n');
% % %         printStr = 'Saving Behavior...';
% % %         fprintf(printStr);
% % %     end
% % %     if doSave
% % %         save(sprintf('%sBehav.mat',saveDir),'Task');
% % % %         delete(sprintf('%sevsRaw.mat',saveDir));
% % %     end
% % %     end
% % %     fprintf(repmat('\b',1,length(printStr)));
% % %     fprintf('Done!\n');
    
    if ~doLive
%         [pdStreamMat,pdStreamT] = klPlaceStream(Task,pdStream);
%     PD.streamMat = pdStreamMat;
%         PD.matT        = pdStreamT;
    else
%         PD.matT = nan;
    end
    
end