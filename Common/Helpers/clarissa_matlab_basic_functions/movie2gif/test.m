% A simple example to utilise movie2gif function
clear all

x = 0:0.1:2*pi;
y = sin(x);

figure('Position',[1 1 240 200])
for i = 1:length(x)
    plot(x(1:i),y(1:i), 'r', 'LineWidth',2)
    axis([0 2*pi -1.2 1.2])
    pause(0.1)
    mov(i) = getframe;
end

movie2gif(mov, 'sin.gif')