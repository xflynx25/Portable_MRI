function [FPav, FPavfft, freqtrack, freq] = processFP_diffv14(filename)


% filename = ['\2018-09-12\brainslice_4rotations_2average2.MRD'];  

disp(filename)
%% Read In Data
rawdata=read_mrd(filename);
[Tx1_Echos,Tx2_Echos]= getechonumbersv2(filename);

Tx1_Echos = Tx1_Echos-1;

totE = Tx1_Echos+Tx2_Echos;
SW = getBW(filename);
Nro=rawdata.dims(1);
averages=rawdata.dims(4)/(Tx1_Echos+Tx2_Echos);
%averages = 16;
Nr=rawdata.dims(2);
Npe = getPEnum(filename);


time = [1/SW:1/SW:Nro/SW];
acqtime = Nro/SW;


freq=linspace(-SW/2,SW/2,Nro);



%% Reconstruction Data
% data=squeeze(rawdata.data(:,:,:,:));

rawcoildata_1=reshape(rawdata.data(:),Nro,[]);
rawcoildata_2 = reshape(rawcoildata_1, Nro, Npe, []);
datareshape = reshape(rawcoildata_2, Nro, Npe, Nr, totE, averages);


% datareshape = reshape(data, Nro, numPE, totE, averages);
for rr = 1:Nr
data1 = squeeze(datareshape(:,:, rr, [1:Tx2_Echos],:));  


data1av0 = sum(data1,4); data1av = permute(data1av0,[1,3,2]);

data1avcorr = data1av;
data1avcorr(:,3:4:end,:) = data1av(:,3:4:end,:).*exp(1i*pi);
data1avcorr(:,4:4:end,:) = data1av(:,4:4:end,:).*exp(1i*pi);

fftdata = fftshift(fft(fftshift(data1avcorr,1),[], 1),1);
WURSTphasediff = repmat((angle(fftdata(:,2,:)) - angle(fftdata(:,1,:))),1,Tx2_Echos,1);
fftdataWcorr = fftdata;
fftdataWcorr(:,2:2:end,:) = fftdata(:,[2:2:end],:).*exp(-1i*WURSTphasediff(:,[2:2:end],:));
data1avWcorr = fftshift(ifft(fftshift(fftdataWcorr,1),[], 1),1);
FPav(:,rr) = sum(reshape(data1avWcorr,Nro, []),2);

FPavfft(:,rr) = sum(reshape(fftdataWcorr,Nro, []),2);

[val,I] = max(abs(FPavfft(:,rr)));
freqtrack(rr) = freq(I);
% figure(1); hold on; plotnmr2(freq, fftshift(fft(fftshift(FPav(:,rr)))));
% figure; plotnmr2(freq,FPavfft);

end

% figure; plot(freqtrack);
