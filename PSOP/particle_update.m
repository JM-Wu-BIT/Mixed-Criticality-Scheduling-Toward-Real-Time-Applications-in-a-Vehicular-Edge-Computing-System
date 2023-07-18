function [target,virtualMachines_success,rate]=particle_update(particle,C_s,VM_nums,ServerNum,DAG,DAG_Task_Num)
%Initializing the Virtual Machine
for s=1:ServerNum
    if isequal(1,s)
        virtualMachines{s}{VM_nums(s)}=[];
    else
        virtualMachines{s}{VM_nums(s)-VM_nums(s-1)}=[];
    end
end

virtualMachines_success=virtualMachines;
Server_alpha=zeros(1,ServerNum);
fin_target=0;
target=[];
task_num=DAG_Task_Num(end);
ServerIndex=round(particle(1:size(DAG,2)));%The server where each DAG is located
for DAG_id=1:size(DAG,2)
    DAG{DAG_id}{6}=ServerIndex(DAG_id);
end
VMIndex=zeros(1,DAG_Task_Num(end));
for i=1:size(DAG,2)%Calculate the VM selected for each task for each DAG
    s=DAG{i}{6};
    if isequal(s,1)
        vm_n=VM_nums(s);
    else
        vm_n=VM_nums(s)-VM_nums(s-1);
    end
    %Virtual machine number assigned to each task
    if isequal(i,1)
        VMIndex(1:DAG_Task_Num(i)) = floor(particle(size(DAG,2)+1:size(DAG,2)+DAG_Task_Num(i))* vm_n) + 1;
    else
        VMIndex(DAG_Task_Num(i-1)+1:DAG_Task_Num(i)) = floor(particle(size(DAG,2)+DAG_Task_Num(i-1)+1:size(DAG,2)+DAG_Task_Num(i))* vm_n) + 1;
    end
end

vCPU_VM = round(particle(size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(end)));%Compute resources (number of virtual CPUs) per server per virtual machine

for s=1:ServerNum               %Selection of tasks to be performed according to the server
    DAG_in_server{s}=find(ServerIndex==s);
end 

critArray = [];
periodArray = [];
execArray = [];

DAG_finish_count=0;
finish_num=0;
for s=1:ServerNum
    if isempty(DAG_in_server{s})%If the server is idle
        alpha=0;
    else
        M=zeros(2,size(DAG_in_server{s},2));
        for m=1:size(DAG_in_server{s},2)
            M(1,m)=DAG_in_server{s}(m);%The first line corresponds to the DAG No. within the server
            M(2,m)=DAG{DAG_in_server{s}(m)}{4};%The second row corresponds to the period of the DAG
        end
        [~,index]=sort(M(2,:), 'ascend');%Sort by DAG period in ascending order
        DAG_assign_order=M(1,index);
        if isequal(s,1)
            server_vcpu=vCPU_VM(1:VM_nums(s));
        else
            server_vcpu=vCPU_VM(VM_nums(s-1)+1:VM_nums(s));
        end
                                  %DAG, DAG execution order, number of compute resources per VM, number of tasks in the current DAG
        alpha=PSO_alphaComputeFuc(DAG, DAG_assign_order,server_vcpu,VMIndex,DAG_Task_Num);
    end
    Server_alpha(s)=alpha;
end  
target=Server_alpha;
%Calculate the number of DAGs successfully executed
rate=size(DAG,2);
for s=1:ServerNum
    if Server_alpha(s)<0.01
        rate=rate-size(DAG_in_server{s},2);
    end
end

end

