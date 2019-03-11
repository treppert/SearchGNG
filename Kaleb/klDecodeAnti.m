%% klDecodeAnti creates the structure "Task" that contains task information for pro/anti trials
%
% "Task" structure fields and calculations inspired by similar functions
% created by Wolf Zinke

function Task = klDecodeAnti(trialCodes,trialTimes,events,Eyes,varargin)

% Set defaults
print = 0;
nPrint = 100;

% Set some constants
stimHs = [.5, 1, 2, .7, 1.41];
stimVs = [2, 1, .5, 1.41, .7];


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
Task.Fixation = nan(nTrs,1);
Task.SingletonColor = nan(nTrs,1);
Task.DistractorColor = nan(nTrs,1);
Task.HardColor = nan(nTrs,1);
Task.CueType = nan(nTrs,1);
Task.CueColor = nan(nTrs,1);
Task.Eccentricity = nan(nTrs,1);
Task.EndAngle = nan(nTrs,1);
Task.EndEcc = nan(nTrs,1);
Task.EndStimInd = nan(nTrs,1);
Task.EndStimLoc = nan(nTrs,1);
Task.EndX = nan(nTrs,1);
Task.EndY = nan(nTrs,1);
Task.SetSize = nan(nTrs,1);
Task.StimLoc = nan(nTrs,4);
Task.StimDiff = nan(nTrs,4);
Task.SingletonDiff = nan(nTrs,1);
Task.TargetLoc = nan(nTrs,1);
Task.TrialType = cell(nTrs,1);
Task.OppType = cell(nTrs,1);
Task.Congruent = nan(nTrs,1);
Task.Correct = nan(nTrs,1);
Task.Abort = nan(nTrs,1);
Task.error = nan(nTrs,1);
Task.Error = nan(nTrs,1);
Task.USStim = nan(nTrs,1);
Task.StimIntended = nan(nTrs,1);
Task.StimCond = nan(nTrs,1);
Task.Outcome = nan(nTrs,1);
Task.IsRepeat = nan(nTrs,1);
Task.ExtinguishType = nan(nTrs,1);
Task.ExtinguishTime = nan(nTrs,1);
Task.VertIsPro = nan(nTrs,1);
Task.StimVertical = nan(nTrs,1);
Task.StimHorizontal = nan(nTrs,1);

jjRemoveSetSize = []; %keep track of trials to remove with set size ~= 8

for jj = 1:nTrs
    if print && mod(jj,nPrint) == 0
        if exist('printStr','var')
            for ib = 1:length(printStr)
                fprintf('\b');
            end
        end
        printStr = sprintf('Working on Trial %d of %d...\n',jj,nTrs);
        fprintf(printStr);
    end
    trCodes = trialCodes{jj};%inEvs(antiHeadInds(it):endInfos(it));
    trTimes = trialTimes{jj};%inEvTms(antiHeadInds(it):endInfos(it));
    allCodes(jj,1:evntCnt(jj)) = trCodes;
    
    %% Get timings
