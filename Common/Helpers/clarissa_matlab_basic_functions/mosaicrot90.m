function Anew2 = mosaicrot90(A, n, m)
% figure;

% n = 6; m = 8; A= temp;
Anew = zeros(size(A,1)+2,size(A,2)+2, size(A,3));

for nn = 1:size(A,3)
Anew(2:end-1,2:end-1,nn) = A(:,:,nn);
% subplot(n,m,nn);
% imagesc(Anew(:,:,nn));
end

N = size(Anew,2);   M = size(Anew,1);

Anew2 = zeros(N*n, M*m);

count = 1;
for nn = 1:n
    for mm = 1:m
        if count <= size(Anew,3)
  Anew2(1+N*(nn-1):N*nn,1+M*(mm-1):M*mm)  = rot90(Anew(:,:,count));
  count = count+1;
        end
    end
end


imagesc(Anew2); axis tight; colormap gray;
%  axis square;