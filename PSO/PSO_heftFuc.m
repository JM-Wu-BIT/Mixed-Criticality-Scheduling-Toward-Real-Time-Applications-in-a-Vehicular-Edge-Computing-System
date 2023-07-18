function [makespan, vmCELLs] = PSO_heftFuc(DAG_index,period,DAG_load, DAG_comCost, preTasks, vCPUwrtVM,DAG_vm)

vmCount = size(vCPUwrtVM, 2);
for i = 1:vmCount
    vmCELLs{i} = [];
end

for taskID = 1:size(DAG_load, 1)
    itsPreTasks = preTasks{taskID};%Find the predecessor of the current task
    itsEndTime = inf;
    vmID=DAG_vm(taskID);%Virtual Machines for Tasking
    itsStartTime = PSO_startTimeCalFuc(taskID, vmID, vmCELLs, itsPreTasks, DAG_comCost);%Calculating task start time
    vmWithThisID = vmCELLs{vmID};
    vCPUcount=vCPUwrtVM(vmID);
    if isempty(vmWithThisID)%Calculate the available time for the current virtual machine
        timeEnd = 0;
    else
        timeEnd = vmWithThisID(end,3)+vmWithThisID(end,4);
    end
    startTimeInThisVM = max(itsStartTime, timeEnd);
    execTime = DAG_load(taskID, vCPUcount);%Execution time of tasks
    taskInfo=[DAG_index,period,startTimeInThisVM,execTime,taskID,vmID,vCPUcount];
    
    chosenVM = vmCELLs{vmID};%Record the execution information of the task in the virtual machine of its choice
    chosenVM = [chosenVM; taskInfo];
    vmCELLs{vmID} = chosenVM;
    
    if isequal(taskID, size(DAG_load, 1))%If the task has been completed
        makespan = chosenVM(end, 3)+chosenVM(end, 4);%Record the completion time of the DAG
    end
end