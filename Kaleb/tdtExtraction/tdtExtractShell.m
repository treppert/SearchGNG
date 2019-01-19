function success = tdtExtractShell(fileName)

success = 0;
reSort = 0;
dataDir= [mlRoot,'DATA/dataProcessed'];
putDir = [tebaMount,'Users/Kaleb/proAntiProcessed/',fileName];

% try
    if reSort || length(dir([dataDir,filesep,fileName,'*'])) < 2
        for i = 1:2
            masterTdt_asFun(fileName,i);
        end
    end
    
    sortFolds=dir([dataDir,filesep,fileName,'*']);
    for iz = 1:2
        clearvars -except iz z sortFolds reSort success dataDir fileName putDir
        if (isempty(dir([sortFolds(iz).folder,filesep,sortFolds(iz).name,'/chan*.mat'])) && isempty(dir([putDir,filesep,'/Chan*']))) || reSort
            rez = load(sprintf('/home/loweka/DATA/dataProcessed/%s/rez.mat',sortFolds(iz).name));
            klRezToSpks(rez,'-r',[tebaMount,'data/Kaleb/antiSessions/']);%'Users/Kaleb/proAntiRaw']);
        end
    end
    
    if ~exist(putDir,'file')
        mkdir(putDir);
    end
    chan1s = dir(['/home/loweka/DATA/dataProcessed/',fileName,'_probe1/chan*.mat']);
    for i = 1:length(chan1s)
        unitFold = [putDir,filesep,'C',chan1s(i).name(2:(end-4))];
        if ~exist(unitFold), mkdir(unitFold); end
        movefile([chan1s(i).folder,filesep,chan1s(i).name],[unitFold,filesep,chan1s(i).name]);
    end
    chan1s = dir(['/home/loweka/DATA/dataProcessed/',fileName,'_probe2/chan*.mat']);
    for i = 1:length(chan1s)
        unitFold = [putDir,filesep,'C',chan1s(i).name(2:(end-4))];
        if ~exist(unitFold), mkdir(unitFold); end
        movefile([chan1s(i).folder,filesep,chan1s(i).name],[unitFold,filesep,chan1s(i).name]);
    end
    
    if ~exist([putDir,filesep,'Behav.mat']) || reSort
        Task = klGetTask(fileName,'-p',1,'-f',1);
    else
        load([putDir,filesep,'Behav.mat']);
    end
    if any(strcmpi(Task.TaskType,'Pro-Anti'))
        klProAntiPhysio(fileName);
    end
    if any(strcmpi(Task.TaskType,'MG'))
        klMGPhysio(fileName);
    end    
    
    success = 1;
% end