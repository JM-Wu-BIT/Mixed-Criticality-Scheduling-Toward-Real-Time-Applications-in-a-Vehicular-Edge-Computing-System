function DAG_Matrix = setupData(level, tasksMaxLevel)

taskLevelArray = [0, 1];
for i = 2:level-1
    taskLevelArray(i,:) = [taskLevelArray(i-1,1)+taskLevelArray(i-1,2), 1 + randi(tasksMaxLevel)];
end
taskLevelArray(level,:) = [taskLevelArray(level-1,1)+taskLevelArray(level-1,2), 1];

numTask = taskLevelArray(end,1) + 1;
DAG_Matrix = zeros(numTask, numTask);

for xx = 1:1
    for i = 1:level-1
        for j = 1:taskLevelArray(i,end)
            DAG_Matrix(taskLevelArray(i,1)+j, taskLevelArray(i+1,1)+randi(taskLevelArray(i+1,2))) = randi(15);
        end
    end
    for i = level:-1:2
        for j = 1:taskLevelArray(i,end)
            DAG_Matrix(taskLevelArray(i-1,1)+randi(taskLevelArray(i-1,2)), taskLevelArray(i,1)+j) = randi(15);
        end
    end
end