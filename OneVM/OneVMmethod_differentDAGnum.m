clc
clear
close all

OneVMR=zeros(1,10);
for i=1:50
    fn=['DAG_data' num2str(i)];
    load(['..\data\' fn '.mat']);
    
    serverNum = 5;%Number of servers
    C_s = 50; %available computation resource
    
    OneVMT=[];
    OneVMalpha=[];
    DAGnew=[];
    for DAGnum=1:10
        DAGnum
    
        for DAG_id=1:DAGnum
            DAG{DAG_id}{6}=randi(serverNum);
            DAGnew{DAG_id}=DAG{DAG_id};
        end
    
        tic
        OneVMSR = OneVM(serverNum,DAGnew,C_s);
        OneMVcomTime=toc 
        OneVMR(DAGnum)=OneVMR(DAGnum)+issuccessful(OneVMSR);
        OneVMT(DAGnum)=OneMVcomTime;
        OneVMalpha(DAGnum,:)=OneVMSR;
         save(['..\result\n=1-10\OneVMresult\Process result\' fn ' DAGnum=' num2str(DAGnum) ' Csp=50 serverNum=5.mat'],"OneVMSR","OneMVcomTime");
    end

    save(['..\result\n=1-10\OneVMresult\' fn 'result DAGnum=1-10 Csp=50 serverNum=5.mat'],"OneVMalpha","OneVMT");
    save(['..\result\n=1-10\OneVMresult\result' fn '.mat'],"OneVMalpha","OneVMT");

end
save('..\result\n=1-10\OneVMresult\Successtime.mat',"OneVMR");