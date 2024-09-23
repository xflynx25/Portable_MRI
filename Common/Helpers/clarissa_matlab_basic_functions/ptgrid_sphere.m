function XYZsphere = ptgrid_sphere(Xvec)

X = Xvec;
Y = Xvec;
Z = Xvec;
Xn = numel(X);
Xline = [X; zeros(1,numel(X));zeros(1,Xn)];
XYgrid = repmat(Xline, [1,numel(Y)]);
for ii = 1:Xn
    XYgrid(2,[(ii-1)*Xn+1:ii*Xn]) = ones(1,Xn)*Y(ii);
end
    


XYn = size(XYgrid,2);
XYZgrid = repmat(XYgrid, [1,Xn]);
for ii = 1:Xn
    XYZgrid(3,[(ii-1)*XYn+1:ii*XYn]) = ones(1,XYn)*Z(ii);
end
    



grid_norm = sqrt(XYZgrid(1,:).^2 + XYZgrid(2,:).^2 + XYZgrid(3,:).^2);
I = grid_norm <= 0.1;
XYZsphere = XYZgrid(:,I).';