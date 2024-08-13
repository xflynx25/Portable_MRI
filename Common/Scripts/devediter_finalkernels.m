function [kern_stack, win_stack, ksz_col, ksz_lin] = devediter_finalkernels(combined_data, win_stack, ksz_col, ksz_lin)
    % Phase 3: using the temporal clusters, compute optimal kernels 
    % TODO: refactor for ky proper use availability 
    
    kern_stack = compute_kernels(combined_data, win_stack, ksz_col, ksz_lin);
end
