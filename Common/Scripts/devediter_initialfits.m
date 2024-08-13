function [starter_kern_stack] = devediter_initialfits(combined_data, W, ksz_col, ksz_lin)
    % Phase 1: find initial kernels 
    % TODO: implement ability to have ky with W = 1 
    % TODO: implement varying W parameter


    % Image size
    ncol = size(combined_data, 1);
    nlin = size(combined_data, 2);

    win_stack = cell(nlin, 1);
    for lin = 1:nlin
        win_stack{lin} = lin;  
    end

    starter_kern_stack = compute_kernels(combined_data, win_stack, ksz_col, ksz_lin); 
end

