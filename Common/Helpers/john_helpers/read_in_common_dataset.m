function pd = read_in_common_dataset(id)
    scan_selector = id; 
    if scan_selector == 1 % SOOO NOISY brain
        data_folder = '80mT_Scanner/20240823'; 
        experimentName = 'brain_calibration_repeat2D_newgradON_trial1_FORMATTED';
        Datadir = evalin('base', 'procDataDir');
    end
    if scan_selector == 2 % cleaner brain
        data_folder = '80mT_Scanner/20240823'; 
        experimentName = 'brain_calibration_repeat2D_FORMATTED';
        Datadir = evalin('base', 'procDataDir');
    end
    if scan_selector == 3 % clean distorted ball
        data_folder = '80mT_Scanner/20240823'; 
        experimentName = 'initial_scan_ball7_FORMATTED';
        Datadir = evalin('base', 'procDataDir');
    end
    if scan_selector == 4 % clean decent ball
        data_folder = '80mT_Scanner/20240807'; 
        experimentName = 'calibration_doubleacq_2avgs_FORMATTED';
        Datadir = evalin('base', 'procDataDir');
    end
    if scan_selector == 5 % the broad snr dataset stuff
        data_folder = 'BroadSNRperformance'; 
        experimentName = '8642_FORMATTED';
        Datadir = evalin('base', 'customDataDir');
    end
    if scan_selector == 6 % blanket dirty ball 
        data_folder = 'BroadSNRperformance'; 
        experimentName = 'with_blanket_newgradON_test1_FORMATTED';
        Datadir = evalin('base', 'customDataDir');
    end
    if scan_selector == 7 % averaging
        data_folder = 'AveragingAnalysis'; 
        experimentName = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_3repeat_260_gain60_ball_5th_trial1_FORMATTED';
        Datadir = evalin('base', 'customDataDir');
    end
    if scan_selector == 8 % averaging
        data_folder = 'AveragingAnalysis'; 
        experimentName = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_8repeat_260_gain60_ball_5th_trial1_FORMATTED';
        Datadir = evalin('base', 'customDataDir');
    end
    if scan_selector == 9 % averaging
        data_folder = 'AveragingAnalysis'; 
        experimentName = 'with_blanket_newgradON_doubleacquisition_test1_FORMATTED';
        Datadir = evalin('base', 'customDataDir');
    end
    if scan_selector == 10 % averaging
        data_folder = '80mT_scanner/20240805'; 
        experimentName = '2Dsequence_2Dtable_averaging_singleecho_trigearly_4rx_4repeat_260_gain60_ball_5th_trial1_FORMATTED';
        Datadir = evalin('base', 'procDataDir');
    end
    if scan_selector == 11 % averaging
        data_folder = '80mT_scanner/20240807'; 
        experimentName = 'calibration_doubleacq_4avgs_FORMATTED';
        Datadir = evalin('base', 'procDataDir');
    end
    pd = load(fullfile(Datadir, data_folder, [experimentName, '.mat'])).datafft_combined; %processed data
    disp('loading ..., size')
    size(pd)
end