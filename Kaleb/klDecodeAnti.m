%% klDecodeAnti creates the structure "Task" that contains task information for pro/anti trials
%
% "Task" structure fields and calculations inspired by similar functions
% created by Wolf Zinke

function Task = klDecodeAnti(trialCodes,trialTimes,events,Eyes)

STIMHORZ = [0.5 1.0 2.0 0.7 1.41];
STIMVERT = [2.0 1.0 0.5 1.41 0.7];

NUM_TRIAL = length(trialCodes);

Task = new_struct({'StimOnsetToTrial','Fixation','FixSpotOn','FixSpotOff', ...
  'Reward','SaccEnd','SRT','Tone','SingletonColor','DistractorColor','HardColor', ...
  'CueType','CueColor','Eccentricity', 'SetSize','StimLoc','StimDiff','SingletonDiff','TargetLoc', ...
  'Correct','Abort','error','Error','StimIntended','StimCond','IsRepeat', ...
  'StimVertical','StimHorizontal'}, 'dim',[1,1]);

Task = populate_struct(Task, {'StimOnsetToTrial','Fixation','FixSpotOn','FixSpotOff', ...
  'Reward','SaccEnd','SRT','Tone','SingletonColor','DistractorColor','HardColor', ...
  'CueType','CueColor','Eccentricity', 'SetSize','SingletonDiff','TargetLoc', ...
  'Correct','Abort','error','Error','StimIntended','StimCond','IsRepeat', ...
  'StimVertical','StimHorizontal'}, NaN(NUM_TRIAL,1));

Task.StimLoc = NaN(NUM_TRIAL,4);
Task.StimDiff = NaN(NUM_TRIAL,4);

jjRemoveSetSize = []; %keep track of trials to remove with set size ~= 8

for jj = 1:NUM_TRIAL
  trCodesJJ = trialCodes{jj};%inEvs(antiHeadInds(it):endInfos(it));
  trTimesJJ = trialTimes{jj};%inEvTms(antiHeadInds(it):endInfos(it));

  %% Task timing
  Task.StimOnsetToTrial(jj)      = getEvTime(trCodesJJ,trTimesJJ,events.Target_);
  Task.SRT(jj)            = getEvTime(trCodesJJ,trTimesJJ,events.Saccade_);
  Task.SaccEnd(jj)        = getEvTime(trCodesJJ,trTimesJJ,events.Decide_);
  Task.Reward(jj)         = getEvTime(trCodesJJ,trTimesJJ,events.Reward_);
  Task.Tone(jj)           = getEvTime(trCodesJJ,trTimesJJ,events.Tone_);
%   Task.RewardTone(jj)     = getEvTime(trCodesJJ,trTimesJJ,events.Reward_tone);
%   Task.ErrorTone(jj)      = getEvTime(trCodesJJ,trTimesJJ,events.Error_tone);
  Task.FixSpotOn(jj)      = getEvTime(trCodesJJ,trTimesJJ,events.FixSpotOn_);
  Task.FixSpotOff(jj)     = getEvTime(trCodesJJ,trTimesJJ,events.FixSpotOff_);
  Task.Fixation(jj)       = getEvTime(trCodesJJ,trTimesJJ,events.Fixate_);

  %% Get Stim Colors
  colorInfos = unique(trCodesJJ(trCodesJJ >= 700 & trCodesJJ < 800));

  if any(colorInfos >= 700 & colorInfos < 710)
