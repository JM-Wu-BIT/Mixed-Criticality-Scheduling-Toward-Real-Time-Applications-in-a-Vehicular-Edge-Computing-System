function [ServesResult,old_Assign,executed_id_temp,DAG_id_Serves,et]=DP_Schedule_MultipleServers(ServerNum,C_s,DAG_load,DAG_priority,DAG_period_all, DAG_period,DAG_deadline,DAG_id,DAG_communicationCost,DAG_criticality_all, DAG_criticality,old_Assign,DAG_id_Serves,et)

old_assign=old_Assign;


%Distribution and execution time of placing DAGs within each server
[Assign,value_task]=DP_Mix_CriticalityFuc(ServerNum,old_Assign,C_s,DAG_load,DAG_priority,DAG_period,DAG_deadline,DAG_id,DAG_communicationCost,DAG_id_Serves, DAG_criticality);

total_value_DAG=[];
for i=1:ServerNum%Get the execution time of a task within each server
    total_value_DAG=[total_value_DAG,value_task{i}{end}];
end
[value_DAG,index]=min(total_value_DAG);%Place the DAG to execute on the server with the shortest execution time
et(DAG_id)=value_DAG;
if value_DAG==inf
    for i=1:ServerNum
        if isempty(old_assign{i})
            ServesResult{i}=old_assign{i};
        else
            ServesResult{i}=old_assign{i}{end}{end};
        end
    end
    executed_id_temp=0;
    return
end

for i=1:ServerNum
    if i==index%Update the servers that are put into the DAG
        ServesResult{i}=Assign{i}{end}{end};
        old_Assign{i}=Assign{i};
        DAG_id_Serves{index}=[DAG_id_Serves{i},DAG_id];
    else%Remaining servers remain intact
        old_Assign{i}=old_assign{i};
        if isempty(old_assign{i})
            ServesResult{i}=old_assign{i};
        else
            ServesResult{i}=old_assign{i}{end}{end};
        end
    end
end
executed_id_temp=1;
