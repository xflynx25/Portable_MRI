clear all;
%  close all;

data_string = 'E:\DATA_bluestone\20230304\HP_match_N42_sequence_test_stability_diffusiondelays.tnt';

data_string = 'E:\DATA_bluestone\20230304\HP_match_N42_sequence_test_stability_diffusiondelays.tnt';

[ Ms1, Header, Var_data ] = Read_Tecmag(data_string);
Necho = 30;
Npe_all = 41;
Nro   = 128;
Ms_reorder_pos = tntreshape(Ms1, Nro, Necho);
data0 = permute(Ms_reorder_pos,[2,3,1]);

figure; subplot(2,2,1);
imagesc(real(squeeze(data0(64,:,:))));
title('real');
subplot(2,2,2);
imagesc(imag(squeeze(data0(64,:,:))));
title('imaginary');
subplot(2,2,3);
imagesc(abs(squeeze(data0(64,:,:))));
title('mag');
subplot(2,2,4);
imagesc(angle(squeeze(data0(64,:,:))));
title('phase');
% 
% 
% % data_string = 'E:\DATA_bluestone\20230304\HP_not_matched_N42_sequence_diffusiondelays_PDtable_nograd.tnt';
% data_string = 'E:\DATA_bluestone\20230304\HP_not_matched_N42_sequence_nodiffusiondelays_PDtable_45_nograd.tnt';
% 
% [ Ms1, Header, Var_data ] = Read_Tecmag(data_string);
% Necho = 30;
% Npe_all = 41;
% Nro   = 256;
% Ms_reorder_pos = tntreshape(Ms1, Nro, Necho);
% data0 = permute(Ms_reorder_pos,[2,3,1]);
% % 
% figure; subplot(2,2,1);
% imagesc(real(squeeze(data0(128,:,:))));
% subplot(2,2,2);
% imagesc(imag(squeeze(data0(128,:,:))));
% subplot(2,2,3);
% imagesc(abs(squeeze(data0(128,:,:))));
% subplot(2,2,4);
% imagesc(angle(squeeze(data0(128,:,:))));