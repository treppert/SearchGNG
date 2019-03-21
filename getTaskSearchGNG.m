function [ Task , Eyes ] = getTaskSearchGNG( sessDir , monkey )
%getTaskSearchGNG Summary of this function goes here
%   Detailed explanation goes here

NUM_SESSION = length(sessDir);

if strcmp(monkey(1), 'L')
  ROOT_DIR = 'Z:\data\Leonardo\Search-Go-NoGo\';
elseif strcmp(monkey(1), 'D')
  ROOT_DIR = 'Z:\data\Darwin\proNoElongationColor\';
end
% ROOT_DIR = '/mnt/schalllab/data/Leonardo/Search-Go-NoGo/';
% ROOT_DIR = '/mnt/schalllab/data/Darwin/proNoElongationColor/';

MIN_NUM_TRIAL = 100;
Eyes = 0;
print = 1;
nPrint = 500;

%event code definitions (EVENTDEF.pro)
CODE_TRIAL_START = 1666;
CODE_TRIAL_END = 1667;
CODES_TRIAL_TYPES = 1500:1510;
CODE_TRIAL_MG = 1502;
CODE_TRIAL_PROANTI = 1509;
CODE_INFOS_START = 2998;
CODE_INFOS_END = 2999;

Task = [];

for kk = 13:13%1:NUM_SESSION
%   if ismember(kk, [13,24]); continue; end
  fprintf('Processing session %s\n', sessDir{kk})
  
  %get TDT event codes and corresponding timestamps
  [eventCodesTDT,eventTimesTDT] = klGetEvsTDT([ROOT_DIR, sessDir{kk}]);

  %isolate event codes corresponding to trial start/end
  % startInds = find(tdtEvs == trStartCode);
  idxTrialEnd = find(eventCodesTDT == CODE_TRIAL_END);
  idxTrialStart = find(ismember(eventCodesTDT,CODES_TRIAL_TYPES));
  
  NUM_TRIAL = length(idxTrialStart);
  
  %% What does this do ??
  
  endInfoTmp = find(eventCodesTDT == CODE_INFOS_END);
  
  endInfos = NaN(1,length(idxTrialStart));
  trEnds = NaN(1,length(idxTrialStart));
  
  for jj = 1:NUM_TRIAL-1
    
    tmp = find(endInfoTmp > idxTrialStart(jj) & endInfoTmp < idxTrialStart(jj+1),1);
    checkStart = endInfoTmp(tmp);
    
    tmp = find(idxTrialEnd > idxTrialStart(jj) & idxTrialEnd < idxTrialStart(jj+1),1);
    checkEnd = idxTrialEnd(tmp);
    
    if ~isempty(checkStart)
      endInfos(jj) = checkStart;
    else
      endInfos(jj) = NaN;
    end

    if ~isempty(checkEnd)
      trEnds(jj) = checkEnd;
    else
      trEnds(jj) = NaN;
    end

  end
  
  checkStart = endInfoTmp(find(endInfoTmp > idxTrialStart(end),1));
  
  checkEnd = idxTrialEnd(find(idxTrialEnd > idxTrialStart(end),1));
  
  if ~isempty(checkStart), endInfos(jj+1) = checkStart; else endInfos(jj+1) = NaN; end
  
  if ~isempty(checkEnd), trEnds(jj+1) = checkEnd; else trEnds(jj+1) = NaN; end
  
  idxTrialStart(isnan(endInfos)) = [];
  trEnds(isnan(endInfos)) = [];
  endInfos(isnan(endInfos)) = [];
  
  %% ***

  % Get the trial codes
  nTrs = length(idxTrialStart);%min([length(startInds),length(endInds)]);

  if (nTrs < MIN_NUM_TRIAL)
    error('Number of trials is less than %d', MIN_NUM_TRIAL)
  end
  
  eventCodes = cell(1,nTrs);
  eventTimes = cell(1,nTrs);
  for jj = 1:nTrs
    eventCodes{jj} = eventCodesTDT(idxTrialStart(jj):endInfos(jj));
    eventTimes{jj} = eventTimesTDT(idxTrialStart(jj):endInfos(jj));
  end
  dashes = strfind(sessDir{kk},'-');

  % Get the trial headers
  trHeads = eventCodesTDT(idxTrialStart);

  idxTrialStart(~ismember(trHeads,CODE_TRIAL_PROANTI)) = [];
  trEnds(~ismember(trHeads,CODE_TRIAL_PROANTI)) = [];
  trHeads(~ismember(trHeads,CODE_TRIAL_PROANTI)) = [];

  EV = TEMPO_EV_cosman_rig028;
  TaskKK = klDecodeAnti(eventCodes(trHeads==CODE_TRIAL_PROANTI), ...
    eventTimes(trHeads==CODE_TRIAL_PROANTI),EV,0,'-p',print,'-np',nPrint);
  
  %remove all aborted trials
  idxAbort = (TaskKK.Abort == 1);
  fieldsTask = fieldnames(TaskKK);
  numFields = length(fieldsTask);
  for ff = 1:numFields
    TaskKK.(fieldsTask{ff})(idxAbort,:) = [];
  end%for:field(ff)

  TaskKK.error_names = {'False','Early','Late','FixBreak','HoldError','CatchErrorNoGo'};
  TaskKK.trStarts = eventTimesTDT(idxTrialStart);
  TaskKK.trEnds(isfinite(trEnds)) = eventTimesTDT(trEnds(isfinite(trEnds)));
  TaskKK.Good = 1;
  TaskKK.Subject = sessDir{kk}(1:(dashes(1)-1));
  TaskKK.Date = sessDir{kk}((dashes(1)+1):(dashes(2)-1));
  TaskKK.fromEyes = ones(size(TaskKK.SRT));
  
  Task = cat(2, Task, TaskKK);
  
end%for:session(kk)

Task = rmfield(Task, {'Abort'});

end%fxngetTaskSearchGNG()

