%% klDecodeSearch creates the structure "Task" that contains task information for T/L search trials
%
% "Task" structure fields and calculations inspired by similar functions
% created by Wolf Zinke

function Task = klDecodeSearch(trialCodes,trialTimes,events,Eyes,varargin)

print = 0;
nPrint = 100;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p','print'}
            print = varargin{varStrInd(iv)+1};
        case {'-np'}
            nPrint = varargin{varStrInd(iv)+1};
    end
end

nTrs = size(trialCodes,1);

evntCnt = cellfun(@length,trialCodes);
allCodes = nan(nTrs,max(evntCnt));
% Task = struct('StimOnsetToTrial',[],'SRT',
Task.StimOnsetToTrial = nan(nTrs,1);
Task.SRT = nan(nTrs,1);
Task.SaccEnd = nan(nTrs,1);
Task.Reward = nan(nTrs,1);
Task.Tone = nan(nTrs,1);
Task.RewardTone = nan(nTrs,1);
Task.ErrorTone = nan(nTrs,1);
Task.FixSpotOn = nan(nTrs,1);
Task.FixSpotOff = nan(nTrs,1);
Task.SingletonColor = nan(nTrs,1);
Task.DistractorColor = nan(nTrs,1);
Task.CueType = nan(nTrs,1);
Task.Eccentricity = nan(nTrs,1);
Task.EndAngle = nan(nTrs,1);
Task.EndEcc = nan(nTrs,1);
Task.SetSize = nan(nTrs,1);
Task.StimLoc = nan(nTrs,4);
Task.StimDiff = nan(nTrs,4);
Task.TargetLoc = nan(nTrs,1);
Task.Congruent = nan(nTrs,1);
Task.Correct = nan(nTrs,1);
Task.Abort = nan(nTrs,1);
Task.Outcome = nan(nTrs,1);
Task.Error = nan(nTrs,1);
Task.ArrayStruct = nan(nTrs,1);
Task.DistHomo = nan(nTrs,1);
Task.SingMode = nan(nTrs,1);
Task.TargetType = nan(nTrs,1);
Task.TrialType = nan(nTrs,1);
Task.Singleton = nan(nTrs,1);
Task.DistLoc = nan(nTrs,1);
Task.IsCatch = nan(nTrs,1);
Task.SingleDistCol = nan(nTrs,1);
Task.DistOri = nan(nTrs,1);
Task.TargetOri = nan(nTrs,1);
Task.PercSgl = nan(nTrs,1);
Task.PercCatch = nan(nTrs,1);
Task.BlockNum = nan(nTrs,1);
Task.SOA = nan(nTrs,1);
Task.TargetPos = nan(nTrs,1);
Task.DistPos = nan(nTrs,1);
Task.TaskType = cell(nTrs,1);
Task.error = nan(nTrs,1);
errorCodes = [events.Error_sacc,events.EarlySaccade_,events.FixError_,events.BreakTFix_,events.CatchIncorrectG_];
errorNums = [1,2,4,5,7];

for it = 1:nTrs
    if print && mod(it,nPrint) == 0
        if exist('printStr','var')
            for ib = 1:length(printStr)
                fprintf('\b');
            end
        end
        printStr = sprintf('Working on Trial %d of %d...\n',it,nTrs);
        fprintf(printStr);
    end
    
    trCodes = trialCodes{it};
    trTimes = trialTimes{it};
    
    %% Get timings
    Task.StimOnsetToTrial(it)      = getEvTime(trCodes,trTimes,events.Target_);
    Task.SRT(it)            = getEvTime(trCodes,trTimes,events.Saccade_);
    Task.SaccEnd(it)        = getEvTime(trCodes,trTimes,events.Decide_);
    Task.Reward(it)         = getEvTime(trCodes,trTimes,events.Reward_);
    Task.Tone(it)           = getEvTime(trCodes,trTimes,events.Tone_);
    Task.RewardTone(it)     = getEvTime(trCodes,trTimes,events.Reward_tone);
    Task.ErrorTone(it)      = getEvTime(trCodes,trTimes,events.Error_tone);
    Task.FixSpotOn(it)      = getEvTime(trCodes,trTimes,events.FixSpotOn_);
    Task.FixSpotOff(it)     = getEvTime(trCodes,trTimes,events.FixSpotOff_);
    
    % Create MG Info Matrix
    trInfos = trCodes(find(trCodes == events.StartInfos_,1):find(trCodes == events.EndInfos_,1,'last'));
    infoVect = getSearchInfos(trInfos);
%     if mod(infoVect(20)-3000,45) ~= 0
%         keyboard
%     end
    
    Task.ArrayStruct(it)   =  infoVect(2) - 4001;
    Task.DistHomo(it)      =  infoVect(3) - 4050;
    Task.SingMode(it)      =  infoVect(4) - 4060;
    Task.SetSize(it)       =  infoVect(5) - 4100;
    Task.TargetType(it)    =  infoVect(6) - 4150;
    Task.TrialType(it)     =  infoVect(7) - 4200;
    Task.Eccentricity(it)  =  infoVect(8) - 4250;
%     Task.Singleton(it)     = (infoVect(9)- 1111)/1111;
    Task.Singleton(it)     = infoVect(9);
    Task.TargetLoc(it)     =  infoVect(12) - 5000;
    Task.DistLoc(it)       =  infoVect(13) - 5500;
    Task.IsCatch(it)       =  infoVect(14) - 4300; % make sure code is 0 for no catch and 1 for catch
    Task.SingleDistCol(it) =  infoVect(15) - 4650;
    Task.DistOri(it)       =  infoVect(16) - 4660;
    Task.TargetOri(it)     =  infoVect(17) - 4670;
    Task.PercSgl(it)       =  infoVect(18) - 4700;
    Task.PercCatch(it)     =  infoVect(19) - 4800;
    Task.BlockNum(it)      =  infoVect(20) - 4900;
    Task.SOA(it)           =  infoVect(21) - 6000;
    Task.Outcome(it)       =  infoVect(22) - 3000;
    if any(ismember(errorCodes,trCodes))
        Task.error(it) = errorNums(find(ismember(errorCodes,trCodes),1,'last'));
    end
    if (Task.Outcome(it) == 7 || Task.Outcome(it) == 4)
        Task.Correct(it) = 1;
        Task.Error(it) = nan;
    else
        Task.Correct(it) = 0;
        Task.Error(it) = Task.Outcome(it);
    end
    if(infoVect(10) == 8888)
        Task.TargetHemi(it) =  char('m');
    elseif(infoVect(10) == 8200)
        Task.TargetHemi(it) =  char('r');
    elseif(infoVect(10) == 8100)
        Task.TargetHemi(it) =  char('l');
    end

    if(infoVect(11) == 8888)
        Task.DistHemi(it) = char('m');
    elseif(infoVect(11) == 8200)
        Task.DistHemi(it) =  char('r');
    elseif(infoVect(11) == 8100)
        Task.DistHemi(it) =  char('l');
    end

    if(Task.SetSize(it) == 1) % with only one item it is a detection task
        Task.TaskType{it} = 'Det';
    elseif(Task.SingMode(it) == 1)  % double check this one
        Task.TaskType{it} = 'Cap';
    else
        Task.TaskType{it} = 'Search';
    end

    Task.TargetPos(it) = mod((360-Task.TargetLoc(it)+90)/45,8); % transform angle to index position
    Task.DistPos(it)   = mod((360-Task.DistLoc(it)  +90)/45,8);
%     
%     
%     
%     Task.TargetLoc(it)      = infoVect(20)-3000;
%     Task.Eccentricity(it)   = (infoVect(25)-3000)/100;
%     Task.Outcome(it)        = infoVect(30)-3000;
%     Task.Correct(it)        = any(trCodes == events.Correct_);
%     Task.Abort(it)          = any(trCodes == events.Abort_);
end


Task.AlignTimes = Task.StimOnsetToTrial;
Task.SaccEnd    = Task.SaccEnd          - Task.StimOnsetToTrial;
Task.Reward     = Task.Reward           - Task.StimOnsetToTrial;
Task.Tone       = Task.Tone             - Task.StimOnsetToTrial;
Task.RewardTone = Task.RewardTone       - Task.StimOnsetToTrial;
Task.ErrorTone  = Task.ErrorTone        - Task.StimOnsetToTrial;
Task.FixSpotOn  = Task.FixSpotOn        - Task.StimOnsetToTrial;
Task.FixSpotOff = Task.FixSpotOff       - Task.StimOnsetToTrial;
Task.StimOnset  = Task.StimOnsetToTrial - Task.StimOnsetToTrial; % should be all zero aferwards
Task.GoCue 		= Task.FixSpotOff;
Task.SRT        = Task.SRT              - Task.StimOnsetToTrial - Task.GoCue;

% % Get SRT and SaccEnd here from Eyes
% saccadeB = klPlaceEvents(Task,Eyes.saccStarts);
% saccadeE = klPlaceEvents(Task,Eyes.saccEnds);
% for it = 1:size(saccadeB,1)
%     bCheck=find(saccadeB(it,:) > 0,1);
%     if isempty(z)
%         Task.SRT(it) = nan;
%     else
%         Task.SRT(it) = saccadeB(it,bCheck) - Task.GoCue(it);
%     end
%     eCheck=find(saccadeE(it,:) > 0,1);
%     if isempty(z)
%         Task.SaccEnd(it) = nan;
%     else
%         Task.SaccEnd(it) = saccadeE(it,eCheck) - Task.GoCue(it);
%     end
% end


function outTime = getEvTime(codes,times,match),
    tmp = find(codes==match,1);
    if ~isempty(tmp),
        outTime = times(tmp);
    else
        outTime = nan;
    end
end

function infoVect = getSearchInfos(infos)
    % We're gonna have to do this in a complicated way perhaps, but I
    % suppose it's worth it
    infosRaw = infos;
    infoVect = nan(1,length(infos));
    minVals = [3000,4000,4050,4060,4100,4150,4200,4250,8000,8000,5000,5500,3800,4650,4660,4670,4700,4800,4900,6000,3000];
    maxVals = [4000,5000,5000,5000,4200,4200,4300,4300,9000,9000,5500,6000,4500,4700,4700,4700,4800,4900,6000,10000,4000];
    for ic = 1:8,
        cutStuff = find(infos >= minVals(ic) & infos <= maxVals(ic),1);
        if isempty(cutStuff),
            infoVect(ic) = 1;
        else
            infoVect(ic) = infos(cutStuff); infos = infos((cutStuff+1):end);
        end
    end
    cutStuff = find(ismember(infos,[2222,1111]),1,'last');
    if isempty(cutStuff),
        infoVect(9) = nan;
    else
        infoVect(9) = infos(cutStuff); infos = infos((cutStuff+1):end);
    end
    for ic = 9:length(minVals),
        cutStuff = find(infos >= minVals(ic) & infos <= maxVals(ic),1);
        if isempty(cutStuff),
            infoVect(ic+1) = nan;
        else
            infoVect(ic+1) = infos(cutStuff); infos = infos((cutStuff+1):end);
        end
    end
    
end


end

