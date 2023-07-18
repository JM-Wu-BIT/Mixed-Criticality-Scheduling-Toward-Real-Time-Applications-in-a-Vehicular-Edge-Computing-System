function schedulePass = schedulabilityTestFuc(critArray, periodArray, execLOArray, execHIArray)
%Consider whether the task meets the requirements
ULO_LO = sum((1-critArray).*execLOArray./periodArray);%Low-criticality release frequency
UHI_HI = sum(critArray.*execHIArray./periodArray);%High-criticality  release frequency

schedulePass = true;
if ULO_LO + UHI_HI > 1
    schedulePass = false;
else
    for taskID = 2:size(critArray, 2)%The first task must satisfy the response time requirement, so it is not considered
        if isequal(critArray(taskID), 0)%Obtain high-level model execution time based on task-criticality level
            Wi_H = execLOArray(taskID);
        else
            Wi_H = execHIArray(taskID);
        end
        for cursorTime = periodArray(1):periodArray(taskID)
            responseTime = Wi_H;%Response time is equal to the execution time of the task's advanced mode
            for cursorTaskID = 1:taskID
                if isequal(critArray(cursorTaskID), 0)%Calculate execution time based on current task criticality level
                    responseTime = responseTime + floor(cursorTime/periodArray(cursorTaskID))*execLOArray(cursorTaskID);
                else
                    responseTime = responseTime + floor(cursorTime/periodArray(cursorTaskID))*execHIArray(cursorTaskID);
                end
            end
            if responseTime > cursorTime
                schedulePass = false;
                break
            end
        end
    end
end