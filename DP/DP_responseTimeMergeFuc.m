function [responseTime, insertPosition] = DP_responseTimeMergeFuc(virtualMachines, newjob, k,DAG_communicationCost)
% newjob = [DAG_id, DAG_period, DAG_load(i), DAG_period, DAG_priority(i)];

priorityMax = newjob(end);
DAG_id = newjob(1);
exec_priority_array = [];
for i = 1:size(virtualMachines, 2)        %�ҳ���newjob���������֮���������д�DAG�������Լ�����Ӱ��
    vm_i = virtualMachines{i};              %��ȡ�����������
    if~eq(i, k)                                       %  ֻ����ǰk-1����������ټ����k���������
        for j = 1:size(vm_i, 1)                     %��ȡ������е�������
            if eq(DAG_id, vm_i(j, 1))              %������������DAG_id������
                vm_update = DP_updateVMfuc(vm_i, DAG_id, j);               %Ϊ�˽���������DAG���񣬺ʹ�DAG�������ֿ�
                exec_time_j = DP_executionTimeFuc(vm_update, DAG_id);     %Calculate the execution time of the same DAG task
                priority_j = vm_i(j, end-1);
                exec_priority_array = [exec_priority_array; exec_time_j, priority_j, i];      %�����DAG�����ÿ��ִ��ʱ�䣬�����칹�������ʱ���㷨
            end
        end
    end
end                                                      %����forѭ������Ѱ���ڶ��������ϵ�DAG���񲢼�¼���ڵڼ��������

vm_k = virtualMachines{k};                      %��ȡ����
index = find(vm_k(:,1) == DAG_id);          %�ҳ�DAG�����λ��
if isempty(index)                                     
    indexMax = 0;
else
    indexMax = max(index);                     %�ҳ����һ��DAG�����λ��,��ͬһ�������ͬDAG���񿿵�Խ��Խ����������DAG��������
end
responseTime = inf;                  
insertPosition = -1;
for position_newjob = indexMax+1:1:size(vm_k,1)+1     
    vm_k_temp = [vm_k(1:position_newjob-1,:); newjob, vm_k(end,end); vm_k(position_newjob:end,:)];       %���������
    pass_DAG = true;   
    for i = 1:DAG_id-1                                           %�����Ӵ�DAG����󣬷Ǵ�DAG�����DAG�����Ƿ���������
        DAG_id_check = i;
        %virtualMachinesOfi = virtualMachines;    
        virtualMachinesOfi{k} = vm_k_temp;
        pass_DAG_id = DP_responseTimeCheckFuc(virtualMachinesOfi, DAG_id_check,DAG_communicationCost);          %����һ�����񣬼���ÿ�������Ӱ��  
        pass_DAG = pass_DAG & pass_DAG_id;     
    end
    
    if pass_DAG
        for j = 1:size(vm_k_temp, 1)                
            if eq(DAG_id, vm_k_temp(j, 1))             %�ҵ�vm_k_temp���д�DAG������
                vm_update = DP_updateVMfuc(vm_k_temp, DAG_id, j);           
                exec_time_j = DP_executionTimeFuc(vm_update, DAG_id);
                priority_j = vm_k_temp(j, end-1);                                                          %���ڴ���������
                exec_priority_array = [exec_priority_array; exec_time_j, priority_j, k];       %��¼��indexMax��size(vm_k,1)+1����ÿ��λ�õ�ִ��ʱ�����ҵ����Ų���λ��
            end
        end
        responseTimeTemp =DP_responseTimeModelFuc(exec_priority_array, DAG_id,DAG_communicationCost);
        if responseTimeTemp < responseTime            
            responseTime = responseTimeTemp;
            insertPosition = position_newjob-1;           
        end
    end
end