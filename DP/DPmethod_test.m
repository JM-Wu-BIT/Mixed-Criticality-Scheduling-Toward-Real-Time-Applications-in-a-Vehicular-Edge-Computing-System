clc
clear
close all
  
serverNum = 5;%Number of servers
DAGnum = 10;%Number of DAGs
C_s=50;%available computation resource
DAG = DAG_gen(DAGnum,serverNum,C_s);
                    
tic
[DPSR] = DP(serverNum,DAG,DAGnum,C_s);
DPcomTime=toc 

