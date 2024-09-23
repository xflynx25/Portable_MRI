function [fmrot] = synthesize_rSEM_fromC_v2(FOV, Nrecon,  C, pos, N_order, rotangdeg)

%%fmrot = synthesize_rSEM_fromC_v2(FOV, Nrecon, Cq(:,rr), pos, N_order, angsq(1)); 

%  synthesize_field_maps3(XX,YY,trajectory_all, field_all, N_order)
% %%field map =  synthesize_field_maps3(XX,YY,pos_temp', fm_freq_corr_no_nav.',field_map_order)+earth_correction(mm);  %%synthesizes field maps from polynomials and adds earth correction 
% 
%     M(1,1) = cos(rotang)); M(1,2) = sin(rotang);  M(2,1) = -sin(rotang);  M(2,2) =  cos(rotang);
%     %     load(['Halbach2_FM_radial_0cm_',num2str(angs(ii)),'deg_11_22_16']);
%     load(['FM',num2str(angsmapped(ii)),'deg652017']);
%     
%     temp = M*pos0.'; pos_rot = temp.';
        
[XX,YY] = meshgrid(linspace(-FOV/2,FOV/2,Nrecon),linspace(-FOV/2,FOV/2,Nrecon));


% %% from synthesize field map code
% FOVfit = FOV*2; N_reconfit = Nrecon*2;  %%synthesize fieldmap 2x size of recon
% crop1 = Nrecon/2+1; crop2 = N_reconfit-Nrecon/2;
% [XX,YY] = meshgrid(linspace(-FOVfit/2,FOVfit/2,N_reconfit),linspace(+FOVfit/2,-FOVfit/2,N_reconfit));  %%creates grid of x and y coordinates

% field_map = zeros(size(XX));    %initialize field map
coeff_num = 1;                  %intialize variable

% for y_order=0:(N_order)
%   for x_order=0:(N_order)
%     if x_order+y_order<(N_order+1)
%        field_map = field_map + C(coeff_num)*XX.^x_order.*YY.^y_order;
%        coeff_num = coeff_num+1;
%     end
%   end
% end

fm_freq = zeros(size(pos(:,1)));
for y_order=0:(N_order)
  for x_order=0:(N_order)
    if x_order+y_order<(N_order+1)
       fm_freq = fm_freq + C(coeff_num)*pos(:,1).^x_order.*pos(:,2).^y_order;
       coeff_num = coeff_num+1;
    end
  end
end


rotang = deg2rad(rotangdeg);

 M(1,1) = cos(rotang); M(1,2) = sin(rotang);  M(2,1) = -sin(rotang);  M(2,2) =  cos(rotang);
 temp = M*pos.'; pos_rot = temp.';

fmrot = synthesize_field_maps3(XX,YY, pos_rot, fm_freq, N_order);


% fmrot = field_map;
% fmoffset0 = mean(mean(field_map(end/2:end/2+1,end/2:end/2+1)));  %fieldmap center value
% fmrot0 = imrotate(field_map,-rotang,'crop');  %%imrotate rotates in ccw direction, but magnet rotates in cw dir
%  
% fmrot = fmrot0(crop1:crop2,crop1:crop2);%-fmoffset0;%-B0_offset;   %%crop down to size of recon
end


