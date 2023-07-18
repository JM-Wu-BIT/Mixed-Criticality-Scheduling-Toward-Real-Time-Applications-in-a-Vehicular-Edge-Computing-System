function [makespan, vmCELLs,task_vm] = heftFuc(DAG_load, DAG_comCost, preTasks, vCPUwrtVM)

vmCount = size(vCPUwrtVM, 2);
for i = 1:vmCount
    vmCELLs{i} = [];
end
task_vm=zeros(1,size(DAG_load,1));
for taskID = 1:size(DAG_load, 1)
    itsPreTasks = preTasks{taskID};
    itsEndTime = inf;
    for vmID = 1:vmCount
        %Calculate the start time of the task
        %Identical VMs do not need to consider task communication costs
        itsStartTime = startTimeCalFuc(taskID, vmID, vmCELLs, itsPreTasks, DAG_comCost);
        vmWithThisID = vmCELLs{vmID};%Calculate the last completion time of the tasks executed within this VM's
        if isempty(vmWithThisID)
            timeEnd = 0;
        else
            timeEnd = vmWithThisID(end,end-2);
        end             
        vCPUcount = vCPUwrtVM(vmID);%Number of virtual CPUs
        execTime = DAG_load(taskID, vCPUcount);%The number of virtual CPUs gets the task execution time according to the table
        startTimeInThisVM = max(itsStartTime, timeEnd);%The maximum of the completion time of the predecessor task and the available time of the selected VM is used as the start time of the task
        endTimeInThisVM = startTimeInThisVM + execTime;%Completion time of the mandate
        if endTimeInThisVM < itsEndTime%If the current VM execution time is less than the minimum completion time, it will be used as the new do-small completion time
            itsEndTime = endTimeInThisVM;
            taskInfo = [taskID, vCPUcount, startTimeInThisVM, endTimeInThisVM,vmID,vCPUcount];%Record task information: task ID, number of virtual CPUs, start execution time of this VM, end execution time of this VM
            chosenVMid = vmID;%Record the selected VM ID
            task_vm(taskID)=vmID;
        end
    end
    chosenVM = vmCELLs{chosenVMid};%Record the execution information of task 1 in the virtual machine it selected
    chosenVM = [chosenVM; taskInfo];
    vmCELLs{chosenVMid} = chosenVM;
    if isequal(taskID, size(DAG_load, 1))%If the task has been completed
        makespan = chosenVM(end, end-2);%Record the completion time of the DAG
    end
end