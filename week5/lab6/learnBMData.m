Data = BMData
IN = Data(:,1:2)' 		% transposed
TARGET = Data(:,3)'		% transposed
plotpv(IN, TARGET)
net = perceptron('hardlim','learnp'); % xxxx
net = configure(net,IN,TARGET);
hold on
linehandle = plotpc(net.IW{1},net.b{1});
e = 1;
count = 0;
while (sse(e)) % Sum squared error performance function
disp(strcat('The perceptron classification squared error before adaptation ', num2str(count), ' is: ', num2str(sse(e)), '.'));
   [net,Y,e] = adapt(net,IN,TARGET); % Adapt the neural network ‘net’
   linehandle = plotpc(net.IW{1},net.b{1},linehandle);
   drawnow;
 count = count + 1;
   pause(0.5) % pause between perceptron adaptations in miliseconds
end
disp(strcat('The final perceptron classification squared error is: ',    num2str(sse(e)),' after: ', num2str(count), ' adaptations.'));

