%% klGetSession returns a "Task" structure and "Eyes" structure that contain the trial information and eye positions for a given session, respectively
%
% The format of "Task" is inspired by Wolf Zinke's PLX2mat.m

function [Task,Eyes,PD,EEG] = klGetSession(subject,date,varargin)

tebaMount = '/mnt/schalllab';

recFold = [tebaMount,'/data/',subject];
doLive = 0;
doSave = 0;
procDir = [tebaMount,'/Users/Kaleb/proAntiProcessed'];

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-r'}
            recFold = varargin{varStrInd(iv)+1};
        case {'-l','live'}
            doLive = varargin{varStrInd(iv)+1};
        case {'-s','save'}
            doSave = varargin{varStrInd(iv)+1};
        case {'-p'}
            procDir = varargin{varStrInd(iv)+1};
    end
end


% myFiles = dir('/mnt/teba/data/Cajal/SchallLab023_Sept_2017_US/Cajal-180221*');
myFiles = dir([recFold,'/',subject,'-',date,'*']);
for ic = 1:length(myFiles)
    [subTask{ic}, subEyes{ic}, subPD{ic}, subEEG{ic}] = klGetTask(myFiles(ic).name,'-r',recFold,'-s',doSave,'-l',doLive,'-proc',procDir);
end

goodTask = cellfun(@ (x) x.Good,subTask);
subTask = subTask(logical(goodTask));
subEyes = subEyes(logical(goodTask));
subEEG = subEEG(logical(goodTask));
Task = subTask{1};
Eyes = subEyes{1};
PD = subPD{1};
EEG = subEEG{1};
if length(subTask) > 1
    for i = 2:length(subTask)
        Task = klCatStruct(Task,subTask{i},1);
        Eyes = klCatStruct(Eyes,subEyes{i},2);
        PD = klCatStruct(PD,subPD{i},2);
        EEG = [];%klCatStruct(EEG,subEEG{i},2);
    end
end