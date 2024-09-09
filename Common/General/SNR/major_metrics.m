% should give SNR, intraRMS (EMI removal amount), and interRMS (repetition
% differences)
% og means the uncorrected
function [SNR, intraRMS, interRMS] = major_metrics(og1, correct1, og2, correct2, use_saved_coords)
        
    fprintf('SNR INFO FOR: raw 1, corrected 1, raw 2, corrected 2\n');
    SNR1og = calculate_snr_saving2d(og1, use_saved_coords); %if comparing to others 
    SNR1correct = calculate_snr_saving2d(correct1, true); 
    SNR2og = calculate_snr_saving2d(og2, true); 
    SNR2correct = calculate_snr_saving2d(correct2, true); 

    intra_normalized_erms1 = rms(abs(og1(:) - correct1(:)) / rms(abs(correct1(:))));
    intra_normalized_erms2 = rms(abs(og2(:) - correct2(:)) / rms(abs(correct2(:))));
    fprintf('repeat1: Normalized intraRMS diff (would there no EMI correction): %.4f\n', intra_normalized_erms1);
    fprintf('repeat2: Normalized intraRMS diff (would there no EMI correction): %.4f\n', intra_normalized_erms2);
    
    inter_normalized_erms_og = rms(abs(og1(:) - og2(:)) / rms(abs(og2(:))));
    inter_normalized_erms_corrects = rms(abs(correct1(:) - correct2(:)) / rms(abs(correct2(:))));
    fprintf('raw: Normalized interRMS: %.4f\n', inter_normalized_erms_og);
    fprintf('corrected: Normalized interRMS: %.4f\n', inter_normalized_erms_corrects);

    SNR = SNR1correct; 
    intraRMS = intra_normalized_erms1; 
    interRMS = inter_normalized_erms_corrects; 
end 