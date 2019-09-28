%% CREATE ARTIFICIAL NEURAL NETWORK
net = network;
% number of input = 1 node
net.numInputs = 1;
% number of layer = 2 node
net.numLayers = 2;
% initialize bias
net.biasConnect = [1;1];
% configure layer connector
net.inputConnect = [1 ;...
                    0 ];
net.layerConnect = [0 0 ;...
                    1 0 ];                
net.outputConnect = [0 1];                
net.targetConnect = [0 1];
% initialize array for input 
netInputs = ones (2160,2);
netInputs (1:2160,1)= -1;
net.inputs{1}.range = netInputs;
% initialize layers, 
net.layers{1}.size = 100;
net.layers{2}.size = 1;
% give transfer function for each neuron (node)
net.layers{1:2}.transferFcn = 'tansig';
net.layers{1:2}.initFcn = 'initnw';
% initialize input for each neuron
net.initFcn = 'initlay';
% configure training
net.performFcn = 'msereg';
net.trainFcn = 'trainscg';
% initialize network
net = init(net);
% save configured ANN
save net net