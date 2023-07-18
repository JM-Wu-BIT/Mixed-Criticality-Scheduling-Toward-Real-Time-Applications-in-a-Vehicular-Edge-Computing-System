clc
clear
close all
PSOPR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    serverNum = 5;%Number of servers
    DAGnum = 10;%Number of DAGs
    
    
    PSOPT=[];
    PSOPalpha=[];
    
    for DAG_id=1:DAGnum
        DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    
    for C_s=10:10:100
        C_s
        filename=['..\result\Csp=10-100\MCSresult\Process result\' fn 'Csp=' num2str(C_s) '.mat'];
        load(filename);
        
        tic
        [Gbest_y,PSO_Prate,PSOPSR] = PSO(serverNum,C_s,DAG,Server_vcpu,Server_choice,DAG_task);
        PSO_PluscomTime=toc
        PSOPR(C_s/10)=PSOPR(C_s/10)+issuccessful(PSOPSR);
        PSOPT(C_s/10)=PSO_PluscomTime;
        PSOPalpha(C_s/10,:)=PSOPSR;
        save(['..\result\Csp=10-100\PSOPresult\Process result\' fn ' Csp=' num2str(C_s) ' serverNum=5 DAGnum=10.mat'],"PSOPSR","PSO_PluscomTime");
    end
    
    save(['..\result\Csp=10-100\PSOPresult\' fn 'result Csp=10-100 serverNum=5 DAGnum=10.mat'],"PSOPalpha","PSOPT");
    save(['..\result\Csp=10-100\PSOPresult\result' fn '.mat'],"PSOPalpha","PSOPT");
end

save('..\result\Csp=10-100\PSOPresult\Successtime',"PSOPR");