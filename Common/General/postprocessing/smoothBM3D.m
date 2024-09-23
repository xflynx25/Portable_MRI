function corrected_img = smoothBM3D(img, sigma)
    % typically we want close to the MAD
    corrected_img = BM3D(img, sigma, 'np');
end 