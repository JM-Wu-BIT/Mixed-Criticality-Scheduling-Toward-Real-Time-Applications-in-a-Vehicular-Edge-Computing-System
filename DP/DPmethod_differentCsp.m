clc
clear
close all
DPR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    serverNum = 5;%Number of servers
    DAGnum = 10;%Number of DAGs
    
    DPT=[];
    DPalpha=[];
    
    for DAG_id=1:DAGnum
        DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    DAGnum=10;
    %different %available computation resource
    for C_s=10:10:100
        C_s
        
        tic
        [DPSR] = DP(serverNum,DAG,DAGnum,C_s);
        DPcomTime=toc 
        DPR(C_s/10)=DPR(C_s/10)+issuccessful(DPSR);
        DPT(C_s/10)=DPcomTime;
        DPalpha(C_s/10,:)=DPSR;
        save(['..\result\Csp=10-100\DPresult\Process result\' fn ' Csp=' num2str(C_s)  ' serverNum=5 DAGnum=10.mat'],"DPSR","DPcomTime");
    end
    
    save(['..\result\Csp=10-100\DPresult\' fn 'result Csp=10-100 serverNum=5 DAGnum=10.mat'],"DPalpha","DPT");
    save(['..\result\Csp=10-100\DPresult\result' fn '.mat'],"DPalpha","DPT");

end
save('..\result\Csp=10-100\DPresult\Successtime.mat',"DPR");