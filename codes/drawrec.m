% Version : 5.3
% Date : 12.01.2010
% Author  : Omid Bonakdar Sakhi

function out = drawrec (in,w)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function will draw a 27x18 rectangle 
% Inputs are an image 'in' abd w is a binary image same size as the input
% image , in the binary image each 1 is the center of a rectangle and the
% function leaves zeros alone.

[m n]=size(in);
% find the center of face (pixel value = 1)
[LUTm LUTn]=find(in);
out = zeros (m,n);
% draw rectangle around the center of face
for i =1:size(LUTm,1)
    try 
        out (LUTm(i),LUTn(i))=0;
    end
    try 
        out (LUTm(i)-14:LUTm(i)+13,LUTn(i)-9)=1;
    end
    try 
        out (LUTm(i)-14:LUTm(i)+13,LUTn(i)+8)=1;
    end
    try 
        out (LUTm(i)-14,LUTn(i)-9:LUTn(i)+8)=1;
    end
    try 
        out (LUTm(i)+13,LUTn(i)-9:LUTn(i)+8)=1;
    end
end