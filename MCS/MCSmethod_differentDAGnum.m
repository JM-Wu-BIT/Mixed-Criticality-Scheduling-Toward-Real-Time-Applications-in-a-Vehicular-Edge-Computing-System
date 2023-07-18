clc
clear
close all

MCSR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    C_s = 50; % available computation resource
    serverNum = 5;%Number of servers
    
    MCST=[];
    MCSalpha=[];
    
    for DAGnum=1:10
        DAGnum
        DAGnew=[];
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
            DAGnew{DAG_id}=DAG{DAG_id};
        end
    
        tic
        [MCSSR,Server_vcpu,Server_choice,DAG_task]= MCS(serverNum,DAGnum,DAGnew,C_s);
        MCScomTime = toc
        MCSR(DAGnum)=MCSR(DAGnum)+issuccessful(MCSSR);
        MCST(DAGnum)=MCScomTime;
        MCSalpha(DAGnum,:)=MCSSR;
        filename=['..\result\n=1-10\MCSresult\Process result\' fn ' DAGnum=' num2str(DAGnum) '.mat'];
        save(filename,"Server_choice","Server_vcpu","DAG_task");
        save(['..\result\n=1-10\MCSresult\Process result\' fn ' DAGnum=' num2str(DAGnum) ' Csp=50 serverNum=5.mat'],"MCSSR","MCScomTime");
    end
    
    save(['..\result\n=1-10\MCSresult\' fn 'result DAGnum=1-10 Csp=50 serverNum=5.mat'],"MCSalpha","MCST");
    save(['..\result\n=1-10\MCSresult\result' fn '.mat'],"MCSalpha","MCST");

end

save('..\result\n=1-10\MCSresult\Successtime.mat',"MCSR");