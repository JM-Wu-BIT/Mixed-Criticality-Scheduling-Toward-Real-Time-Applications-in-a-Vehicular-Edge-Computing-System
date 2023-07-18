clc
clear
close all
PSOPR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    serverNum = 5;%Number of servers
    C_s = 50; %available computation resource
    
    PSOPT=[];
    PSOPalpha=[];
    
    for DAGnum=1:10
        DAGnum
        DAGnew=[];
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
            DAGnew{DAG_id}=DAG{DAG_id};
        end
    
        filename=['..\result\n=1-10\MCSresult\Process result\' fn ' DAGnum=' num2str(DAGnum) '.mat'];
        load(filename);
    
        tic
        [Gbest_y,PSO_Prate,PSOPSR] = PSO(serverNum,C_s,DAGnew,Server_vcpu,Server_choice,DAG_task);
        PSO_PluscomTime=toc
        PSOPR(DAGnum)=PSOPR(DAGnum)+issuccessful(PSOPSR);
        PSOPT(DAGnum)=PSO_PluscomTime;
        PSOPalpha(DAGnum,:)=PSOPSR;
        save(['..\result\n=1-10\PSOPresult\Process result\' fn ' DAGnum=' num2str(DAGnum)  ' Csp=50 serverNum=5.mat'],"PSOPSR","PSO_PluscomTime");
    
    end


    save(['..\result\n=1-10\PSOPresult\' fn 'result DAGnum=1-10 Csp=50 serverNum=5.mat'],"PSOPalpha","PSOPT");
    save(['..\result\n=1-10\PSOPresult\result' fn '.mat'],"PSOPalpha","PSOPT");

end
save('..\result\n=1-10\PSOPresult\Successtime.mat',"PSOPR");