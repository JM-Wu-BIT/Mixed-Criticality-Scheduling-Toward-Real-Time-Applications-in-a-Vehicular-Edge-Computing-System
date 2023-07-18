function responseTime = DP_responseTimeSepFuc(virtualMachines, newjob, k,DAG_communicationCost)

responseTime=inf;
finishtime_vm=[];
priority_array=[];

virtualMachines_size = size(virtualMachines, 2);
new_virtualMachine = [newjob, k];% Create a new VM for newjob with compute resources k
virtualMachines{virtualMachines_size + 1} = new_virtualMachine;

DAG_id = newjob(1);
exec_priority_array = [];
for i = 1:size(virtualMachines, 2)
    vm_i = virtualMachines{i};
    
    id_position=find(vm_i(:,1)==DAG_id);%
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
         exec_time_array= DP_executionTimeFuc(array, DAG_id);%Calculate the execution time of the current task
         finishtime_vm=[finishtime_vm,exec_time_array];
         for j = 1:size(vm_i, 1)
             if eq(DAG_id, vm_i(j, 1))
                 deadline = vm_i(j, 4);
                 priority_array=[priority_array;DAG_id,vm_i(j,end-1),i];
             end
         end
    end
end
         
DAG_communicationCost_temp=DAG_communicationCost{DAG_id};
%The sum of the execution time of all DAGs plus the communication time between tasks is the total execution time of the DAG.
finishtime_temp=sum(finishtime_vm);

[temp, index] = sort(priority_array(:,2), 'ascend');
exec_priority = priority_array(index, :);
    for i=1:size(exec_priority,1)
        priority = exec_priority(i, end-1); 
        if priority ==1
            finish_time_i=finishtime_temp;
        else
            location=find(DAG_communicationCost_temp(1:priority-1,priority)~=-1,1);
            if isempty(location)
                finish_time_i=finishtime_temp;
            else                
                %If the computational resources are different, it means that the current task and the predecessor task are placed in different virtual machines, which requires additional communication time
                if  exec_priority(location(end),end)~= exec_priority(priority,end)
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
        end
    
end

  