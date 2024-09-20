function MSE = MSE_ABS(a, b)
    % Ensure both inputs are matrices of the same size
    if ~isequal(size(a), size(b))
        error('Input matrices must have the same dimensions');
    end
    
    % Flatten the matrices to 1D vectors
    a_flat = abs(a(:));
    b_flat = abs(b(:));
    
    % Calculate Mean Squared Error
    MSE = mean((a_flat - b_flat).^2);
end
