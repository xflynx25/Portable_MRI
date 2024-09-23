function [slope, offset,yfit] = linefit(x, y, plotresults)


P = polyfit(x,y,1);

    yfit = P(1)*x+P(2);

    slope = P(1);
    offset = P(2);

    if plotresults == 1
        figure; 
        plot(x,y);
    hold on;

    plot(x,yfit,'r-.');
    end