%     Task.SingletonColor(jj) = colorInfos(colorInfos >= 700 & colorInfos < 710) - 700;
  end
  if any(colorInfos >= 710 & colorInfos < 720)
    Task.DistractorColor(jj) = colorInfos(colorInfos >= 710 & colorInfos < 720) - 710;
  end
  if any(colorInfos >= 720 & colorInfos < 730)
    Task.CueType(jj) = colorInfos(find(colorInfos >= 720 & colorInfos < 730,1)) - 720;
  end
  if any(colorInfos >= 730 & colorInfos < 740)
    Task.CueColor(jj) = colorInfos(find(colorInfos >= 730 & colorInfos < 740,1)) - 730;
  end

  %% Get general flags about task
  if any(trCodesJJ >= 440 & trCodesJJ < 450)
    Task.IsRepeat(jj) = trCodesJJ(find(trCodesJJ >= 440 & trCodesJJ < 450,1)) - 440;
  end
  if any(trCodesJJ >= 450 & trCodesJJ < 460)
    Task.HardColor(jj) = trCodesJJ(find(trCodesJJ >= 450 & trCodesJJ < 460,1)) - 450;
  end

  %% Get Stim Locations
  if any (trCodesJJ >= 900 & trCodesJJ < 1000)
    thisCodes = unique(trCodesJJ(trCodesJJ >= 900 & trCodesJJ < 920));
    Task.Eccentricity(jj) = thisCodes(1) - 900;
  end
  
  locCodes = trCodesJJ(trCodesJJ >= 5000 & trCodesJJ < 6000);
  diffCodes = trCodesJJ(trCodesJJ >= 6000 & trCodesJJ <= 7000);
  
  if isempty(diffCodes)
    continue
  end
  
  if any(trCodesJJ >= 420 & trCodesJJ < 430)
      Task.StimCond(jj) = trCodesJJ(find(trCodesJJ >= 420 & trCodesJJ < 430,1)) - 420;
      Task.StimIntended(jj) = Task.StimCond(jj) > 0;
  end
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
    continue
  end
  if ~isempty(locCodes)
    for is = 1:Task.SetSize(jj)
      Task.StimLoc(jj,is) = locCodes(is) - 5000;
      tmpDiff = trCodesJJ(trCodesJJ >= (6000 + (100*(is))) & trCodesJJ < (6000 + (100*(is)+20))) - (6000 + (100*(is)));
      tmpV = (trCodesJJ(trCodesJJ >= (7000 + (100*(is))) & trCodesJJ < (7000 + (100*(is)+20))) - (7000 + (100*(is))))./10;
      if ~isempty(tmpV), stimV(is) = tmpV; else stimV(is) = NaN; end
      if ~isempty(tmpDiff)
        Task.StimDiff(jj,is) = tmpDiff(1);
      end
    end
    
    if any(trCodesJJ >= 800 & trCodesJJ < (800+Task.SetSize(jj)))
      Task.TargetLoc(jj) = Task.StimLoc(jj,trCodesJJ(trCodesJJ >= 800 & trCodesJJ < (800 + Task.SetSize(jj)))-799);
    end
  end%if:~isempty(locCodes)
  
%   if any(isnan(Task.StimLoc(jj,1:Task.SetSize(jj)))) || any(hist(Task.StimLoc(jj,1:Task.SetSize(jj)),sort(unique(Task.StimLoc(jj,1:Task.SetSize(jj))))) > 1)
%     continue
%   end
  
  if ~isnan(Task.TargetLoc(jj))
    stimInd = Task.StimDiff(jj,Task.StimLoc(jj,:)==Task.TargetLoc(jj))+1;
    Task.SingletonDiff(jj) = Task.StimDiff(jj,Task.StimLoc(jj,:)==Task.TargetLoc(jj));
    if ~isnan(stimV(Task.StimLoc(jj,:)==Task.TargetLoc(jj)))
      tmpV = stimV(Task.StimLoc(jj,:)==Task.TargetLoc(jj));
      tmpH = 1./tmpV;
      Task.StimVertical(jj,:) = tmpV;
      Task.StimHorizontal(jj,:) = tmpH;
    else
      if stimInd <= length(STIMHORZ)
        tmpH = STIMHORZ(stimInd);
        tmpV = STIMVERT(stimInd);
      else
        continue
      end
    end

    if Task.SetSize(jj) > 1
      stimInd = Task.StimDiff(jj,Task.StimLoc(jj,:)==mod(Task.TargetLoc(jj)+180,360))+1;
      if sum(isfinite(stimV))==Task.SetSize(jj)
        tmpV = stimV(stimInd);
        tmpH = 1./stimV(stimInd);
      elseif stimInd <= length(STIMHORZ)
        tmpH = STIMHORZ(stimInd);
        tmpV = STIMVERT(stimInd);
      else
        continue
      end
    end%if:SetSize > 1
  end%if:~isnan(Task.TargetLoc(jj))

  % Get Trial Outcome
  if any(trCodesJJ == events.Correct_) || any(trCodesJJ == events.CatchCorrect_)
      Task.Correct(jj) = 1;
  else
      Task.Correct(jj) = 0;
  end
  if isnan(Task.SaccEnd(jj)) && ~isnan(Task.SRT(jj))
