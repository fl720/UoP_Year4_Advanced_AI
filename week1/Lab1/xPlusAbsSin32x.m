function f = xPlusAbsSin32x
x = 0: 0.005: pi;
  f = x + abs(sin(32*x));
figure;
plot(x,f); 
title('f(x)= x + abs(sin(32x))');
end
