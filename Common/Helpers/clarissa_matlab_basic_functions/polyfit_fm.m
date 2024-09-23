function [C] = polyfit_fm(trajectory_all, field_all, N_order)
%%field map =  synthesize_field_maps3(XX,YY,pos_temp', fm_freq_corr_no_nav.',field_map_order)+earth_correction(mm);  %%synthesizes field maps from polynomials and adds earth correction 

%%[C, A] = fit_field_maps(trajectory_all, field_all,N_order)
%disp('HELLO')
%% from fit field map code
for pp=1:numel(trajectory_all(:,1))
    
    % populate a temporary matrix with pure polynomials up to desired order
    for oo=1:(N_order+1)
        temp(oo,1) = trajectory_all(pp,1).^(oo-1);
        temp(oo,2) = trajectory_all(pp,2).^(oo-1);
    end
    
    ii=1;    
    for bb=1:(N_order+1)       
        for aa=1:(N_order+1)          
            if aa+bb<(N_order+3)
                
                A(pp,ii) = temp(aa,1)*temp(bb,2);
                ii=ii+1;   
            end
        end
    end
end

% solving matrix equation...
C = A\field_all;



           
    %figure; imagesc(field_map)     

