function I = findpt(xvec, pt)


if numel(pt) ==1
[Y,I] = min(abs(pt-xvec)); 

else
    for nn = 1:numel(pt)
        [Y,I(nn)] = min(abs(pt(nn)-xvec)); 
    end

end