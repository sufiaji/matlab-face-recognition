function [im_out, acenter, t] = imscan (net,im, parent)
%% the main function of face detection
% parameter inputs:
% 1. net = ANN object
% 2. im = image where face detection  is to be performed
% 3. parent = axes where the image will be displayed
% parameter outputs:
% 1. im_out = result image
% 2. acenter = caenter point coordinate (x,y) where face is detected
% 3. t = elapsed time
tic;
SCAN_FOLDER = 'imscan/';
UT_FOLDER = 'imscan/under-thresh/';
TEMPLATE1 = 'template1.png';      
TEMPLATE2 = 'template2.png';      
Threshold = 0.5;
DEBUG = 0;

warning off;
% create temporary folder, delete the content first
delete ([UT_FOLDER,'*.*']);
delete ([SCAN_FOLDER,'*.*']);
if (DEBUG == 1)
    mkdir (UT_FOLDER);
    mkdir (SCAN_FOLDER);
end

[m n]=size(im);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% First Section: 
% 2D convolution of the image templates
C1 = mminmax(double(im));
C2 = mminmax(double(imread (TEMPLATE1)));
C3 = mminmax(double(imread (TEMPLATE2)));
Corr_1 = double(conv2 (C1,C2,'same'));
Corr_2 = double(conv2 (C1,C3,'same'));
% calculate regional maxima of each convolution to generate initial value for face scanning
Cell.state = int8(imregionalmax(Corr_1) | imregionalmax(Corr_2));
Cell.state(1:13,:)=-1;
Cell.state(end-13:end,:)=-1;
Cell.state(:,1:9)=-1;
Cell.state(:,end-9:end)=-1;
Cell.net = ones(m,n)*-1;
[LUTm LUTn]= find(Cell.state == 1);
% show the photo
imshow(im,'Parent',parent);
hold(parent);%on
clc;
% plot initial value in the same axes (yellow color)
plot(parent,LUTn,LUTm,'.y'); pause(0.001);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Second Section
while (1==1)
	% find cell content where state = 1
    [i j] = find(Cell.state==1,1);
	% no convolution match, means no face
    if isempty(i)
        break;
    end
	% crop image
    imcut = im(i-13:i+13,j-9:j+8);
	% initiate state of cell content to -1
    Cell.state(i,j) = -1;
	% perform ANN-based face detection
    Cell.net(i,j) = sim(net,im2vec(imcut));   
    if Cell.net(i,j) < -0.95
        for u_=i-3:i+3
            for v_=j-3:j+3
                try
                    Cell.state(u_,v_)=-1;
                end
            end
        end 
		% plot (black color)
        plot(parent,j,i,'.k'); pause(0.001);
        continue;
    elseif Cell.net(i,j) < -1*Threshold
		% plot (red color) if less than -threshold
        plot(parent,j,i,'.m'); pause(0.001);
        continue;
    elseif Cell.net(i,j) > 0.95
		% plot (blue color) if more than 0.95
        plot(parent,j,i,'.b'); pause(0.001);
        for u_=i-13:i+13
            for v_=j-9:j+9
                try
                    Cell.state(u_,v_)=-1;
                end
            end
        end
    elseif Cell.net(i,j) > Threshold
		% plot (green color) if more than threshold
        plot(parent,j,i,'.g'); pause(0.001);
    elseif Cell.net(i,j) < Threshold    
		% plot (red color) if less than threshold
        plot(parent,j,i,'.r'); pause(0.001);                        
    end     
	% iterate pixels from -1 to 1 of the center
    for i_=-1:1
        for j_=-1:1
            m_=i+i_;                    
            n_=j+j_;    
			% evaluate state or net of cell
            if (Cell.state(m_,n_) == -1 || Cell.net(m_,n_)~=-1)
                continue;
            end  
			% crop image
            imcut = im(m_-13:m_+13,n_-9:n_+8);
			% perform face detection using ANN
            Cell.net(m_,n_) = sim(net,im2vec(imcut));
            if Cell.net(m_,n_) > 0.95
				% if ANN result less than 0.95
                plot(parent,n_,m_,'.b'); pause(0.001);
                for u_=m_-13:m_+13
                    for v_=n_-9:n_+9
                        try
                            Cell.state(u_,v_)=-1;
                        end
                    end
                end
                continue;
            end           
			% if ANN result more than threshold
            if Cell.net(m_,n_) > Threshold
                Cell.state(m_,n_) = 1;
				% plot (green color)
                plot(parent,n_,m_,'.g'); pause(0.001);
                if (DEBUG == 1)
                    imwrite(imcut,[SCAN_FOLDER,'@',int2str(m_),',',int2str(n_),' (',int2str(fix(Cell.net(m_,n_)*100)),'%).png']);                       
                end
            else % if ANN result less than threshold
                Cell.state(m_,n_) = -1;
				% plot red color
                plot(parent,n_,m_,'.r'); pause(0.001);
                if (DEBUG == 1)
                    imwrite(imcut,[UT_FOLDER,'@',int2str(m_),',',int2str(n_),' (',int2str(fix(Cell.net(m_,n_)*100)),'%).png']);                       
                end
            end  
        end
    end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Third Section
% morphological operation
hold(parent); %off
clc;
% find ANN result more than threshold
xy_ = Cell.net > Threshold;
% regional maxima
xy_ = imregionalmax(xy_);
% perform dilation
xy_ = imdilate (xy_,strel('disk',2,4));
% find connected pixel, return in BW image
[LabelMatrix,nLabel] = bwlabeln(xy_,4);
% find centroid coordinate of all pixels wg=hch have value 1
CentroidMatrix = regionprops(LabelMatrix,'centroid');
xy_ = zeros(m,n);
for i = 1:nLabel
    xy_(fix(CentroidMatrix(i).Centroid(2)),...
           fix(CentroidMatrix(i).Centroid(1))) = 1;
end
acenter = xy_;
% draw rectangular with size 27x18
xy_ = drawrec(xy_,[27 18]);
im_out (:,:,1) = im;
im_out (:,:,2) = im;
im_out (:,:,3) = im;
% return image with green rectangle around the face
for i = 1:m
    for j=1:n
        if xy_(i,j)==1
            im_out (i,j,1)=0;
            im_out (i,j,2)=255;
            im_out (i,j,3)=0;            
        end
    end
end
t = toc;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~