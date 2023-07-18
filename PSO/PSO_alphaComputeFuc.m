function [alpha,finish_DAG_num] = PSO_alphaComputeFuc(DAG, DAGArray,vCPUwrtVM,VMIndex,DAG_Task_Num)

DAGnum = size(DAGArray, 2);
makespanInd = ones(DAGnum, 1);
critArray = [];
periodArray = [];
execArray = [];
finish_DAG_num=0;
for i = 1:size(DAGArray, 2)
    DAG_index=DAGArray(i);
    DAGinfo = DAG{DAG_index};
    DAG_load = DAGinfo{1};%computational load
    DAG_comCost = DAGinfo{2};%communications cost
    preTasks = DAGinfo{3};%predecessor task
    period=DAGinfo{4};
    if eq(DAG_index,1)
        DAG_vm=VMIndex(1:DAG_Task_Num(1));
    else
        DAG_vm=VMIndex(DAG_Task_Num(DAG_index-1)+1:DAG_Task_Num(DAG_index));
    end
    [makespan, vmCELLs] = PSO_heftFuc(DAG_index,period,DAG_load, DAG_comCost, preTasks, vCPUwrtVM,DAG_vm);
                            
    %vmCELLs is a task that the server needs to perform
    %makespan is the time when the DAG task is completed
    makespan = round(makespan);
    critArray = [critArray, DAGinfo{5}];%DAG Criticality
    periodArray = [periodArray, DAGinfo{4}];%DAG period
    execArray = [execArray, makespan];%%DAG execution time
    
end
%Algorithm 1, maximizing alpha is used to satisfy (5)
alpha = alphaCoreFuc(critArray, periodArray, execArray);
