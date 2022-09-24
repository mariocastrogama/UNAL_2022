clc
clear;
close all;
fclose all;

po = [28, 10, 8/3];
[to, yo] = mylorenz(po);


p1 = [28, 10, 3.0];
[t1, y1] = mylorenz(p1);

figure(1)
subplot(2,1,1)
plot(to,yo)
legend('x','y','z')
ylabel('Lorenz original')

subplot(2,1,2)
plot(t1,y1)
legend('x','y','z')
ylabel('Lorenz slightly modified')