clc
clear
close all
PSOR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    C_s = 50;%available computation resource
    DAGnum = 10;%Number of DAGs
    
    
    PSOT=[];
    PSOalpha=[];
    
    
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
        [ServerResult,PSOrate,PSOSR]=PSO(serverNum,C_s,DAG);
        PSOcomTime = toc
        PSOR(serverNum)=PSOR(serverNum)+issuccessful(PSOSR);
        PSOT(serverNum)=PSOcomTime;
        PSOalpha{serverNum}=PSOSR;
        
        save(['..\result\m=1-10\PSOresult\Process result\' fn ' serverNum=' num2str(serverNum)  ' Csp=50 DAGnum=10.mat'],"PSOSR","PSOcomTime");
    end
    
    
    save(['..\result\m=1-10\PSOresult\' fn 'result serverNum=1-10 Csp=50 DAGnum=10.mat'],"PSOalpha","PSOT");
    save(['..\result\PSOresult\result' fn '.mat'],"PSOalpha","PSOT");
end
save('..\result\m=1-10\PSOresult\Successtime.mat',"PSOR");

