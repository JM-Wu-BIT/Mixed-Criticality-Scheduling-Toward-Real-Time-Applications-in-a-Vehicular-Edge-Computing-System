function [Gbest_y,rate,targetOutput] = PSO(ServerNum,C_s,DAG,Server_vcpu,Server_choice,DAG_task)

n=200;%Number of particles
iter=500;%Number of iterations
c1=2;%learning factor
c2=2;
w=0.6;%inertial weighting
vmax = 0.8;  %Velocity Maximum
rate=0;
Gbest_y_old = 0;
Gbest_x = 0;
ServerResult = {};
alpha=[];
DAG_id=1:size(DAG,2);
serverchoice=[];
for i=1:size(DAG,2)
    serverchoice=[serverchoice,DAG{i}{6}];%Find the currently assigned server for each DAG
end
VM_nums=[];
flag=1;
%If several parameters exist, they are set to the initial data of the first particle
if exist('Server_vcpu')&&exist('Server_choice')&&exist('DAG_task')
    temp=0;
    flag=2;
    for i=1:size(Server_vcpu,2)
        vm_count=size(Server_vcpu{i},2);
        if isequal(vm_count,0)
            vm_count=floor(C_s/3)+1;
        end
        temp=temp+vm_count;
        VM_nums=[VM_nums,temp];
    end
else
    temp=0;
    vm_count=floor(C_s/3)+1;
    for i=1:ServerNum
        temp=temp+vm_count;
        VM_nums=[VM_nums,temp];
    end
end
M=zeros(1,DAG_id(end));
for m=1:DAG_id(end)
    M(1,m)=DAG{m}{5};%Record DAG criticality
end
[~,index]=sort(M(1,:), 'descend');%Sort by criticality descending
DAG_assign_order=index;

DAG_Task_Num=[];
temp=0;


for i = 1: size(DAG,2)
    temp=temp+size(DAG{i}{2},1);
    DAG_Task_Num=[DAG_Task_Num,temp];
end

task_num = DAG_Task_Num(end);%Total number of tasks for all DAGs
x=zeros(n,size(DAG,2)+task_num+VM_nums(end));
%Initializing particles
if isequal(flag,2)
    rate=0;
    x(1,1:size(DAG,2))=Server_choice;
    for i=1:size(DAG,2)
        if isequal(i,1)
            if isequal(Server_choice(i),1)
                x(1,size(DAG,2)+1:size(DAG,2)+DAG_Task_Num(i))=(DAG_task{i}-1)/VM_nums(1);
            else
                x(1,size(DAG,2)+1:size(DAG,2)+DAG_Task_Num(i))=(DAG_task{i}-1)/(VM_nums(Server_choice(i))-VM_nums(Server_choice(i)-1));
            end
        else
            if isequal(Server_choice(i),1)
                x(1,size(DAG,2)+DAG_Task_Num(i-1)+1:size(DAG,2)+DAG_Task_Num(i))=(DAG_task{i}-1)/VM_nums(1);
            else
                x(1,size(DAG,2)+DAG_Task_Num(i-1)+1:size(DAG,2)+DAG_Task_Num(i))=(DAG_task{i}-1)/(VM_nums(Server_choice(i))-VM_nums(Server_choice(i)-1));
            end
        end
    end
    for i=1:ServerNum
        if isequal(i,1)
            if isequal(size(Server_vcpu{i},2),0)
                while 1
                    x(1,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(i))=randi(floor(2*C_s/VM_nums(i)), 1, VM_nums(i));
                    if sum(x(1,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(i)))<=C_s && min(x(1,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(i)))>0
                        break
                    end
                end
            else
                x(1,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(i))=Server_vcpu{i};
            end
        else
            if isequal(size(Server_vcpu{i},2),0)
                while 1
                    x(i,size(DAG,2)+task_num+VM_nums(i-1)+1:size(DAG,2)+task_num+VM_nums(i))=randi(floor(2*(C_s/(VM_nums(i)-VM_nums(i-1)))), 1, VM_nums(i)-VM_nums(i-1));
                    if sum(x(i,size(DAG,2)+task_num+VM_nums(i-1)+1:size(DAG,2)+task_num+VM_nums(i)))<=C_s && min(x(i,size(DAG,2)+task_num+VM_nums(i-1)+1:size(DAG,2)+task_num+VM_nums(i)))>0
                        break
                    end
                end
            else
                x(1,size(DAG,2)+task_num+VM_nums(i-1)+1:size(DAG,2)+task_num+VM_nums(i))=Server_vcpu{i};
            end
        end
    end
end

