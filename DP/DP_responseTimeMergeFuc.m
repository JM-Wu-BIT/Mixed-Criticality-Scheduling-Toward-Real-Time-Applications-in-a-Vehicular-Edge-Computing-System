function [responseTime, insertPosition] = DP_responseTimeMergeFuc(virtualMachines, newjob, k,DAG_communicationCost)
% newjob = [DAG_id, DAG_period, DAG_load(i), DAG_period, DAG_priority(i)];

priorityMax = newjob(end);
DAG_id = newjob(1);
exec_priority_array = [];
for i = 1:size(virtualMachines, 2)        %找出除newjob插入虚拟机之外的虚拟机中此DAG的任务，以检测插入影响
    vm_i = virtualMachines{i};              %提取虚拟机的任务
    if~eq(i, k)                                       %  只计算前k-1个虚拟机，再计算第k个虚拟机。
        for j = 1:size(vm_i, 1)                     %提取虚拟机中的任务数
            if eq(DAG_id, vm_i(j, 1))              %如果虚拟机中有DAG_id的任务，
                vm_update = DP_updateVMfuc(vm_i, DAG_id, j);               %为了将虚拟机里的DAG任务，和此DAG里的任务分开
                exec_time_j = DP_executionTimeFuc(vm_update, DAG_id);     %Calculate the execution time of the same DAG task
                priority_j = vm_i(j, end-1);
                exec_priority_array = [exec_priority_array; exec_time_j, priority_j, i];      %计算此DAG任务的每个执行时间，利用异构最早完成时间算法
            end
        end
    end
end                                                      %整个for循环用于寻找在多个虚拟机上的DAG任务并记录所在第几个虚拟机

vm_k = virtualMachines{k};                      %提取任务
index = find(vm_k(:,1) == DAG_id);          %找出DAG任务的位置
if isempty(index)                                     
    indexMax = 0;
else
    indexMax = max(index);                     %找出最后一个DAG任务的位置,在同一虚拟机内同DAG任务靠的越近越有利于整个DAG任务的完成
end
responseTime = inf;                  
insertPosition = -1;
for position_newjob = indexMax+1:1:size(vm_k,1)+1     
    vm_k_temp = [vm_k(1:position_newjob-1,:); newjob, vm_k(end,end); vm_k(position_newjob:end,:)];       %更新虚拟机
    pass_DAG = true;   
    for i = 1:DAG_id-1                                           %检查添加此DAG任务后，非此DAG任务的DAG任务是否正常运行
        DAG_id_check = i;
        %virtualMachinesOfi = virtualMachines;    
        virtualMachinesOfi{k} = vm_k_temp;
        pass_DAG_id = DP_responseTimeCheckFuc(virtualMachinesOfi, DAG_id_check,DAG_communicationCost);          %插入一个任务，检测对每个任务的影响  
        pass_DAG = pass_DAG & pass_DAG_id;     
    end
    
    if pass_DAG
        for j = 1:size(vm_k_temp, 1)                
            if eq(DAG_id, vm_k_temp(j, 1))             %找到vm_k_temp，中此DAG的任务
                vm_update = DP_updateVMfuc(vm_k_temp, DAG_id, j);           
                exec_time_j = DP_executionTimeFuc(vm_update, DAG_id);
                priority_j = vm_k_temp(j, end-1);                                                          %用于处理并行任务
                exec_priority_array = [exec_priority_array; exec_time_j, priority_j, k];       %记录从indexMax到size(vm_k,1)+1插入每个位置的执行时间以找到最优插入位置
            end
        end
        responseTimeTemp =DP_responseTimeModelFuc(exec_priority_array, DAG_id,DAG_communicationCost);
        if responseTimeTemp < responseTime            
            responseTime = responseTimeTemp;
            insertPosition = position_newjob-1;           
        end
    end
end