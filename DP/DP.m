function [alphaArray]= DP(serverNum,DAG,DAGnum,C_s_1)

DAG_executeTime=[];
flag=1;


DAG_period=zeros(1,DAGnum);
DAG_criticality=zeros(1,DAGnum);
C_s=C_s_1*ones(1,serverNum);
for DAG_id=1:DAGnum
    DAG_criticality(DAG_id)=DAG{DAG_id}{5};
    DAG_load{DAG_id}=DAG{DAG_id}{1};
    DAG_priority{DAG_id}=1:size(DAG_load{DAG_id},1);
    DAG_period(DAG_id)=DAG{DAG_id}{4};
    DAG_deadline(DAG_id)=DAG{DAG_id}{4};
    DAG_communicationCost{DAG_id}=DAG{DAG_id}{2};
    DAG_preTasks{DAG_id}=DAG{DAG_id}{3};
end
DAG_id=1:10;
[temp,index]=sort(DAG_criticality,'descend');%Descending order according to key level
et=zeros(1,DAGnum);
%ssign DAGs to the server and calculate the execution time of the DAGs
for i=1:DAGnum
    if i==1
        for s=1:serverNum
            Assign{s}=[];
            DAG_id_Servers{s}=[];
        end
        old_Assign=Assign;
    end                                                                                                 
    [ServersResult,old_Assign,executed_id_temp,DAG_id_Servers,et]=DP_Schedule_MultipleServers(serverNum,C_s,DAG_load{index(i)},DAG_priority{index(i)},DAG_period, DAG_period(index(i)),DAG_deadline(index(i)),DAG_id(index(i)),DAG_communicationCost,DAG_criticality, DAG_criticality(index(i)),old_Assign,DAG_id_Servers,et);
    if executed_id_temp
        executed_id= flag&executed_id_temp;
    else
        executed_id= flag&executed_id_temp;
        break
    end
end
alphaArray=zeros(1,serverNum);
for s=1:serverNum%Calculate the alpha value for each server based on the allocation results
    DAG_in_server=DAG_id_Servers{s};
    if isempty(DAG_in_server)
        alpha=0;
    else
        periodArray=DAG_period(DAG_in_server);
        critArray=DAG_criticality(DAG_in_server);
        execArray=et(DAG_in_server);
        [periodArray,index]=sort(periodArray, 'ascend');
        critArray=critArray(index);
        execArray=execArray(index);
        alpha = alphaCoreFuc(critArray, periodArray, execArray);
    end
    alphaArray(s)=alpha;
end

end