if ~isempty(DAG_Task_Num)
    for i=flag:n
        x(i,1:size(DAG,2))=randi(ServerNum,1,size(DAG,2));
        for j=1:size(DAG,2)%Randomly place tasks from the DAG in the virtual machine
            if isequal(j,1)
                x(i,size(DAG,2)+1:size(DAG,2)+DAG_Task_Num(j))=(randi(100,1,DAG_Task_Num(j))-1)./100; 
            else
                x(i,size(DAG,2)+DAG_Task_Num(j-1)+1:size(DAG,2)+DAG_Task_Num(j))=(randi(100,1,DAG_Task_Num(j)-DAG_Task_Num(j-1))-1)./100;
            
            end
        end
         for j=1:ServerNum
            while 1
                if isequal(j,1)%Random allocation of VM compute resources per server
                    if isequal(C_s,VM_nums(j))
                        x(i,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(j))=ones(1,VM_nums(j));
                    else
                        x(i,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(j))=randi(floor(2*C_s/VM_nums(j)), 1, VM_nums(j));
                    end
                else
                    if isequal(C_s,VM_nums(j)-VM_nums(j-1))
                        x(i,size(DAG,2)+task_num+VM_nums(j-1)+1:size(DAG,2)+task_num+VM_nums(j))=ones(1,VM_nums(j)-VM_nums(j-1));
                    else
                        x(i,size(DAG,2)+task_num+VM_nums(j-1)+1:size(DAG,2)+task_num+VM_nums(j))=randi(floor(2*(C_s/(VM_nums(j)-VM_nums(j-1)))), 1, VM_nums(j)-VM_nums(j-1));
                    end
                end
                if isequal(j,1) 
                    if sum(x(i,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(j)))<=C_s && min(x(i,size(DAG,2)+task_num+1:size(DAG,2)+task_num+VM_nums(j)))>0
                        break
                    end
                else
                    if sum(x(i,size(DAG,2)+task_num+VM_nums(j-1)+1:size(DAG,2)+task_num+VM_nums(j)))<=C_s && min(x(i,size(DAG,2)+task_num+VM_nums(j-1)+1:size(DAG,2)+task_num+VM_nums(j)))>0
                        break
                    end
                end
            end
        end
    end
    Pbest_x=x;                % Set the initial position to the position of the local optimal solution
    Pbest_y=zeros(1,n);       % The function value of each particle as its local optimal solution
    Prate=zeros(1,n);         % The function value of each particle as its local optimal solution
    Gbest_y=0;                % The initial value of the global optimal solution is set to inf
    Gbest_x = x(1,:);         % The initial global optimal position is set to the position of the first particle
    
    v = zeros(n,size(DAG,2)+task_num+VM_nums(end));
    v(:,1:size(DAG,2))=ones(n,size(DAG,2));
    v(:,size(DAG,2)+1:size(DAG,2)+task_num) = randi(100,n,task_num)/100;
    v(:,size(DAG,2)+task_num+1:end) = randi(5,n,VM_nums(end));
    alpha=zeros(n,ServerNum);
    vm_all_particles{n} = {};
    Gbest_y_old = 0;
    for i = 1:iter
        for j=1:n
            [target,virtualMachines,p_rate]=particle_update(x(j,:),C_s,VM_nums,ServerNum,DAG,DAG_Task_Num);%Update particles
            fin_target=sum(target)+p_rate;%The sum of the alpha values of all servers plus the number of successful DAG schedules
            vm_all_particles{j} = virtualMachines;
            if fin_target>Pbest_y(j)
                Pbest_y(j)=fin_target;        %Updating the individual optimal solution
                Pbest_x(j,:)=x(j,:);          %Updating the individual optimal position
                alpha(j,:)=target;
                Prate(j)=p_rate/size(DAG,2);
            end
        end
        if i==1
            Gbest_y_old=0;
        end
            % Update the global optimal position and adaptation values
        [Gbest_y,index] = max(Pbest_y);
        Gbest_x = Pbest_x(index,:);
        if Gbest_y>Gbest_y_old
            ServerResult = vm_all_particles{index};
            targetOutput=alpha(index,:);

            Gbest_y_old=Gbest_y;
            rate=Prate(index)/size(DAG,2);
        end
            
        for j = 1:n
            v(j,:)=w*v(j,:)+c1*rand()*(Pbest_x(j,:)-x(j,:))+c2*rand()*(Gbest_x-x(j,:));
            v(j,:) = roundn(v(j,:),-1);                                                             
            x(j,:)=x(j,:)+v(j,:);
            %Find negative numbers in particles and update
            a=find(x(j,size(DAG,2)+1:size(DAG,2)+task_num)<0 | x(j,size(DAG,2)+1:size(DAG,2)+task_num)==0 |(x(j,size(DAG,2)+1:size(DAG,2)+task_num)>1) | x(j,size(DAG,2)+1:size(DAG,2)+task_num)==1);
            if ~isempty(a)
                for k=1:size(a,2)
                    x(j,size(DAG,2)+a(k))=((randi([2,100])-1))/100;
                end
            end

            b=find(x(j,size(DAG,2)+task_num+1:end)<1 | x(j,size(DAG,2)+task_num+1:end)>C_s);
            if ~isempty(b)
                for k=1:size(b,2)
                    x(j,size(DAG,2)+task_num+b(k))=2.00;
                end
            end
            c=find(x(j,1:size(DAG,2))<1 | x(j,1:size(DAG,2))>ServerNum);
            if ~isempty(c)
                for k=1:size(c,2)
                    x(j,c(k))=1.00;
                end
            end
        end
        if isequal(i, iter) && isequal(Gbest_y_old, 0)
            return
        end
    end
end