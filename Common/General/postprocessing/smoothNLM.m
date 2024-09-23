function corrected_img = smoothNLM(img, smoothing)
    % .08 seems to be a default
    corrected_img = imnlmfilt(abs(img), 'DegreeOfSmoothing', smoothing);
end 