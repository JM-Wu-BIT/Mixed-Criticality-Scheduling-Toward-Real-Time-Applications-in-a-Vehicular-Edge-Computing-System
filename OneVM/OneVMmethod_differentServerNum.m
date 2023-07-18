clc
clear
close all
OneVMR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)];
    load(['..\data\' fn '.mat']);
    
    C_s = 50;%available computation resource
    DAGnum = 10;%Number of DAGs
    
    
    OneVMT=[];
    OneVMalpha=[];
    
    
    for DAG_id=1:DAGnum
        %DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    %different serverNum
    for serverNum=1:10
        serverNum
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
        end
    
        tic
        OneVMSR = OneVM(serverNum,DAG,C_s);
        OneVMcomTime=toc 
        OneVMR(serverNum)=OneVMR(serverNum)+issuccessful(OneVMSR);
        OneVMT(serverNum)=OneVMcomTime;
        OneVMalpha{serverNum}=OneVMSR;
        save(['..\result\m=1-10\OneVMresult\Process result\' fn ' serverNum=' num2str(serverNum)  ' Csp=50 DAGnum=10.mat'],"OneVMSR","OneVMcomTime");
    end
    
    save(['..\result\m=1-10\OneVMresult\' fn 'result serverNum=1-10 Csp=50 DAGnum=10.mat'],"OneVMalpha","OneVMT");
    save(['..\result\m=1-10\OneVMresult\result' fn '.mat'],"OneVMalpha","OneVMT");
end
save('..\result\m=1-10\OneVMresult\Successtime.mat',"OneVMR");