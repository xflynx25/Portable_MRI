function  [] = plotnmr( x, datain )

% figure; 
if nargin == 1
plot(squeeze(abs(x)),'-b'); hold on; 
plot(squeeze(real(x)),'-r'); hold on; 
plot(squeeze(imag(x)),'-g');

else 
   plot(x,squeeze(abs(datain)),'-b'); hold on; 
plot(x,squeeze(real(datain)),'-r'); hold on; 
plot(x,squeeze(imag(datain)),'-g');
end 