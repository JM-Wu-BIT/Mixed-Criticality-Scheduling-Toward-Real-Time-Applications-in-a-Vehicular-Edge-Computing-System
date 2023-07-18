function [Assign,value_task]=DP_Mix_CriticalityFuc(ServerNum,Assign,C_s,DAG_load,DAG_priority,DAG_period,DAG_deadline,DAG_id,DAG_communicationCost,DAG_id_Serves, DAG_criticality,i)

 for n=1:ServerNum
     id_In_Serves=DAG_id_Serves{n};
    if isempty(Assign{n})        %The case where the server is empty
        for i=1:size(DAG_load,1)       
            for j=1:C_s(n)
                resource = j;
                if eq(i,1)%When the server performs the first task, it needs to create a virtual machine to perform the task
                    Assign{n}{i}{j}{1} = [DAG_id, DAG_period, DAG_load(i,resource), DAG_deadline, DAG_priority(i), resource];%将虚拟机具有不同资源的情况列出
                else
                    newjob = [DAG_id, DAG_period, DAG_load(i,resource), DAG_deadline, DAG_priority(i)];
                            
                    %Try to put newjob into a VM with compute resource j for execution
                    valueTemp = [];
                    insertPositionTemp = [];
                    virtualMachines = Assign{n}{i-1}{j};
                    if isempty(virtualMachines)%If the virtual machine does not exist, this method is not effective
                        valueMaxMerge = inf;
                    else
                        for k = 1:size(virtualMachines, 2) %Try to put it into each VM, calculate the execution time and insertion location
                            [responseTimeNewJob, insertPosition] = DP_responseTimeMergeFuc_modified(virtualMachines, newjob, k,DAG_communicationCost,id_In_Serves);
                            valueTemp = [valueTemp, responseTimeNewJob];
                            insertPositionTemp = [insertPositionTemp, insertPosition];
                        end
                        [valueMaxMerge, indexMerge] = min(valueTemp);%Select the VM with the shortest execution time as the VM of choice
                        indexPosition = insertPositionTemp(indexMerge);
                    end

                    %Try to put newjob into a VM with less compute resources than j to execute it
                    valeMaxSep = inf;
                    resourceAssigned = 0;
                    for k=1:resource-1%k denotes the resources for executing the newjob virtual machine
                        value_Sep_Temp = DAG_load(i,k);
                        resource_left = resource - k;
                        virtualMachines = Assign{n}{i-1}{resource_left};
                        if ~isempty(virtualMachines)
                            responseTimeNewJob = DP_responseTimeSepFuc(virtualMachines, newjob, k,DAG_communicationCost);
                            if responseTimeNewJob < valeMaxSep
                                valeMaxSep = responseTimeNewJob;
                                resourceAssigned = k;
                            end
                        end
                    end
                    % Find the shortest execution time of the two ways as the newjob's execution and update the virtual machine
                    if  valeMaxSep >= valueMaxMerge
                         Assign{n}{i}{j} = Assign{n}{i-1}{j};
                         job_VM = Assign{n}{i}{j}{indexMerge};
                         job_VM = [job_VM(1:indexPosition,:); newjob, job_VM(end,end); job_VM(indexPosition+1:end, :)];
                         Assign{n}{i}{j}{indexMerge} = job_VM;
                         value_task_Temp= valueMaxMerge;
                    else
                        Assign{n}{i}{j} = Assign{n}{i-1}{resource - resourceAssigned};
                        size_vm = size(Assign{n}{i}{j}, 2);
                        job_VM = [newjob, resourceAssigned];
                        Assign{n}{i}{j}{size_vm+1} = job_VM;
                        value_task_Temp=valeMaxSep;
                    end
                if i==size(DAG_load,1)
                    value_task{n}{i}=[value_task_Temp];  
                else
                    value_task{n}{i}=[value_task_Temp];  
                end
                end
            end
        end                   
    %When there are already tasks in the server
    else
        existing_num=size(Assign{n},2);
        for i=1:size(DAG_load,1)
            for j=1:C_s(n)
                resource = j;
                newjob = [DAG_id, DAG_period, DAG_load(i,resource), DAG_deadline, DAG_priority(i)];
                
                %Try to put newjob into a VM with compute resource j for execution
                valueTemp = [];
                insertPositionTemp = [];
                virtualMachines = Assign{n}{existing_num+i-1}{j};
                if isempty(virtualMachines)
                    valueMaxMerge = inf;
                else
                    for k = 1:size(virtualMachines, 2)%Try to put the newjob into each VM
                        [responseTimeNewJob, insertPosition] = DP_responseTimeMergeFuc_modified(virtualMachines, newjob, k,DAG_communicationCost,id_In_Serves);
                        valueTemp = [valueTemp, responseTimeNewJob];
                        insertPositionTemp = [insertPositionTemp, insertPosition];
                    end
                    [valueMaxMerge, indexMerge] = min(valueTemp);
                    indexPosition = insertPositionTemp(indexMerge);
                end
                
                %Find the shortest execution time of the two ways as the newjob's execution and update the virtual machine
                valeMaxSep = inf;
                resourceAssigned = 0;
                for k=1:resource-1
                    newjob(3) = DAG_load(i,k);
                    resource_left = resource - k;
                    virtualMachines = Assign{n}{existing_num+i-1}{resource_left};
                    pass_DAG = true;
                    if pass_DAG 

                        if ~isempty(virtualMachines)
                            responseTimeNewJob = DP_responseTimeSepFuc(virtualMachines, newjob, k,DAG_communicationCost);
                            if responseTimeNewJob < valeMaxSep
                                valeMaxSep = responseTimeNewJob;
                                resourceAssigned = k;
                            end
                        end
                    else
                        continue
                    end
                end
                %Find the shortest execution time of the two ways to execute as a newjob
                if valeMaxSep >= valueMaxMerge
                     Assign{n}{existing_num+i}{j} = Assign{n}{existing_num+i-1}{j};
                     job_VM = Assign{n}{existing_num+i}{j}{indexMerge};
                     job_VM = [job_VM(1:indexPosition,:); newjob, job_VM(end,end); job_VM(indexPosition+1:end, :)];
                     Assign{n}{existing_num+i}{j}{indexMerge} = job_VM;
                     value_task_Temp= valueMaxMerge;
                else
                    Assign{n}{existing_num+i}{j} = Assign{n}{existing_num+i-1}{resource - resourceAssigned};
                   size_vm = size(Assign{n}{existing_num+i}{j}, 2);
                    job_VM = [newjob, resourceAssigned];
                    Assign{n}{existing_num+i}{j}{size_vm+1} = job_VM;
                    value_task_Temp=valeMaxSep;
                end 
                if i==size(DAG_load,1)
                    value_task{n}{i}=[value_task_Temp];  
                else
                    value_task{n}{i}=[value_task_Temp];  
                end
            end
        end
    end
 end



