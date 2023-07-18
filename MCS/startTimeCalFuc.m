function itsStartTime = startTimeCalFuc(taskID, vmID, vmCELLs, itsPreTasks, DAG_comCost)
%If there are antecedent tasks, the start time is when all antecedent tasks are completed
if ~isempty(itsPreTasks)
    itsStartTime = 0;
    for i = 1:size(vmCELLs, 2)
        taskRunTimeInfo = vmCELLs{i};
        if ~isempty(taskRunTimeInfo)
            for j = 1:size(taskRunTimeInfo, 1)
                preTaskID = taskRunTimeInfo(j, 1);
                if ismember(preTaskID, itsPreTasks)
                    if isequal(i, vmID)
                        itsStartTimeTemp = taskRunTimeInfo(j, end-2);
                    else
                        itsStartTimeTemp = taskRunTimeInfo(j, end-2) + DAG_comCost(j, taskID);
                    end
                    itsStartTime = max(itsStartTime, itsStartTimeTemp);
                end
            end
        end
    end
else%If no predecessor task exists, the start time is 0
    itsStartTime = 0;
end