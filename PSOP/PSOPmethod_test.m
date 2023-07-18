clc
clear
close all

serverNum = 5;%Number of servers
DAGnum = 10;%Number of DAGs
C_s=50;%available computation resource
% DAG = DAG_gen(DAGnum,serverNum,C_s);%Generate DAG data
filename='..\MCS\Process result\result.mat';%Loading MCS data and results
load(filename);
        
tic
[Gbest_y,PSO_Prate,PSOPSR] = PSO(serverNum,C_s,DAG,Server_vcpu,Server_choice,DAG_task);
PSO_PluscomTime=toc
