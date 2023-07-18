function [alphaOutput,vCPUwrtVMOutput,resultOutput] = alphaComputeWRTserver(DAG, DAG_id, C_s)

DAGnew = {};
counter = 1;
periodArray = [];
serverCheck = DAG{DAG_id}{6};
DAG_index=[];
for i = 1:size(DAG, 2)
    if isequal(DAG{i}{6}, serverCheck)%Find the DAG that works with the same server as DAG_id
        periodArray = [periodArray, DAG{i}{4}];
        DAGnew{counter} = DAG{i};
        counter = counter + 1;
        DAG_index=[DAG_index,i];
    end
end
DAG = DAGnew;
result=[];
DAGnew = {};
DAG_array=[];
[~, index] = sort(periodArray, 'ascend');%Ascending order based on release frequency
for i = 1:size(DAG, 2)%Reordering of DAGs based on alignment results
    DAG_array=[DAG_array,DAG_index(index(i))];
    DAGid = index(i);
    DAGnew{i} = DAG{DAGid};
end
DAG = DAGnew;

initialVMcount = floor(C_s/3)+1;%Initialize (C_s/3) VMs in the server
vCPUperVM = floor(C_s/initialVMcount);%Distribute virtual machine resources evenly
vCPUwrtVM = vCPUperVM*ones(1, initialVMcount);
vCPUwrtVM(end) = C_s - sum(vCPUwrtVM(1:end-1));
iterNum = 1000;

[alpha,result] = alphaComputeFuc(DAG, vCPUwrtVM,DAG_array);%Calculate the maximum alpha that the current DAG can get in the current situation

counter = 0;%If more than 20 iterations are performed without obtaining a new alpha value that exceeds the alpha value, the current value is considered to be the optimal value
for iter = 2:iterNum
    if size(vCPUwrtVM, 2) >= 2% If the number of VMs within the current server is greater than or equal to 2, VM compute resource consolidation is attempted
        vCPUwrtVM_merge = [];
        % Randomly select two VMs in a cluster of virtualizers for consolidation
        mergeVMids = randperm(size(vCPUwrtVM, 2));
        vCPUwrtVM_merge(1) = vCPUwrtVM(mergeVMids(1)) + vCPUwrtVM(mergeVMids(2));
        %Consolidated in-server VM compute resources
        vCPUwrtVM_merge = [vCPUwrtVM_merge, vCPUwrtVM(mergeVMids(3:end))];
        %Calculate the maximum alpha value of the DAG after reallocating VM resources
        [alphaMerge,resultMerge] = alphaComputeFuc(DAG, vCPUwrtVM_merge,DAG_array);
    else%
        vCPUwrtVM_merge = vCPUwrtVM;
        [alphaMerge,resultMerge] = alphaComputeFuc(DAG, vCPUwrtVM_merge,DAG_array);
    end
    %Randomly select a VM in the VM compute resource set
    if ~isequal(C_s,1)
        vcpusSep = 1;
        while isequal(vcpusSep, 1)
            sepVMid = randi(size(vCPUwrtVM, 2));
            vcpusSep = vCPUwrtVM(sepVMid);
        end
        %Try to randomly split the selected VM into two VMs
        vcpusSep1 = randi(vcpusSep-1);
        vcpusSep2 = vcpusSep-vcpusSep1;
        vCPUwrtVM_sep = [vCPUwrtVM(1:sepVMid-1), vcpusSep1, vcpusSep2, vCPUwrtVM(sepVMid+1:end)];
        [alphaSep,resultSep] = alphaComputeFuc(DAG, vCPUwrtVM_sep,DAG_array);
    else
        alphaSep=0;
        vCPUwrtVM=[1];
        resultSep=[];
    end
    %Compare which computed alpha value is greater for VM splitting vs. merging
    if max(alphaMerge, alphaSep) > alpha
        alpha = max(alphaMerge, alphaSep);
        if alphaMerge > alphaSep
            vCPUwrtVM = vCPUwrtVM_merge;
            result=resultMerge;
        else
            vCPUwrtVM = vCPUwrtVM_sep;
            result=resultSep;
        end
        counter = 0;
    else
        counter = counter + 1;
        if counter > 20
            alphaOutput = alpha;
            resultOutput=result;
            vCPUwrtVMOutput=vCPUwrtVM;
            break
        end
    end
end