warning off;
% prepare for creating Gabor filter
fprintf ('Creating Gabor Filters ...\n');
% create 5x8 empty cell 
G = cell(5,8);
% initialize cell content: fill each cell with 32x32 zero matrix
for s = 1:5
    for j = 1:8
        G{s,j}=zeros(32,32);
    end
end
% create gabor filter
for s = 1:5
    for j = 1:8
		% call Gabour function (gabor.m)
        G{s,9-j} = gabor([32 32],(s-1),j-1,pi,sqrt(2),pi);
    end
end
% perform fast fourier transform
for s = 1:5
    for j = 1:8        
        G{s,j}=fft2(G{s,j});
    end
end
% save gabor data (G) to gabor.mat
save gabor G
