function [dataFID, dataSpec] = phasecorr_EMI(usephasecorrection, Ms_reorder_pos,Necho, Npe_all, EMIacq)


nphase = size(Ms_reorder_pos,2)/2+4;

nRO = size(Ms_reorder_pos,2);
nmid = size(Ms_reorder_pos,2)/2;

if EMIacq == 1
    navechos = [Necho/2-3,Necho/2-1];
else
    navechos = [Necho-3,Necho-1];
end

if usephasecorrection == 1
dat_nav_pos = Ms_reorder_pos(navechos,:,:);
dat_nav_pos1 = squeeze(dat_nav_pos(1,:,:));
dat_nav_pos2 = squeeze(dat_nav_pos(2,:,:));

[y, nphase1] = max(dat_nav_pos1);
[y, nphase2] = max(dat_nav_pos2);
nphase1 = round(mean(nphase1));
nphase2 = round(mean(nphase2));

fitpoints1 = nphase1-1:nphase1+1;
fitpoints2 = nphase2-1:nphase2+1;

% xfit1 = [1:numel(fitpoints1)];
% yfit1 = unwrap(angle(dat_nav_pos1(fitpoints1,:)));
% yfit2 = unwrap(angle(dat_nav_pos2(fitpoints2,:)));
% [slope1, offset] = linefit_multi(xfit1, yfit1, 0);
% [slope2, offset] = linefit_multi(xfit1, yfit2, 0);
% % 
xfit1 = [1:nRO];
yfit1 = unwrap(angle(dat_nav_pos1(:,:)));
yfit2 = unwrap(angle(dat_nav_pos2(:,:)));
[slope1, offset] = linefit_multi(xfit1, yfit1, 0);
[slope2, offset] = linefit_multi(xfit1, yfit2, 0);

% slope3 = mean([slope1;slope2],1);
slope3 = mean([slope1;slope2],1);
[slope4, offset3,slopefit] = linefit([1:Npe_all], slope3, 0);

% figure; plot([slope1;slope2;slope3;slopefit].');



% % tempdiff0 = ((angle(dat_nav_pos1(nphase-2:nphase+2,:)),1,1),1);
% 
% tempdiff1 = mean(diff(angle(dat_nav_pos1(nphase-2:nphase+2,:)),1,1),1);
% temp1 = (((dat_nav_pos1(nphase-1:nphase+1,:))));
% 
% tempdiff2 = mean(diff(angle(dat_nav_pos2(nphase-2:nphase+2,:)),1,1),1);
% tempdiff = mean([tempdiff1;tempdiff2]);
for ii = 1:Npe_all
% angleramp = [-tempdiff(ii)*nmid:tempdiff(ii):tempdiff(ii)*(nmid-1)]+angle(dat_nav_pos1(nphase));
angleramp = [1:nRO]*slopefit(ii);
% angleramp = [1:nRO]*slope3(ii);
phaseramp(:,ii) = exp( 1j * -angleramp);

for iii = 1:Necho

datacorrected(iii,:,ii) = (Ms_reorder_pos(iii,:,ii)).*phaseramp(:,ii).' ;
end
end

anglecheck = angle(datacorrected(57,nphase2,1));
disp(anglecheck);
datacorrected = datacorrected.*exp( 1j * -anglecheck);

% % phaseramp_3d = repmat(phaseramp, [Necho, 1, Npe_all]);
% phaseramp_3d = repmat(reshape(phaseramp,[1,nRO,Npe_all]), [Necho, 1, 1]);
% pcorr_3d_comp_pos = phaseramp_3d;
% Ms_pcorr_pos = Ms_reorder_pos .* pcorr_3d_comp_pos;
% 

else
    datacorrected = Ms_reorder_pos ;
end

%%  process phase corrected data

data0 = permute(datacorrected,[2,3,1]);
dataFID= data0(:,:,1:2:end);
dataSpec= data0(:,:,2:2:end);
dataFID(:,:,1:2:end) = dataFID(:,:,1:2:end)*exp(1i*pi);
dataSpec(:,:,1:2:end) = dataSpec(:,:,1:2:end)*exp(1i*pi);