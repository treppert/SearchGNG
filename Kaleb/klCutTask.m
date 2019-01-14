function outTask = klCutTask(inTask,crit)

% Get field names
myFields = fieldnames(inTask);

% Loop
for ii = 1:length(myFields),
    if size(inTask.(myFields{ii}),1) == length(crit),
        outTask.(myFields{ii}) = inTask.(myFields{ii})(crit,:);
    elseif size(inTask.(myFields{ii}),2) == length(crit),
        outTask.(myFields{ii}) = inTask.(myFields{ii})(:,crit);
    else
        outTask.(myFields{ii}) = inTask.(myFields{ii});
    end
end
    