function exec_time_i = DP_executionTimeFuc(vm_update, DAG_id)

resource = vm_update(1, end);                       %computing resource
position = find(vm_update(:, 1) == DAG_id);         %Find the location of this DAG task
currentJob = vm_update(position,:);                 %Currently performing tasks for this DAG task
job_ahead = vm_update(1:position-1, :);  
job_lag = vm_update(position+1:end, :);
if isempty(job_lag)%job_lag is empty, no preemption
    execMax = 0;
else
    execMax = max(job_lag(:,3)/job_lag(end,end));     %Consider the worst case scenario where job_lag's MaxResponce_job preempts currentJob       
end

if isempty(currentJob)
    exec_time_i =0;
    return
end

%Calculation of execution time
if isempty(job_ahead)
    exec_time_i = execMax + currentJob(3);
else
    exec_time_currentJob = currentJob(3);
    reponseTime = exec_time_currentJob;
    while 1%Calculate the execution time of all jobs in job_ahead
        exec_time_ahead = exec_time_currentJob;
        for i = 1:size(job_ahead, 1)                                    
            exec_time_ahead = exec_time_ahead + ceil(reponseTime/job_ahead(i,2))*job_ahead(i,3);
        end
        if exec_time_ahead > vm_update(1, 4)
            exec_time_i = execMax + exec_time_ahead;
            break
        elseif abs(exec_time_ahead - reponseTime) > 1e-3       %If exec_time_ahead - reponseTime > 0. This indicates that job_ahead is not empty
            reponseTime = exec_time_ahead;
        else
            exec_time_i = execMax + exec_time_ahead;
            break
        end
    end
end