%     if it > 1048
%             keyboard
%     end
    Task.StimOnsetToTrial(jj)      = getEvTime(trCodes,trTimes,events.Target_);
    Task.SRT(jj)            = getEvTime(trCodes,trTimes,events.Saccade_);
    Task.SaccEnd(jj)        = getEvTime(trCodes,trTimes,events.Decide_);
    Task.Reward(jj)         = getEvTime(trCodes,trTimes,events.Reward_);
    Task.Tone(jj)           = getEvTime(trCodes,trTimes,events.Tone_);
    Task.RewardTone(jj)     = getEvTime(trCodes,trTimes,events.Reward_tone);
    Task.ErrorTone(jj)      = getEvTime(trCodes,trTimes,events.Error_tone);
    Task.FixSpotOn(jj)      = getEvTime(trCodes,trTimes,events.FixSpotOn_);
    Task.FixSpotOff(jj)     = getEvTime(trCodes,trTimes,events.FixSpotOff_);
    Task.Fixation(jj)       = getEvTime(trCodes,trTimes,events.Fixate_);
    
    %% Get Stim Colors
    colorInfo = unique(trCodes(trCodes >= 700 & trCodes < 800));
    
    if any(colorInfo >= 700 & colorInfo < 710)
        Task.SingletonColor(jj) = colorInfo(colorInfo >= 700 & colorInfo < 710) - 700;
    else
        Task.SingletonColor(jj) = nan;
    end
    if any(colorInfo >= 710 & colorInfo < 720)
        Task.DistractorColor(jj) = colorInfo(colorInfo >= 710 & colorInfo < 720) - 710;
    else
        Task.DistractorColor(jj) = nan;
    end
    if any(colorInfo >= 720 & colorInfo < 730)
        Task.CueType(jj) = colorInfo(find(colorInfo >= 720 & colorInfo < 730,1)) - 720;
    else
        Task.CueType(jj) = nan;
    end
    if any(colorInfo >= 730 & colorInfo < 740)
        Task.CueColor(jj) = colorInfo(find(colorInfo >= 730 & colorInfo < 740,1)) - 730;
    else
        Task.CueColor(jj) = nan;
    end
    
    %% Get general flags about task
    if any(trCodes >= 400 & trCodes < 410)
        Task.ExtinguishType(jj) = trCodes(find(trCodes >= 400 & trCodes < 410,1)) - 400;
    end
    if any(trCodes >= 410 & trCodes < 420)
        Task.ExtinguishTime(jj) = trCodes(find(trCodes >= 410 & trCodes < 420,1)) - 410;
    end
    if any(trCodes >= 440 & trCodes < 450)
        Task.IsRepeat(jj) = trCodes(find(trCodes >= 440 & trCodes < 450,1)) - 440;
    else
        Task.IsRepeat(jj) = nan;
    end
    if any(trCodes >= 450 & trCodes < 460)
        Task.HardColor(jj) = trCodes(find(trCodes >= 450 & trCodes < 460,1)) - 450;
    else
        Task.HardColor(jj) = nan;
    end
    if any(trCodes >= 750 & trCodes < 760)
        Task.VertIsPro(jj) = trCodes(find(trCodes >= 750 & trCodes < 760,1)) - 750;
    else
        Task.VertIsPro(jj) = nan;
    end
    
    %% Get Stim Locations
    if any (trCodes >= 900 & trCodes < 1000)
        thisCodes = unique(trCodes(trCodes >= 900 & trCodes < 920));
        Task.Eccentricity(jj) = thisCodes(1) - 900;
    else
        Task.Eccentricity(jj) = nan;
    end
    locCodes = trCodes(trCodes >= 5000 & trCodes < 6000);
    diffCodes = trCodes(trCodes >= 6000 & trCodes <= 7000);
    if isempty(diffCodes)
        continue
    end
    if any(trCodes >= 420 & trCodes < 430)
        Task.StimCond(jj) = trCodes(find(trCodes >= 420 & trCodes < 430,1)) - 420;
        Task.StimIntended(jj) = Task.StimCond(jj) > 0;
    end
