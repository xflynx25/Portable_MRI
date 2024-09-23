function [slope, offset] = linefit_multi(x, y, plotresults)

for ii = 1:size(y,2)

P = polyfit(x,y(:,ii).',1);

    yfit(:,ii) = P(1)*x+P(2);

    slope(ii) = P(1);
    offset(ii) = P(2);
end

    if plotresults == 1
        figure; 
        plot(y);
    hold on;

    plot(yfit,'r-.');
    end

