function [dataFID, dataSpec] = phasecorr_4(usephasecorrection, Ms_reorder_pos,Necho, Npe_all)


nphase = size(Ms_reorder_pos,2)/2+4;
nmid = size(Ms_reorder_pos,2)/2;
if usephasecorrection == 1
dat_nav_pos = Ms_reorder_pos([57,59],:,:);
dat_nav_pos1 = squeeze(dat_nav_pos(1,:,:));
dat_nav_pos2 = squeeze(dat_nav_pos(2,:,:));
tempdiff1 = mean(diff(angle(dat_nav_pos1(nphase-2:nphase+2,:)),1,1),1);
temp1 = (((dat_nav_pos1(nphase-1:nphase+1,:))));

tempdiff2 = mean(diff(angle(dat_nav_pos2(nphase-2:nphase+2,:)),1,1),1);
tempdiff = mean([tempdiff1;tempdiff2]);
for ii = 1:Npe_all
angleramp = [-tempdiff(ii)*nmid:tempdiff(ii):tempdiff(ii)*(nmid-1)]+angle(dat_nav_pos1(nphase));
phaseramp(:,ii) = exp( 1j * -angleramp);
end
% phaseramp_3d = repmat(phaseramp, [Necho, 1, Npe_all]);
phaseramp_3d = repmat(reshape(phaseramp,[1,nmid*2,Npe_all]), [Necho, 1, 1]);
pcorr_3d_comp_pos = phaseramp_3d;
Ms_pcorr_pos = Ms_reorder_pos .* pcorr_3d_comp_pos;

dat_nav_poscorr = Ms_pcorr_pos([57,59],:,:);
dat_nav_poscorr1 = squeeze(dat_nav_poscorr(1,:,:));

end

%%  process phase corrected data
data0 = permute(Ms_reorder_pos,[2,3,1]);
dataFID= data0(:,:,1:2:end);
dataSpec= data0(:,:,2:2:end);
dataFID(:,:,1:2:end) = dataFID(:,:,1:2:end)*exp(1i*pi);
dataSpec(:,:,1:2:end) = dataSpec(:,:,1:2:end)*exp(1i*pi);