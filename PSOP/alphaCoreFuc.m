function alpha = alphaCoreFuc(critArray, periodArray, execArray)

execHIArray = execArray;

epislon = 0.01;
alpha_l = 0;
alpha_r = 1;
while alpha_r - alpha_l > epislon
    alpha = (alpha_l + alpha_r)/2;
    %Consider only low-criticality deflation
    execLOArray = (alpha*(1 - critArray)).*execHIArray + critArray.*execHIArray;
    schedulePass = schedulabilityTestFuc(critArray, periodArray, execLOArray, execHIArray);
    if schedulePass
        alpha_l = alpha;
    else
        alpha_r = alpha;
    end
end