function [Server_alpha,Server_vcpu,Server_choice,DAG_task] = MCS(serverNum,DAGnum,DAG,C_s)

counter=0;
iterMax=10;
alphaArray = zeros(iterMax,serverNum);
serverArray = [];
column = 1;

Server_alpha=zeros(1,serverNum);
Server_vcpu{serverNum}=[];


finish_time=zeros(1,DAGnum);
for DAG_id =1:DAGnum
    %Maximum alpha value under optimal VM compute resource allocation is obtained according to 1000 iterations of the evolutionary algorithm
    [alpha_DAG_id,vCPUwrtVM,result] = alphaComputeWRTserver(DAG, DAG_id, C_s); 
    for j=1:size(result,2)
        SR{result{j}{1}}=result{j}{2};
        DAG_task{result{j}{1}}=result{j}{3};
    end
    Server_alpha(DAG{DAG_id}{6})=alpha_DAG_id;
    Server_vcpu{DAG{DAG_id}{6}}=vCPUwrtVM;
    serverArray(column, DAG_id) = DAG{DAG_id}{6};%Record the server on which the DAG is executed
end
alphaArray(column,:)=Server_alpha;
column=column+1;
havebeenDAG=zeros(1,DAGnum);
flag=0;
% If the number of DAGs is less than the number of servers, ensure that there is only one DAG in each server.
if DAGnum<=serverNum
    server_DAGnum=zeros(1,serverNum);
    for s=1:serverNum%Find the DAG for each server
        ready_DAG=find(serverArray(column-1,:)==s);
        server_DAGnum(s)=size(ready_DAG,2);
    end
    while 1
        ready_server=find(server_DAGnum>1);%Find servers containing multiple DAGs
        alphaArray(column,:)=alphaArray(column-1,:);
        serverArray(column,:)=serverArray(column-1,:);
        if isempty(ready_server)%If the server containing multiple DAGs does not exist, the current loop is skipped and the DAG allocation ends
            break;
        else% Distribute DAGs from servers containing multiple DAGs to other servers
            choice_server_out=ready_server(randi(size(ready_server,2)));%Randomly selecting one of the servers containing multiple DAGs
            server_DAGnum(choice_server_out)=server_DAGnum(choice_server_out)-1;%The number of server DAGs removed from the DAG is subtracted by one
            server_in=find(server_DAGnum==0);%Find free servers and randomly select one
            choice_server_in=server_in(randi(size(server_in,2)));
            server_DAGnum(choice_server_in)=server_DAGnum(choice_server_in)+1;%The number of server DAGs moved into the DAG plus one
            ready_DAG=find(serverArray(column-1,:)==choice_server_out);%Randomly select a DAG among the servers that moved out of the DAG
            choice_DAG=ready_DAG(randi(size(ready_DAG,2)));
            DAG{choice_DAG}{6}=choice_server_in;%Place it in the server moved into the DAG
            [alpha_DAG_id, vCPUwrtVM,result]= alphaComputeWRTserver(DAG, choice_DAG, C_s);%Calculate the alpha value of the server moved into the DAG and record the server computing resource allocation
            for j=1:size(result,2)
                SR{result{j}{1}}=result{j}{2};
                DAG_task{result{j}{1}}=result{j}{3};
                finish_time(result{j}{1})=result{j}{4};
            end
            Server_vcpu{choice_server_in}=vCPUwrtVM;
            alphaArray(column,choice_server_in)=alpha_DAG_id;
            DAGarray=find(ready_DAG~=choice_DAG);%Find the other DAGs in the move-out server and calculate the alpha value for the move-out server
            DAG_update=ready_DAG(DAGarray(size(DAGarray,2)));
            [alpha_DAG_id, vCPUwrtVM,result]= alphaComputeWRTserver(DAG, DAG_update, C_s);
            for j=1:size(result,2)
                SR{result{j}{1}}=result{j}{2};
                DAG_task{result{j}{1}}=result{j}{3};
                finish_time(result{j}{1})=result{j}{4};
            end
            Server_vcpu{choice_server_out}=vCPUwrtVM;
            alphaArray(column,choice_server_out)=alpha_DAG_id;
            serverArray(column,choice_DAG)=choice_server_in;
            column=column+1;
        end
    end
else
    while 1
        serverArray(column, :)=serverArray(column-1, :);
        alphaArray(column,:)=alphaArray(column-1,:);
        if isequal(sum(havebeenDAG),DAGnum) %Ensure that every DAG has been selected
            havebeenDAG=zeros(1,DAGnum);
            flag=1;
        end
        readyDAGArray=find(havebeenDAG==0);%Randomly select one of the unselected DAGs 
        readyDAG=readyDAGArray(randi(size(readyDAGArray,2)));
        havebeenDAG(readyDAG)=1;
        init_choice=DAG{readyDAG}{6};%Record its currently selected server
        havebeenserver=zeros(1,serverNum);
        server_order=zeros(1,serverNum);
        alpha_max=alphaComputeWRTserver(DAG,readyDAG,C_s);%Record the alpha value of the server in the current scenario
        Bestserver=init_choice;
        for servertime=1:serverNum
            readyserverArray=find(havebeenserver==0);%Randomly select a server, ensuring that each server is selected only once
            readyserver=readyserverArray(randi(size(readyserverArray,2)));
            havebeenserver(readyserver)=1;
            server_order(servertime)=readyserver;%Recording server selection order
            DAG{readyDAG}{6}=readyserver;
            alpha=alphaComputeWRTserver(DAG,readyDAG,C_s);%Record the new alpha value
            if alpha>alpha_max%If the alpha value of the server for the new scheme is greater than the previous scheme, update the allocation policy
                alpha_max=alpha;
                Bestserver=readyserver;
            end
        end
        if ~isequal(Bestserver,0)
            DAG{readyDAG}{6}=Bestserver;
            serverArray(column,readyDAG)=Bestserver;
            alphaArray(column,Bestserver)=alpha_max;
        end
        %If the DAG allocation scheme remains unchanged, the counter is increased by one
        if isequal(flag,1)&&isequal(serverArray(column,:),serverArray(column-1,:))
            counter=counter+1;
        else
            counter=0;
        end
        column=column+1;
        %The DAG allocation scheme is considered to reach a Nash equilibrium if it remains unchanged for many times
        if isequal(counter,5)
            break;
        end
        
    end
end
Server_choice=serverArray(column-1,:);
%Calculate the alpha value for each server in the Nash equilibrium state
Server_alpha=[];
for s=1:serverNum
    DAG_name=[];
    for i = 1:size(DAG, 2)
        if isequal(DAG{i}{6}, s)
            DAG_name=[DAG_name,i];
            DAG_in=i;
        end
    end
    if ~isempty(DAG_name)
        DAG_in=DAG_name(1);
        [alphaTemp,vCPUwrtVM,result] = alphaComputeWRTserver(DAG,DAG_in , C_s);
        for j=1:size(result,2)
            SR{result{j}{1}}=result{j}{2};
            DAG_task{result{j}{1}}=result{j}{3};
            if result{j}{4}<=DAG{result{j}{1}}{4}
                flag=flag+1;
            end
        end
 
    else
        %If the current server is idle, compute resources are distributed evenly
        alphaTemp=0;
        vCPUperVM = floor(C_s/(floor(C_s/3)+1));
        vCPUwrtVM = vCPUperVM*ones(1, floor(C_s/3)+1);
        vCPUwrtVM(end) = C_s - sum(vCPUwrtVM(1:end-1));

    end
    Server_alpha=[Server_alpha,alphaTemp];
    Server_vcpu{s}=vCPUwrtVM;
end


end

