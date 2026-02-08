function ff= fun_with_noise 
 a = 0:0.01:2*pi;  
 b = a.^2;  
 c = a.^3;  
 d = a.^4;  
 e = sin(a);  
 f = 0.05*randn(size(a));
 plot(a,f);% will plot the noise f(a)
 (hold);
 plot(a,e+f);% will plot sin(a) with noise
 title('Function sin() with noise f(a)');
end