%     Task.SetSize(it) = length(diffCodes);
    Task.SetSize(jj) = length(locCodes);
    
    %NOTE: only working with set size eight
    if (Task.SetSize(jj) ~= 8)
      jjRemoveSetSize = [jjRemoveSetSize, jj];
      continue
    end
    
    nLoops = 0;
    while (nLoops < length(diffCodes)) && length(unique(mod(locCodes,360/Task.SetSize(jj)))) > 1
        uCodes = unique(mod(locCodes,360/Task.SetSize(jj)));
        if length(uCodes) ~= Task.SetSize(jj)
            nLoops = nLoops + 1;
            continue
        else
            [n,c] = hist(mod(locCodes,360/Task.SetSize(jj)),uCodes);
            locCodes(mod(locCodes,360/Task.SetSize(jj)) == c(n==min(n))) = [];
            nLoops = nLoops+1;
        end
    end
    if nLoops == length(diffCodes)
        continue;
    end
    if length(locCodes)
        for is = 1:Task.SetSize(jj)
            Task.StimLoc(jj,is) = locCodes(is) - 5000;
            tmpDiff = trCodes(trCodes >= (6000 + (100*(is))) & trCodes < (6000 + (100*(is)+20))) - (6000 + (100*(is)));
            tmpV = (trCodes(trCodes >= (7000 + (100*(is))) & trCodes < (7000 + (100*(is)+20))) - (7000 + (100*(is))))./10;
            if ~isempty(tmpV), stimV(is) = tmpV; else stimV(is) = nan; end
            if isempty(tmpDiff)
                Task.StimDiff(jj,is) = nan;
            else
                Task.StimDiff(jj,is) = tmpDiff(1);
            end
        end
        if any(trCodes >= 800 & trCodes < (800+Task.SetSize(jj)))
            Task.TargetLoc(jj) = Task.StimLoc(jj,trCodes(trCodes >= 800 & trCodes < (800 + Task.SetSize(jj)))-799);
        end
    end
    if any(isnan(Task.StimLoc(jj,1:Task.SetSize(jj)))) || any(hist(Task.StimLoc(jj,1:Task.SetSize(jj)),sort(unique(Task.StimLoc(jj,1:Task.SetSize(jj))))) > 1)
        continue
    end
    if ~isnan(Task.TargetLoc(jj))
        stimInd = Task.StimDiff(jj,Task.StimLoc(jj,:)==Task.TargetLoc(jj))+1;
        Task.SingletonDiff(jj) = Task.StimDiff(jj,Task.StimLoc(jj,:)==Task.TargetLoc(jj));
        if ~isnan(stimV(Task.StimLoc(jj,:)==Task.TargetLoc(jj)))
            tmpV = stimV(Task.StimLoc(jj,:)==Task.TargetLoc(jj));
            tmpH = 1./tmpV;
            if ~isfinite(Task.VertIsPro(jj)) || Task.VertIsPro(jj)
                Task.StimVertical(jj,:) = tmpV;
                Task.StimHorizontal(jj,:) = tmpH;
            end
        else
            if stimInd <= length(stimHs)
                tmpH = stimHs(stimInd);
                tmpV = stimVs(stimInd);
            else
                continue;
            end
        end
        if ~isfinite(Task.VertIsPro(jj)) || Task.VertIsPro(jj)
            if abs(tmpH - tmpV) < .001
                Task.TrialType{jj} = 'catch';
            elseif tmpH > tmpV
                Task.TrialType{jj} = 'anti';
            elseif tmpV > tmpH
                Task.TrialType{jj} = 'pro';
            else
                keyboard
            end
        else
            if abs(tmpH - tmpV) < .001
                Task.TrialType{jj} = 'catch';
            elseif tmpH > tmpV
                Task.TrialType{jj} = 'pro';
            elseif tmpV > tmpH
                Task.TrialType{jj} = 'anti';
            else
                keyboard
            end
        end
        clear tmpH tmpV
        
        if Task.SetSize(jj) > 1
            stimInd = Task.StimDiff(jj,Task.StimLoc(jj,:)==mod(Task.TargetLoc(jj)+180,360))+1;
            if sum(isfinite(stimV))==Task.SetSize(jj)
                tmpV = stimV(stimInd);
                tmpH = 1./stimV(stimInd);
            elseif stimInd <= length(stimHs)
                tmpH = stimHs(stimInd);
                tmpV = stimVs(stimInd);
            else
                continue;
            end
            
            if ~isfinite(Task.VertIsPro(jj)) || Task.VertIsPro(jj)
                if abs(tmpH - tmpV) < .001
                    Task.OppType{jj} = 'catch';
                elseif tmpH > tmpV
                    Task.OppType{jj} = 'anti';
                elseif tmpV > tmpH
                    Task.OppType{jj} = 'pro';
                else
                    keyboard
                end
            else
                if abs(tmpH - tmpV) < .001
                    Task.OppType{jj} = 'catch';
                elseif tmpH > tmpV
                    Task.OppType{jj} = 'pro';
                elseif tmpV > tmpH
                    Task.OppType{jj} = 'anti';
                else
                    keyboard
                end
            end
            clear tmpH tmpV

            if (strcmpi(Task.TrialType{jj},'pro') && strcmpi(Task.OppType{jj},'anti')) || (strcmpi(Task.TrialType{jj},'anti') && strcmpi(Task.OppType{jj},'pro'))
                Task.Congruent(jj) = 1;
                
            elseif strcmpi(Task.TrialType{jj},Task.OppType{jj})
                Task.Congruent(jj) = 0;
            else
                Task.Congruent(jj) = 2;
            end
            
        else
            Task.OppType{jj} = 'NA';
            Task.Congruent(jj) = nan;
        end
    end
    
    % Get Trial Outcome
    if any(trCodes == events.Correct_) || any(trCodes == events.CatchCorrect_)
        Task.Correct(jj) = 1;
    else
        Task.Correct(jj) = 0;
    end
    if isnan(Task.SaccEnd(jj)) && ~isnan(Task.SRT(jj))
