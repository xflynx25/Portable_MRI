function [fmrot] = synthesize_rSEM_fromC(FOV, Nrecon, C, N_order, rotang)
%%field map =  synthesize_field_maps3(XX,YY,pos_temp', fm_freq_corr_no_nav.',field_map_order)+earth_correction(mm);  %%synthesizes field maps from polynomials and adds earth correction 

%% from synthesize field map code
FOVfit = FOV*2; N_reconfit = Nrecon*2;  %%synthesize fieldmap 2x size of recon
crop1 = Nrecon/2+1; crop2 = N_reconfit-Nrecon/2;
[XX,YY] = meshgrid(linspace(-FOVfit/2,FOVfit/2,N_reconfit),linspace(+FOVfit/2,-FOVfit/2,N_reconfit));  %%creates grid of x and y coordinates

field_map = zeros(size(XX));    %initialize field map
coeff_num = 1;                  %intialize variable

for y_order=0:(N_order)
  for x_order=0:(N_order)
    if x_order+y_order<(N_order+1)
       field_map = field_map + C(coeff_num)*XX.^x_order.*YY.^y_order;
       coeff_num = coeff_num+1;
    end
  end
end


fmoffset0 = mean(mean(field_map(end/2:end/2+1,end/2:end/2+1)));  %fieldmap center value
fmrot0 = imrotate(field_map,-rotang,'nearest','crop');  %%imrotate rotates in ccw direction, but magnet rotates in cw dir
 
fmrot = fmrot0(crop1:crop2,crop1:crop2);%-fmoffset0;%-B0_offset;   %%crop down to size of recon
end


