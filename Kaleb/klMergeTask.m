%% klMergeTask collates the structure "Task" created by individual decoding functions
%
% "Task" structure fields and calculations inspired by similar functions
% created by Wolf Zinke

function Task = klMergeTask(subTask,taskHeads)

taskStr = {'MG','Search','Capture','Pro-Anti'};
taskCode = [1502, 1507, 1508, 1509];

uTasks = nunique(taskHeads);
Task.TaskType = cell(length(taskHeads),1);
for it = 1:length(uTasks)
    taskInds = taskHeads == uTasks(it);
    [Task.TaskType{taskInds}]=deal(taskStr{taskCode == uTasks(it)});
    if isempty(subTask{it})
        continue
    end
    taskFields = fieldnames(subTask{it});
    for iField = 1:length(taskFields)
        if ~isfield(Task,taskFields{iField})
            if isnumeric(subTask{it}.(taskFields{iField}))
                Task.(taskFields{iField}) = nan(length(taskHeads),size(subTask{it}.(taskFields{iField}),2));
                Task.(taskFields{iField})(taskInds,1:size(subTask{it}.(taskFields{iField}),2)) = subTask{it}.(taskFields{iField});
            elseif iscell(subTask{it}.(taskFields{iField}))
                Task.(taskFields{iField}) = cell(length(taskHeads),size(subTask{it}.(taskFields{iField}),2));
                [subTask{it}.(taskFields{iField}){find(cellfun(@isempty,subTask{it}.(taskFields{iField})))}] = deal('NaN');
                Task.(taskFields{iField})(taskInds,1:size(subTask{it}.(taskFields{iField}),2)) = subTask{it}.(taskFields{iField});
                [Task.(taskFields{iField}){find(cellfun(@isempty,Task.(taskFields{iField})))}] = deal('NaN');
            end
        
        else
            if isnumeric(subTask{it}.(taskFields{iField}))
                Task.(taskFields{iField})(taskInds,1:size(subTask{it}.(taskFields{iField}),2)) = subTask{it}.(taskFields{iField});
            elseif iscell(subTask{it}.(taskFields{iField}))
                [subTask{it}.(taskFields{iField}){find(cellfun(@isempty,subTask{it}.(taskFields{iField})))}] = deal('NaN');
                Task.(taskFields{iField})(taskInds,1:size(subTask{it}.(taskFields{iField}),2)) = subTask{it}.(taskFields{iField});
            end
        end
    end
end
