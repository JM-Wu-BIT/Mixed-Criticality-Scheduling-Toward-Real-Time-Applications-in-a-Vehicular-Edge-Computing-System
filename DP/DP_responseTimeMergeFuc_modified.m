function [responseTime, insertPosition] = DP_responseTimeMergeFuc_modified(virtualMachines, newjob, k,DAG_communicationCost,id_In_Serves)


priorityMax = newjob(end);
DAG_id = newjob(1);
exec_priority_array = [];

priority_array=[];
finishtime_vm=[];

vm_k = virtualMachines{k};                  %Find the current virtual machine
index = find(vm_k(:,1) == DAG_id);          %Find out where the DAG task is located
if isempty(index)
    indexMax = 0;
else
    indexMax = max(index);                  %Find the location of the last DAG task, the closer the DAG tasks are to each other in the same VM, the better it is for the completion of the entire DAG task.
end
responseTime = inf;
insertPosition = 0;
for position_newjob = indexMax+1:1:size(vm_k,1)+1     
    if position_newjob~=indexMax+1
        continue
    else
        vm_k_temp = [vm_k(1:position_newjob-1,:); newjob, vm_k(end,end); vm_k(position_newjob:end,:)];       %Updating Virtual Machines
        pass_DAG = true;
        newjob_complete=[newjob, vm_k(end,end)];
        
        
        for i = 1:size(id_In_Serves,2)                   %Check that DAG tasks that are not part of this DAG task are running properly after adding this DAG task
            DAG_id_check =id_In_Serves(i);
            virtualMachinesOfi = virtualMachines;
            virtualMachinesOfi{k} = vm_k_temp;
            
            pass_DAG_id = DP_responseTimeCheckFuc_modify2(virtualMachinesOfi, DAG_id_check,DAG_communicationCost);
            
            pass_DAG = pass_DAG & pass_DAG_id;
        end
        if pass_DAG
            virtualMachines{k}=vm_k_temp;
            
            for i = 1:size(virtualMachines, 2)
                vm_i = virtualMachines{i};
                if ~isempty(vm_i)
                    id_position=find(vm_i(:,1)==DAG_id);
                    if isempty(id_position)
                        continue
                    else
                        array=[];
                        index=1;
                        location=find(vm_i(:,1)==DAG_id);
                        ahead_id=vm_i(1: location(1)-1,:);
                        lag_id=vm_i( location(end)+1:end,:);
                        index_id=[vm_i(location(1),1:2),sum(vm_i(location,3)),vm_i(location(1),4:end)];
                        array=[ahead_id;index_id; lag_id];
                        exec_time_array= DP_executionTimeFuc(array, DAG_id);%Calculate the execution time of the same DAG task
                        finishtime_vm=[finishtime_vm,exec_time_array];
                        for j = 1:size(vm_i, 1)
                            if eq(DAG_id, vm_i(j, 1))
                                deadline = vm_i(j, 4);
                                priority_array=[priority_array;DAG_id,vm_i(j,end-1),i];%DAG_id,task_priority,VM Number
                            end
                        end
                    end
                end
            end
        else
            return
        end
    end
end

DAG_communicationCost_temp=DAG_communicationCost{DAG_id};
%The sum of the execution time of all DAGs plus the communication time between tasks is the total execution time of the DAG.
finishtime_temp=sum(finishtime_vm);%Calculate the sum of the execution times of all tasks in the current DAG.

if isempty(priority_array)
    return
end

[temp, index] = sort(priority_array(:,2), 'ascend');%Ascending order based on task priority
exec_priority = priority_array(index, :);

for i=1:size(exec_priority,1)
    priority = exec_priority(i, end-1);
    if priority ==1     %The first mission does not need to consider communication time
        finish_time_i=finishtime_temp;
    else
        location=find(DAG_communicationCost_temp(1:priority-1,priority)~=-1,1);
        if isempty(location)
            finish_time_i=finishtime_temp;
        else
            if  exec_priority(location(end),end)~= exec_priority(priority,end)%If the current task is executing on a different virtual machine than its predecessor, you need to calculate the communication time
                finish_time_i=finishtime_temp+DAG_communicationCost_temp( location(end),priority);
            else
                finish_time_i=finishtime_temp;
            end
        end
    end
end

    responseTimeTemp= finish_time_i;
    if responseTimeTemp < responseTime
        responseTime = responseTimeTemp;
        insertPosition = indexMax;
    end




