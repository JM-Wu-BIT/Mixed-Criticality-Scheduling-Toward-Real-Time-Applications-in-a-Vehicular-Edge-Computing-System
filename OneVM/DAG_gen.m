function DAG = DAG_gen(DAGnum,serverNum,C_s)

periodArray = [];
for DAG_id = 1:DAGnum
    level = 5+randi(15);
    tasksMaxLevel = 10;
    DAG_comCost = setupData(level, tasksMaxLevel); % Generate DAG
    taskCount = size(DAG_comCost, 1);
    DAG_load = 50+randi(50, 1, taskCount); % load base

    DAG_load_new = [];
    for i = 1:size(DAG_load, 2)
        preTasks{i} = (find(DAG_comCost(:,i)~=0))';
        for j = 1:C_s
            if isequal(j, 1)
                DAG_load_new(i,j) = DAG_load(i);
            else
                DAG_load_new(i,j) = randi([(j-1)*100,j*100])/(j*100)*DAG_load_new(i,j-1); % 对于DAG里第i个任务在拥有j个vCPU情况下的执行时间
            end
        end
    end
    DAG_load = DAG_load_new;

    DAG_period = round(sum(DAG_load(:, 50)))*1.8; % Setting the release period and time response period
    if randi(100) > 50 %Randomized Generation of DAG Key Levels
        crit = 1; % There is a 0.5 probability that the key level is HI,0.5 probability that the key level is LO
    else
        crit = 0;
    end
    periodArray = [periodArray, DAG_period];
    DAG{DAG_id}{1} = DAG_load;
    DAG{DAG_id}{2} = DAG_comCost;
    DAG{DAG_id}{3} = preTasks;
    DAG{DAG_id}{4} = DAG_period;
    DAG{DAG_id}{5} = crit;
    DAG{DAG_id}{6} = randi(serverNum); % Randomly assign a server
    DAG{DAG_id}{7} = 1:size(DAG_comCost,2);%DAG Task Priority
end
end

