function Server_alpha = OneVM(serverNum,DAG,C_s)

DAGnum=size(DAG,2);
serveravailtime=zeros(1,serverNum);
DAG_sumtime=[];
flag=0;
Serverchoice=zeros(1,DAGnum);
serveralpha=zeros(1,serverNum);
serverArray=[];
alphaArray=[];
column=1;
for DAG_id = 1:DAGnum
    executeTime=sum(DAG{DAG_id}{1}(:,C_s));
    serverArray(DAG_id)=DAG{DAG_id}{6};
    DAG_sumtime=[DAG_sumtime,executeTime];
end
%Calculate the alpha value of the server under the current allocation scheme
for s=1:serverNum
    periodArray=[];
    critArray=[];
    DAG_in_s=find(serverArray==s);
    if isequal(size(DAG_in_s,2),0)
        alpha=0;
    else
        execArray = DAG_sumtime(DAG_in_s);
        for i=1:size(DAG_in_s,2)
            periodArray = [periodArray, DAG{DAG_in_s(i)}{4}];
            critArray = [critArray, DAG{DAG_in_s(i)}{5}];
        end
        [periodArray, index] = sort(periodArray, 'ascend');
        critArray=critArray(index);
        execArray=execArray(index);
        alpha = alphaCoreFuc(critArray, periodArray, execArray);
    end
    serveralpha(s)=alpha;
end
alphaArray(column,:)=serveralpha;
serverArray(column,:)=serverArray;
column=column+1;
havebeenDAG=zeros(1,DAGnum);
%If the number of DAGs is less than the number of servers, ensure that there is only one DAG in each server
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
        critArray=[];
        periodArray=[];
        execArray=[];
        if isempty(ready_server)%If the server containing multiple DAGs does not exist, the DAG allocation ends
            break;
        else%Assigning DAGs from a server containing multiple DAGs to other servers
            choice_server_out=ready_server(randi(size(ready_server,2)));%Randomly selecting one of the servers containing multiple DAGs
            server_DAGnum(choice_server_out)=server_DAGnum(choice_server_out)-1;%The number of server DAGs removed from the DAG is subtracted by one
            server_in=find(server_DAGnum==0);%Find free servers and randomly select one
            choice_server_in=server_in(randi(size(server_in,2)));
            server_DAGnum(choice_server_in)=server_DAGnum(choice_server_in)+1;%The number of server DAGs moved into the DAG plus one
            ready_DAG=find(serverArray(column-1,:)==choice_server_out);%Randomly select a DAG among the servers that moved out of the DAG
            choice_DAG=ready_DAG(randi(size(ready_DAG,2)));
            DAG{choice_DAG}{6}=choice_server_in;%Place it in the server moved into the DAG
            serverArray(column,choice_DAG)=choice_server_in;%Calculate the alpha value of the move to the server
            critArray=[DAG{choice_DAG}{5}];
            periodArray=[DAG{choice_DAG}{4}];
            execArray=[DAG_sumtime(choice_DAG)];
            alpha = alphaCoreFuc(critArray, periodArray, execArray);
            critArray=[];
            periodArray=[];
            execArray=[];
            alphaArray(column,choice_server_in)=alpha;
            ready_DAG=find(serverArray(column,:)==choice_server_out);%Find the remaining DAGs in the move-out server
            execArray = DAG_sumtime(ready_DAG);%Calculate the alpha value for moving out of the server
            for i=1:size(ready_DAG,2)
                periodArray = [periodArray, DAG{ready_DAG(i)}{4}];
                critArray = [critArray, DAG{ready_DAG(i)}{5}];
            end
            [periodArray, index] = sort(periodArray, 'ascend');
            critArray=critArray(index);
            execArray=execArray(index);
            alpha = alphaCoreFuc(critArray, periodArray, execArray);
            critArray=[];
            periodArray=[];
            execArray=[];
            alphaArray(column,choice_server_out)=alpha;
            column=column+1;
        end
    end
else%When the number of DAGs exceeds the number of servers
    while 1
        alphaArray(column,:)=alphaArray(column-1,:);
        serverArray(column,:)=serverArray(column-1,:);        
        if isequal(sum(havebeenDAG),DAGnum)%Ensure that every DAG has been selected
            havebeenDAG=zeros(1,DAGnum);
            flag=1;
        end
        readyDAGArray=find(havebeenDAG==0);%Randomly select one of the unselected DAGs 
        readyDAG=readyDAGArray(randi(size(readyDAGArray,2)));
        havebeenDAG(readyDAG)=1;
        init_choice=DAG{readyDAG}{6};%Record its currently selected server
        havebeenserver=zeros(1,serverNum);
        alpha_max=alphaArray(column,init_choice);%Record the alpha value of the server in the current scenario
        Bestserver=init_choice;
        for servertime=1:serverNum
            readyserverArray=find(havebeenserver==0);%Randomly select a server, ensuring that each server is selected only once
            readyserver=readyserverArray(randi(size(readyserverArray,2)));
            havebeenserver(readyserver)=1;
            serverArray(column,readyDAG)=readyserver;%Recording server selection order
            DAG_in_s=find(serverArray(column,:)==readyserver);
            critArray=[];
            periodArray=[];
            execArray=[];
            execArray = DAG_sumtime(DAG_in_s);
            for i=1:size(DAG_in_s,2)
                periodArray = [periodArray, DAG{DAG_in_s(i)}{4}];
                critArray = [critArray, DAG{DAG_in_s(i)}{5}];
            end
            [periodArray, index] = sort(periodArray, 'ascend');
            critArray=critArray(index);
            execArray=execArray(index);
            alpha = alphaCoreFuc(critArray, periodArray, execArray);%Record the new alpha value
            critArray=[];
            periodArray=[];
            execArray=[];
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
    critArray=[];
    periodArray=[];
    execArray=[];
    DAG_in_server=find(Server_choice==s);
    if isempty(DAG_in_server)
        alpha=0;
    else
        execArray = DAG_sumtime(DAG_in_server);
        for i=1:size(DAG_in_server,2)
            periodArray = [periodArray, DAG{DAG_in_server(i)}{4}];
            critArray = [critArray, DAG{DAG_in_server(i)}{5}];
        end
        [periodArray, index] = sort(periodArray, 'ascend');
        critArray=critArray(index);
        execArray=execArray(index);
        alpha = alphaCoreFuc(critArray, periodArray, execArray);
        critArray=[];
        periodArray=[];
        execArray=[];
    end
    Server_alpha=[Server_alpha,alpha];
end

end