% %         if Eyes.Good
% %             tmpT = Eyes.Times(Eyes.Times >= Task.StimOnsetToTrial(it) & Eyes.Times <= Task.SRT(it)+3000);
% %             tmpX = Eyes.X(Eyes.Times >= Task.StimOnsetToTrial(it) & Eyes.Times <= Task.SRT(it)+3000);
% %             tmpY = Eyes.Y(Eyes.Times >= Task.StimOnsetToTrial(it) & Eyes.Times <= Task.SRT(it)+3000);
% %             if strcmpi(Task.TrialType{it},'pro')
% %                 inWind = klInBox(tmpX,tmpY,[Task.Eccentricity(it)*cos(klDeg2Rad(Task.TargetLoc(it))),Task.Eccentricity(it)*sin(klDeg2Rad(Task.TargetLoc(it)))],4);
% %             else
% %                 inWind = klInBox(tmpX,tmpY,[Task.Eccentricity(it)*cos(klDeg2Rad(mod(Task.TargetLoc(it)+180,360))),Task.Eccentricity(it)*sin(klDeg2Rad(mod(Task.TargetLoc(it)+180,360)))],4);
% %             end
% %             if any(inWind)
% %                 Task.SaccEnd(it) = tmpT(find(inWind,1));
% %             end
% %             if ~isnan(Task.SaccEnd(it))
% %                 if Task.SaccEnd(it) > (100 + Task.SRT(it))
% % %                     Task.Correct(it) = 0;
% %                 end
% %             end
% %         else
            Task.SaccEnd(jj) = nan;
% %         end
    end
    
    if any(trCodes == events.Abort_)
        Task.Abort(jj) = 1;
    else
        Task.Abort(jj) = 0;
    end
    if ~Task.Abort(jj) && ~Task.Correct(jj)
        Task.Error(jj) = 1;
    else
        Task.Error(jj) = 0;
    end
    if Task.Abort(jj) == 0 && ~isnan(Task.SRT(jj))
% %         if Eyes.Good
% %             mnX = nanmean(Eyes.X(Eyes.Times >= (Task.SRT(it) + 50) & Eyes.Times <= (Task.SRT(it) + 100)));
% %             mnY = nanmean(Eyes.Y(Eyes.Times >= (Task.SRT(it) + 50) & Eyes.Times <= (Task.SRT(it) + 100)));
% %             Task.EndX(it) = mnX; Task.EndY(it) = mnY;
% %             % Figure out which stimulus was the closest
% %             tmpLocs(:,1) = cos(klDeg2Rad(Task.StimLoc(it,:))).*Task.Eccentricity(it);
% %             tmpLocs(:,2) = sin(klDeg2Rad(Task.StimLoc(it,:))).*Task.Eccentricity(it);
% %             stmDist = klEucDist([mnX,mnY],tmpLocs);
% %             tmpDist = find(stmDist == min(stmDist),1);
% %             if ~isempty(tmpDist), Task.EndStimInd(it) = tmpDist; Task.EndStimLoc(it) = Task.StimLoc(it,Task.EndStimInd(it)); end
% %             Task.EndEcc(it)   = sqrt(mnY^2 + mnX^2);
% %             baseAngle = klRad2Deg(atan(abs(mnY)/abs(mnX)));
% %             if (mnX > 0) && (mnY > 0)
% %                 Task.EndAngle(it) = baseAngle;
% %             elseif (mnX < 0) && (mnY > 0)
% %                 Task.EndAngle(it) = 180-baseAngle;
% %             elseif (mnX < 0) && (mnY < 0)
% %                 Task.EndAngle(it) = baseAngle + 180;
% %             elseif (mnX > 0) && (mnY < 0)
% %                 Task.EndAngle(it) = 360-baseAngle;
% %             end
% %             
% %         end
    end
    
end%for:trial(jj)

%remove trials due to set size ~= 8
fieldsTask = fieldnames(Task);
NUM_FIELD = length(fieldsTask);
for ff = 1:NUM_FIELD
  Task.(fieldsTask{ff})(jjRemoveSetSize,:) = [];
end%for:field(ff)

%% Get Trial Outcomes
Task.AlignTimes = Task.StimOnsetToTrial;
Task.SaccEnd    = Task.SaccEnd          - Task.StimOnsetToTrial;
Task.Reward     = Task.Reward           - Task.StimOnsetToTrial;
Task.Tone       = Task.Tone             - Task.StimOnsetToTrial;
Task.RewardTone = Task.RewardTone       - Task.StimOnsetToTrial;
Task.ErrorTone  = Task.ErrorTone        - Task.StimOnsetToTrial;
Task.FixSpotOn  = Task.FixSpotOn        - Task.StimOnsetToTrial;
Task.FixSpotOff = Task.FixSpotOff       - Task.StimOnsetToTrial;
Task.Fixation   = Task.Fixation         - Task.StimOnsetToTrial;
Task.StimOnset  = Task.StimOnsetToTrial - Task.StimOnsetToTrial; % should be all zero aferwards
% Task.GoCue 		= Task.FixSpotOff;
Task.SRT        = Task.SRT              - Task.StimOnsetToTrial - Task.FixSpotOff;

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

function outTime = getEvTime(codes,times,match)
tmp = find(codes==match,1);
if ~isempty(tmp)
    outTime = times(tmp);
else
    outTime = nan;
end
end
end
