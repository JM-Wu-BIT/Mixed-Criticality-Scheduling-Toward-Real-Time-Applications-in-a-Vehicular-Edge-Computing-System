clc
clear
close all

serverNum = 5;%Number of servers
DAGnum = 10;%Number of DAGs
C_s=100;%available computation resource
DAG = DAG_gen(DAGnum,serverNum,C_s);%Generate DAG data
    
tic
[ServerResult,PSOrate,PSOSR]=PSO(serverNum,C_s,DAG);
PSOcomTime = toc

