function sigma_est = estimate_noise_sigma_MAD(image)
    % Convert to grayscale if the image is RGB
    if size(image, 3) == 3
        image = rgb2gray(image);
    end

    % Apply a high-pass filter to extract high-frequency components
    h = fspecial('gaussian', 3, 1);
    image_filtered = imfilter(image, h, 'replicate');
    image_high_freq = image - image_filtered;

    % Compute the Median Absolute Deviation
    median_high_freq = median(image_high_freq(:));
    mad = median(abs(image_high_freq(:) - median_high_freq));
    sigma_est = mad / 0.6745;
end
