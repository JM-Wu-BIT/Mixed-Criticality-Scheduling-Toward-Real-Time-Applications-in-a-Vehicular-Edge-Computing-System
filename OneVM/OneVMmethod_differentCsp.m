clc
clear
close all
OneVMR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)];
    load(['..\data\' fn '.mat']);
    
    serverNum = 5;%Number of servers
    DAGnum = 10;%Number of DAGs
    
    
    OneVMT=[];
    OneVMalpha=[];
    
    
    for DAG_id=1:DAGnum
        DAG{DAG_id}{6}=randi(serverNum);
        DAGnew{DAG_id}=DAG{DAG_id};
    end
    DAG=DAGnew;
    %different available computation resource
    for C_s=10:10:100
        C_s
    
        tic
        OneVMSR = OneVM(serverNum,DAG,C_s);
        OneMVcomTime=toc 
        OneVMR(C_s/10)=OneVMR(C_s/10)+issuccessful(OneVMSR);
        OneVMT(C_s/10)=OneMVcomTime;
        OneVMalpha(C_s/10,:)=OneVMSR;
        save(['..\result\Csp=10-100\OneVMresult\Process result\' fn ' Csp=' num2str(C_s) ' serverNum=5 DAGnum=10.mat'],"OneVMalpha","OneVMT");
    end
    
    save(['..\result\Csp=10-100\OneVMresult\' fn 'result Csp=10-100 serverNum=5 DAGnum=10.mat'],"OneVMalpha","OneVMT");
    save(['..\result\Csp=10-100\OneVMresult\result' fn '.mat'],"OneVMalpha","OneVMT");
end
save('..\result\Csp=10-100\OneVMresult\Successtime',"OneVMR");