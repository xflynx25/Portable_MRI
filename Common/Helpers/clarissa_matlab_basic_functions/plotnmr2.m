function  [] = plotnmr2( x, datain )

% figure; 
plot(x, abs(datain)); hold on; 
plot(x,real(datain)); hold on; 
plot(x, imag(datain));