%     if Eyes.Good
%       tmpT = Eyes.Times(Eyes.Times >= Task.StimOnsetToTrial(it) & Eyes.Times <= Task.SRT(it)+3000);
%       tmpX = Eyes.X(Eyes.Times >= Task.StimOnsetToTrial(it) & Eyes.Times <= Task.SRT(it)+3000);
%       tmpY = Eyes.Y(Eyes.Times >= Task.StimOnsetToTrial(it) & Eyes.Times <= Task.SRT(it)+3000);
%       if strcmpi(Task.TrialType{it},'pro')
%         inWind = klInBox(tmpX,tmpY,[Task.Eccentricity(it)*cos(klDeg2Rad(Task.TargetLoc(it))),Task.Eccentricity(it)*sin(klDeg2Rad(Task.TargetLoc(it)))],4);
%       else
%         inWind = klInBox(tmpX,tmpY,[Task.Eccentricity(it)*cos(klDeg2Rad(mod(Task.TargetLoc(it)+180,360))),Task.Eccentricity(it)*sin(klDeg2Rad(mod(Task.TargetLoc(it)+180,360)))],4);
%       end
%       if any(inWind)
%         Task.SaccEnd(it) = tmpT(find(inWind,1));
%       end
%       if ~isnan(Task.SaccEnd(it))
%         if Task.SaccEnd(it) > (100 + Task.SRT(it))
%         end
%       end
%     else
%       Task.SaccEnd(jj) = NaN;
%     end
  end

  if any(trCodesJJ == events.Abort_)
      Task.Abort(jj) = 1;
  else
      Task.Abort(jj) = 0;
  end
  if ~Task.Abort(jj) && ~Task.Correct(jj)
      Task.Error(jj) = 1;
  else
      Task.Error(jj) = 0;
  end
    
end%for:trial(jj)

%remove trials due to set size ~= 8
fieldsTask = fieldnames(Task);
NUM_FIELD = length(fieldsTask);
for ff = 1:NUM_FIELD
  Task.(fieldsTask{ff})(jjRemoveSetSize,:) = [];
end%for:field(ff)

%% Get Trial Outcomes
Task.SaccEnd    = Task.SaccEnd          - Task.StimOnsetToTrial;
Task.Reward     = Task.Reward           - Task.StimOnsetToTrial;
Task.Tone       = Task.Tone             - Task.StimOnsetToTrial;
Task.FixSpotOn  = Task.FixSpotOn        - Task.StimOnsetToTrial;
Task.FixSpotOff = Task.FixSpotOff       - Task.StimOnsetToTrial;
Task.Fixation   = Task.Fixation         - Task.StimOnsetToTrial;
Task.StimOnset  = Task.StimOnsetToTrial - Task.StimOnsetToTrial; % should be all zero aferwards
Task.SRT        = Task.SRT              - Task.StimOnsetToTrial - Task.FixSpotOff;

function outTime = getEvTime(codes,times,match)
outTime = NaN;
tmp = find(codes==match,1);
if ~isempty(tmp)
    outTime = times(tmp);
end
end%util:getEvTime()

end%fxn:klDecodeAnti()
