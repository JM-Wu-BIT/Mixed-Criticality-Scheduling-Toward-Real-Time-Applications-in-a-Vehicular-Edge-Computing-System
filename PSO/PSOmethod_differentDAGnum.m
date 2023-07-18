clc
clear
close all

PSOR=zeros(1,10);
for i=1:50
fn=['DAG_data' num2str(i)]
load(['..\data\' fn '.mat']);

serverNum = 5;%Number of servers
C_s = 50; %available computation resource


PSOT=[];
PSOalpha=[];


DAGnew=[];

for DAGnum=1:10
    DAGnum

    for DAG_id=1:DAGnum
        DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end

    tic
    [ServerResult,PSOrate,PSOSR]=PSO(serverNum,C_s,DAGnew);
    PSOcomTime = toc
    PSOR(DAGnum)=PSOR(DAGnum)+issuccessful(PSOSR);
    PSOT(DAGnum)=PSOcomTime;
    PSOalpha(DAGnum,:)=PSOSR;
    
    save(['..\result\n=1-10\PSOresult\Process result\' fn ' DAGnum=' num2str(DAGnum)  ' Csp=50 servernum=5.mat'],"PSOSR","PSOcomTime");

end


    save(['..\result\n=1-10\PSOresult\' fn 'result DAGnum=1-10 Csp=50 serverNum=5.mat'],"PSOalpha","PSOT");
    save(['..\result\PSOresult\result' fn '.mat'],"PSOalpha","PSOT");
end

save('..\result\n=1-10\PSOresult\Successtime.mat',"PSOR");

