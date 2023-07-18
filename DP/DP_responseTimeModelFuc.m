function responseTime = DP_responseTimeModelFuc(exec_priority_array, DAG_id,DAG_communicationCost)

responseTime = 0;
feasibleTime_vm = zeros(max(exec_priority_array(:,end)), 1);         %Used to store sequential execution times of the same DAG tasks in the same virtual machine

DAG_communicationCost_temp=DAG_communicationCost;

DAG_edge = zeros(size(DAG_communicationCost_temp ,2));
for r=1:size(DAG_communicationCost_temp,2)
    for h=1:size(DAG_communicationCost_temp,1)
        if DAG_communicationCost_temp(r,h)~=-1
            DAG_edge(r,h)=1;
        end
    end
end

[temp, index] = sort(exec_priority_array(:,2), 'ascend');
exec_priority_array = exec_priority_array(index, :);
for i = 1:size(exec_priority_array, 1)                   %
    vm_index = exec_priority_array(i, end);           %Indicates which virtual machine this DAG task is in
    priority = exec_priority_array(i, end-1);          %Parallel tasks are executed in the order of their previously assigned priorities

    if priority==1  
        finishTime_i = max(feasibleTime_vm(vm_index), max(DAG_edge(:,priority))) + exec_priority_array(i, 1);
    else      
        location=find(DAG_communicationCost_temp(1:priority-1,priority)~=-1,1);
        if isempty(location)
            finishTime_i = max(feasibleTime_vm(vm_index), max(DAG_edge(:,priority))) + exec_priority_array(i, 1);
        else
            if exec_priority_array(location(end),end)~=exec_priority_array(priority,end)                
                finishTime_i =max(feasibleTime_vm(vm_index), max(DAG_edge(:,priority))+DAG_communicationCost_temp( location(end),priority))+ exec_priority_array(i, 1) ;
            else
                finishTime_i = max(feasibleTime_vm(vm_index), max(DAG_edge(:,priority))) + exec_priority_array(i, 1);
            end
        end
    end
    if eq(i, size(exec_priority_array, 1))                   
        DAG_edge(priority,end) =  finishTime_i;        
    else
        DAG_edge(priority,:) = DAG_edge(priority,:)*finishTime_i;        %The same task in different insertion locations
    end
    feasibleTime_vm(vm_index) = finishTime_i;                    %Indicates the predecessor task completion time before the start of the target task
    old_vm_index=vm_index;
end

for r=1:size(DAG_edge,2)
    for h=1:size(DAG_edge,1)
        
        
        if DAG_edge(r,h)==1
            DAG_edge(r,h)=0;
        end
    end
end

responseTime = max(max(DAG_edge));

