function [alpha,result] = alphaComputeFuc(DAG, vCPUwrtVM,DAG_array)

DAGnum = size(DAG, 2);
makespanInd = ones(DAGnum, 1);
critArray = [];
periodArray = [];
execArray = [];
result{size(DAG, 2)}{4}=[];
for i = 1:size(DAG, 2)
    DAGinfo = DAG{i};
    DAG_load = DAGinfo{1};%computational load
    DAG_comCost = DAGinfo{2};%communications cost
    preTasks = DAGinfo{3};%predecessor task
    [makespan, vmCELLs,task_vm] = heftFuc(DAG_load, DAG_comCost, preTasks, vCPUwrtVM);
    %vmCELLs is a task that the server needs to perform
    %makespan is the time when the DAG task is completed
    makespan = round(makespan);
    result{i}{1}=DAG_array(i);
    result{i}{2}=vmCELLs;
    result{i}{3}=task_vm;
    result{i}{4}=makespan;

    critArray = [critArray, DAGinfo{5}];%DAG Criticality
    periodArray = [periodArray, DAGinfo{4}];%DAG period
    execArray = [execArray, makespan];%%DAG execution time
end
%Algorithm 1, maximizing alpha is used to satisfy (5)
alpha = alphaCoreFuc(critArray, periodArray, execArray);