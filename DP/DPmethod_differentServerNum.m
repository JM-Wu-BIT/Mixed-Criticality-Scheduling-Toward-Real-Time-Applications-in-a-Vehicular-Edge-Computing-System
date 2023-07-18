clc
clear
close all
DPR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    C_s = 50;%available computation resource
    DAGnum = 10;%Number of DAGs
    
    DPT=[];
    DPalpha=[];
    
    
    for DAG_id=1:DAGnum
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    
    for serverNum=1:10
        serverNum
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
        end
        tic
        [DPSR] = DP(serverNum,DAG,DAGnum,C_s);
        DPcomTime=toc 
        DPR(serverNum)=DPR(serverNum)+issuccessful(DPSR);
        DPT(serverNum)=DPcomTime;
        DPalpha{serverNum}=DPSR;
        save(['..\result\m=1-10\DPresult\Process result\' fn ' serverNum=' num2str(serverNum)  ' Csp=50 DAGnum=10.mat'],"DPSR","DPcomTime");
    end
    
    save(['..\result\m=1-10\DPresult\' fn 'result serverNum=1-10 Csp=50 DAGnum=10.mat'],"DPalpha","DPT");
    save(['..\result\m=1-10\DPresult\result' fn '.mat'],"DPalpha","DPT");
end
save('..\result\m=1-10\DPresult\Successtime.mat',"DPR");