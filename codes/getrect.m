function [imcr LUTm LUTn w h] = getrect(in,img,scale,wo,ho)
%% a function to create rectangle around face image with specified width
%% and height
% parameters input: 
% 1. in = binary image where face coordinate is mapped (1 for face, 0 for
% non face)
% 2. img = gray input image
% 3. scale = scale factor
% 4. wo = width of rectangle
% 5. ho = height of rectangle
% parameters output:
% 1. imcr = list of faces (face images array)
% 2. LUTm = array of x coordinate of the center where face found
% 3. LUTn = array of y coordinate of the center where face found
% 4. w = width of rectangle after scaled
% 5. h = height of rectangle after scaled

[LUTm LUTn] = find(in);
LUTm = round(LUTm/scale);
LUTn = round(LUTn/scale);
imcr = cell(1);
w = round(wo*(1/scale));
h = round(ho*(1/scale));  
for i = 1:length(LUTm)
    imcr{i} = imcrop(img,[LUTn(i)-round(w/2) LUTm(i)-round(h/2) w h]);
end
