function vm_update = DP_updateVMfuc(vm_i, DAG_id, j)

vm_update = [];
for i = 1:size(vm_i, 1)
    if ~eq(vm_i(i,1), DAG_id)                  %Find tasks that are not this DAG
        vm_update = [vm_update; vm_i(i, :)];
    elseif eq(i, j)                            % i j can only be equal once, and the other tasks of this DAG can be deleted by this link.
        vm_update = [vm_update; vm_i(i, :)];   %In the previous loop j represented the number of rows in the target job, in this loop i also represents the number of rows, traversed in the same VM, i = j means the target job is found
    end
end



        