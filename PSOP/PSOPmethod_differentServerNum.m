clc
clear
close all
PSOPR=zeros(1,10);
for i=1:50
    
    fn=['DAG_data' num2str(i)];
    load(['..\data\' fn '.mat']);
    C_s = 50;%available computation resource
    DAGnum = 10;%Number of DAGs
    

    PSOPT=[];
    PSOPalpha=[];
    
    for DAG_id=1:DAGnum
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    
    for serverNum=1:10
        serverNum
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
        end
    
        filename=['..\result\m=1-10\MCSresult\Process result\' fn ' serverNum=' num2str(serverNum) '.mat'];
        load(filename);
        
        
        tic
        [Gbest_y,PSO_Prate,PSOPSR] = PSO(serverNum,C_s,DAG,Server_vcpu,Server_choice,DAG_task);
        PSO_PluscomTime=toc
        PSOPR(serverNum)=PSOPR(serverNum)+issuccessful(PSOPSR);
        PSOPT(serverNum)=PSO_PluscomTime;
        PSOPalpha{serverNum}=PSOPSR;
        save(['..\result\m=1-10\PSOPresult\Process result\' fn ' serverNum=' num2str(serverNum)  ' Csp=50 DAGnum=10.mat'],"PSOPSR","PSO_PluscomTime");
    end
    
    save(['..\result\m=1-10\PSOPresult\' fn 'result serverNum=1-10 Csp=50 DAGnum=10.mat'],"PSOPalpha","PSOPT");
    save(['..\result\PSOPresult\reslut' fn '.mat'],"PSOPalpha","PSOPT");

end
save('..\result\m=1-10\PSOPresult\Successtime.mat',"PSOPR");
