function [ Task , Eyes ] = getTaskSearchGNG( sessDir )
%getTaskSearchGNG Summary of this function goes here
%   Detailed explanation goes here

MIN_NUM_TRIAL = 100;
Eyes = 0;
print = 1;
nPrint = 500;

% Set some code identifiers
% trStartCode = 1666;
trEndCode = 1667;
taskHeaders = 1500:1510;
mgHeader = 1502;
antiHeader = 1509;
infoEndCode = 2999;

% Get event codes and times
[tdtEvs,tdtEvTms] = klGetEvsTDT(sessDir);
if (~any(tdtEvs > 6000 & tdtEvs < 7000))
  error('No event codes between 6000 and 7000')
end

% Find trial starts and ends
% startInds = find(tdtEvs == trStartCode);
endInds = find(tdtEvs == trEndCode);
trHeadInds = find(ismember(tdtEvs,taskHeaders));

if isempty(trHeadInds)
  error('Array "trHeadInds" is empty')
%   Task.Good = 0;
end

endInfoTmp = find(tdtEvs == infoEndCode);
endInfos = NaN(1,length(trHeadInds));
trEnds = NaN(1,length(trHeadInds));
for it = 1:(length(trHeadInds)-1)
    check = endInfoTmp(find(endInfoTmp > trHeadInds(it) & endInfoTmp < trHeadInds(it+1),1));
    checkEnd = endInds(find(endInds > trHeadInds(it) & endInds < trHeadInds(it+1),1));
    if ~isempty(check), endInfos(it) = check; else endInfos(it) = NaN; end
    if ~isempty(checkEnd), trEnds(it) = checkEnd; else trEnds(it) = NaN; end
end
check = endInfoTmp(find(endInfoTmp > trHeadInds(end),1));
checkEnd = endInds(find(endInds > trHeadInds(end),1));
if ~isempty(check), endInfos(it+1) = check; else endInfos(it+1) = NaN; end
if ~isempty(checkEnd), trEnds(it+1) = checkEnd; else trEnds(it+1) = NaN; end
trHeadInds(isnan(endInfos)) = [];
trEnds(isnan(endInfos)) = [];
endInfos(isnan(endInfos)) = [];

% Get the trial codes
nTrs = length(trHeadInds);%min([length(startInds),length(endInds)]);

if (nTrs < MIN_NUM_TRIAL)
  error('Number of trials is less than %d', MIN_NUM_TRIAL)
end

for it = 1:nTrs
  trialCodes{it,1} = tdtEvs(trHeadInds(it):endInfos(it));
  trialTimes{it,1} = tdtEvTms(trHeadInds(it):endInfos(it));
end
dashes = strfind(sessDir,'-');

% Get the trial headers
trHeads = tdtEvs(trHeadInds);

trHeadInds(~ismember(trHeads,antiHeader)) = [];
trEnds(~ismember(trHeads,antiHeader)) = [];
trHeads(~ismember(trHeads,antiHeader)) = [];

EV = TEMPO_EV_cosman_rig028;
Task = klDecodeAnti(trialCodes(trHeads==antiHeader,1),trialTimes(trHeads==antiHeader,1),EV,0,'-p',print,'-np',nPrint);

Task.error_names = {'False','Early','Late','FixBreak','HoldError','CatchErrorNoGo'};
Task.trStarts = tdtEvTms(trHeadInds);
Task.trEnds(isfinite(trEnds)) = tdtEvTms(trEnds(isfinite(trEnds)));
Task.Good = 1;
Task.Subject = sessDir(1:(dashes(1)-1));
Task.Date = sessDir((dashes(1)+1):(dashes(2)-1));
Task.fromEyes = ones(size(Task.SRT));

end%fxngetTaskSearchGNG()

