clc
clear
close all

DPR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)]
    load(['..\data\' fn '.mat']);
    
    serverNum = 5;%Number of servers
    C_s = 50; %available computation resource
    
    
    DPT=[];
    DPalpha=[];
    
    for DAGnum=1:10
        DAGnum
        DAGnew=[];
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
            DAGnew{DAG_id}=DAG{DAG_id};
        end
        
        tic
        [DPSR] = DP(serverNum,DAGnew,DAGnum,C_s);
        DPcomTime=toc 
        DPR(DAGnum)=DPR(DAGnum)+issuccessful(DPSR);
        DPT(DAGnum)=DPcomTime;
        DPalpha(DAGnum,:)=DPSR;
        save(['..\result\n=1-10\DPresult\Process result\' fn ' DAGnum=' num2str(DAGnum)  ' Csp=50 serverNum=5.mat'],"DPSR","DPcomTime");
    
    end
    
    save(['..\result\n=1-10\DPresult\' fn 'result DAGnum=1-10 Csp=50 serverNum=5.mat'],"DPalpha","DPT");
    save(['..\result\n=1-10\DPresult\result' fn '.mat'],"DPalpha","DPT");
end
save('..\result\n=1-10\DPresult\Successtime.mat',"DPR");