function pass_DAG_id = DP_responseTimeCheckFuc_modify2(virtualMachinesOfi, DAG_id_check,DAG_communicationCost)

DAG_id = DAG_id_check;    
exec_priority_array = [];
priority_array=[];
finishtime_vm=[];

for i = 1:size(virtualMachinesOfi, 2)                       %  Iterate through each virtual machine
    
    vm_i = virtualMachinesOfi{i};                            %Extracting task information from a virtual machine
    if ~isempty(vm_i)
        check_id_position=find(vm_i(:,1)==DAG_id);          %Find the location of the task in the same DAG in the virtual machine
        if isempty(check_id_position)
            continue     
        else     
            location=find(vm_i(:,1)==DAG_id);
            ahead_id=vm_i(1: location(1)-1,:);%Record tasks that are not from the same DAG
            lag_id=vm_i( location(end)+1:end,:);
            index_id=[vm_i(location(1),1:2),sum(vm_i(location,3)),vm_i(location(1),4:end)];
            array=[ahead_id;index_id; lag_id];
            exec_time_array= DP_executionTimeFuc(array, DAG_id);%Calculate the execution time of the same DAG task
            finishtime_vm=[finishtime_vm,exec_time_array];
            for j = 1:size(vm_i, 1)
                 if eq(DAG_id, vm_i(j, 1))
                     deadline = vm_i(j, 4);
                     priority_array=[priority_array;DAG_id,vm_i(j,end-1),i];
                 end
            end
        end
    end
end
                            

DAG_communicationCost_temp=DAG_communicationCost{DAG_id};
finishtime_temp=sum(finishtime_vm);%Calculate the sum of the execution times of all tasks in the current DAG.
    
if isempty(priority_array)
    pass_DAG_id =false;
    return
end

[temp, index] = sort(priority_array(:,2), 'ascend');
exec_priority = priority_array(index, :);

%The sum of the execution time of all DAGs plus the communication time between tasks is the total execution time of the DAG.
for i=1:size(exec_priority,1)
    priority = exec_priority(i, end-1); 

    if priority ==1
        finish_time_i=finishtime_temp;
    else
        location=find(DAG_communicationCost_temp(1:priority-1,priority)~=-1,1);
        if isempty(location)
            finish_time_i=finishtime_temp;
        else
            if  exec_priority(location(end),end)~= exec_priority(priority,end)
                 finish_time_i=finishtime_temp+DAG_communicationCost_temp( location(end),priority);
            else
                 finish_time_i=finishtime_temp;
            end
        end
    end
end
%If the execution time of the DAG is less than the deadline, it can be executed, and otherwise it cannot be executed.
responseTime=finish_time_i;
if responseTime < deadline
    pass_DAG_id = true;
else
    pass_DAG_id = false;
end
