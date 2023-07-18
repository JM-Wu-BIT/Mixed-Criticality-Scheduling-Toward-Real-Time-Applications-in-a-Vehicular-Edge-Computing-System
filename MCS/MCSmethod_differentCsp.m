clc
clear
close all

MCSR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    serverNum = 5;%Number of servers
    DAGnum=10;%Number of DAGs

    MCST=[];
    MCSalpha=[];
    
    for DAG_id=1:DAGnum
        DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    %different c
    for C_s=10:10:100
        C_s
        
        tic
        [SR,Server_vcpu,Server_choice,DAG_task]= MCS(serverNum,DAGnum,DAG,C_s);
        MCScomTime = toc
        MCSR(C_s/10)=MCSR(C_s/10)+issuccessful(SR);
        MCST(C_s/10)=MCScomTime;
        MCSalpha(C_s/10,:)=SR;
        filename=['..\result\Csp=10-100\MCSresult\Process result\' fn 'Csp=' num2str(C_s) '.mat'];
        save(filename,"Server_choice","Server_vcpu","DAG_task");
        save(['..\result\Csp=10-100\MCSresult\Process result\' fn ' Csp=' num2str(C_s) ' serverNum=5 DAGnum=10.mat'],"SR","MCScomTime");
    end
    
    save(['..\result\Csp=10-100\MCSresult\' fn 'result Csp=10-100 serverNum=5 DAGnum=10.mat'],"MCSalpha","MCST");
    save(['..\result\Csp=10-100\MCSresult\result' fn '.mat'],"MCSalpha","MCST");
end
save('..\result\Csp=10-100\MCSresult\Successtime.mat',"MCSR");