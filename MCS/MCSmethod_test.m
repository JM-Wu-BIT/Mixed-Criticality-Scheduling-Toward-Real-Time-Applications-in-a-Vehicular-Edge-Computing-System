clc
clear
close all
    
serverNum = 5;%Number of servers
DAGnum = 10;%Number of DAGs
C_s=50;%available computation resource
DAG = DAG_gen(DAGnum,serverNum,C_s);%Generate DAG data
tic
[SR,Server_vcpu,Server_choice,DAG_task]= MCS(serverNum,DAGnum,DAG,C_s);
MCScomTime = toc

filename=['Process result\result.mat'];%Record the experimental results of the MCS algorithm for PSO+
save(filename,"DAG","Server_choice","Server_vcpu","DAG_task");
