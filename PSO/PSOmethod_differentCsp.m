clc
clear
close all
PSOR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    serverNum = 5;%Number of servers
    DAGnum = 10;%Number of DAGs
    
    
    PSOT=[];
    PSOalpha=[];
    
    for DAG_id=1:DAGnum
        DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    
    for C_s=10:10:100
        C_s
        tic
        [ServerResult,PSOrate,PSOSR]=PSO(serverNum,C_s,DAG);
        PSOcomTime = toc
        PSOR(C_s/10)=PSOR(C_s/10)+issuccessful(PSOSR);
        PSOT(C_s/10)=PSOcomTime;
        PSOalpha(C_s/10,:)=PSOSR;
        save(['..\result\Csp=10-100\PSOresult\Process result\' fn ' Csp=' num2str(C_s) ' serverNum=5 DAGnum=10.mat'],"PSOSR","PSOcomTime");
    end
    
    save(['..\result\Csp=10-100\PSOresult\' fn 'result Csp=10-100 serverNum=5 DAGnum=10.mat'],"PSOalpha","PSOT");
    save(['..\result\PSOresult\result' fn '.mat'],"PSOalpha","PSOT");


end
save('..\result\Csp=10-100\PSOresult\Successtime',"PSOR");
