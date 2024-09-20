% Test Script for my_zscore Function

% Generate Sample Data
test_data = [1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12];

% Apply Custom Z-Score Normalization
normalized_test_data = zscore_normalization(test_data);

% Display Results
disp('Original Data:');
disp(test_data);

disp('Normalized Data:');
disp(normalized_test_data);

% Verify Mean and Standard Deviation
mean_normalized = mean(normalized_test_data, 1);
std_normalized = std(normalized_test_data, 0, 1);

disp('Mean after normalization:');
disp(mean_normalized);

disp('Standard Deviation after normalization:');
disp(std_normalized);
