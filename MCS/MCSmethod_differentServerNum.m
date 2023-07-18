clc
clear
close all

MCSR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    C_s = 50;%available computation resource
    DAGnum = 10;%%Number of DAGs
    
    
    MCST=[];
    MCSalpha=[];
    
    for DAG_id=1:DAGnum
        %DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    DAGnum=10;
    for serverNum=1:10
        serverNum
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
        end
    
        tic
        [SR,Server_vcpu,Server_choice,DAG_task]= MCS(serverNum,DAGnum,DAG,C_s);
        MCScomTime = toc
        MCSR(serverNum)=MCSR(serverNum)+issuccessful(SR);
        MCST(serverNum)=MCScomTime;
        MCSalpha{serverNum}=SR;
        filename=['..\result\m=1-10\MCSresult\Process result\' fn ' serverNum=' num2str(serverNum) '.mat'];
        save(filename,"Server_choice","Server_vcpu","DAG_task");
        save(['..\result\m=1-10\MCSresult\Process result\' fn ' serverNum=' num2str(serverNum) ' Csp=50 DAGnum=10.mat'],"SR","MCScomTime");
    end
    
    save(['..\result\m=1-10\MCSresult\' fn 'result serverNum=1-10 Csp=50 DAGnum=10.mat'],"MCSalpha","MCST");
    save(['..\result\m=1-10\MCSresult\result' fn '.mat'],"MCSalpha","MCST");
end
save('..\result\m=1-10\MCSresult\Successtime.mat',"MCSR");
