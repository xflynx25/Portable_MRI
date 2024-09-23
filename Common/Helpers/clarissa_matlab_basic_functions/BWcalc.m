function [BW,coil_fc] = BWcalc(freq,s12,plot_yn)

[y,I] = max(s12);
coil_fc = freq(I);

[temp1,Ineg3db] = min(abs(s12(1:I) - (y-3)));
[temp2,Ipos3db_0] = min(abs(s12(I:end) - (y-3)));

Ipos3db = Ipos3db_0 + I;

yneg3db = s12(Ineg3db);
ypos3db = s12(Ipos3db);
f_neg3db = freq(Ineg3db);
f_pos3db = freq(Ipos3db);
BW = (f_pos3db - f_neg3db)/1000; % BW in kHz

if plot_yn == 1
    figure;
    plot(freq,s12);
    hold on;
    plot(coil_fc, y, 'or');
    
    plot([f_neg3db,f_pos3db], [yneg3db ypos3db], '-k');
    
    title(['fc = ',num2str(coil_fc/1e6),' MHz, BW = ',num2str(BW),' kHz']);
    xlabel('freq (Hz)');  ylabel('S12 (dB)');
    xlim([min(freq), max(freq)]);
end



