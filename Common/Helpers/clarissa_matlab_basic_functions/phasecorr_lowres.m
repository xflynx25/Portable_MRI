function [dataFID, dataSpec] = phasecorr_2(usephasecorrection, Ms_reorder_pos,Necho, Npe_all)

if usephasecorrection == 1
dat_nav_pos = Ms_reorder_pos([57,59],:,:);
dat_nav_pos1 = squeeze(dat_nav_pos(1,:,:));
dat_nav_pos2 = squeeze(dat_nav_pos(2,:,:));
tempdiff1 = mean(diff(angle(dat_nav_pos1(132-2:132+2,:)),1,1),1);
tempdiff2 = mean(diff(angle(dat_nav_pos2(132-2:132+2,:)),1,1),1);
tempdiff = mean([tempdiff1;tempdiff2]);
for ii = 1:41
angleramp = [-tempdiff(ii)*128:tempdiff(ii):tempdiff(ii)*127]+angle(dat_nav_pos1(132));
phaseramp(:,ii) = exp( 1j * -angleramp);
end
% phaseramp_3d = repmat(phaseramp, [Necho, 1, Npe_all]);
phaseramp_3d = repmat(reshape(phaseramp,[1,256,41]), [Necho, 1, 1]);
pcorr_3d_comp_pos = phaseramp_3d;
Ms_pcorr_pos = Ms_reorder_pos .* pcorr_3d_comp_pos;
end

%%  process phase corrected data
data0 = permute(Ms_reorder_pos,[2,3,1]);
dataFID= data0(:,:,1:2:end);
dataSpec= data0(:,:,2:2:end);
dataFID(:,:,1:2:end) = dataFID(:,:,1:2:end)*exp(1i*pi);
dataSpec(:,:,1:2:end) = dataSpec(:,:,1:2:end)*exp(1i*pi);