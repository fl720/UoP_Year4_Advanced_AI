Data = load('perceptronData3.txt')
IN = Data(:,1:3)'
TARGET = Data(:,4)' 
plotpv(IN, TARGET) 
net2 = perceptron('hardlim','learnpn');
net2 = configure(net2,IN,TARGET);
hold on
linehandle = plotpc(net2.IW{1},net2.b{1});
e = 1;
while (sse(e))
   [net2,Y,e] = adapt(net2,IN,TARGET);
   linehandle = plotpc(net2.IW{1},net2.b{1},linehandle);
   drawnow;
end
