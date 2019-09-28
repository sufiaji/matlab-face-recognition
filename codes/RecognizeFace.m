% FACE RECOGNITION FUNCTION
% First takes the last selected image
% Calls the images from database
% Applies PCA to images
% Compares the last selected image with database images and says if it is
% found at the database or not.
% Return Values: =================================================
% % % if found=1 & id>0 -> face identified
% % % if found=0 & id>0 -> face unidentified but similar face exist
% % % if found=0 & id=0 -> error

function [found id] = RecognizeFace(img)
id = 0;
found = 0;
try    
    img2 = double(img(:));
    if(exist('fdata.dat') == 2)        
        load('fdata.dat','-mat');
        % declare temporary var to hold image data
        mtr = zeros(size(data{1,1},1),fnumber);
        for ii = 1:fnumber
            % Calling the images from database
            mtr(:,ii) = double(data{ii,1}); 
            % normalize the color of face image
            mtr2 = double(mtr)/255;
            % taking the average of the face image
            avr = mean(mtr2')';
            % for all face images
            % calculate the differences of each face image and average image
            for i = 1:fnumber 
                mtr2(:,i) = mtr2(:,i) - avr;  
            end
        end
        % Obtaining the L matrix
        Lmat = mtr2'*mtr2; 
        % Eigen values(D) and eigenvectors(V) of the L matrix
        [V,D] = eig(Lmat);       
        % obtaining eigenfaces 
        V = mtr2*V*(abs(D))^-0.5 ;        %This line is taken from the software karhunenloeve.m
             %Available at
                                  %http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6995&objectType=file
                                  %Author:Alex Chirokov
                                  
        % feature vector of the new image
        f1 = V'*(img2-avr) ;           
        fdata = zeros(max_class,max_class); %empty matrice
        for ii = 1:fnumber
            imdata = double(data{ii,1});
            classdata = data{ii,2};
            cor = V'*(imdata-avr); % weight vector of the stored faces
            fdata(:,classdata) = fdata(:,classdata)+cor;
        end
        dist = zeros(max_class,1);
        % feature eigen minus original data
        for ii = 1:(max_class)
            dist(ii) = norm(f1-fdata(:,ii));            
        end      
        [minf,pminf] = min(dist);
        k = minf/1000;
%         hll = waitbar(0,'CHECKING THE DATABASE...');
%         close(hll)
        if k <= 6.1
%             disp(strcat('The corresponding ID number of the face is --> ',num2str(pminf)));            
            id = pminf;
            found = 1;
%             [name sname ph] = ldinfo(id);
            return
        end
        if k>=6.1
%             disp('The corresponding face does not exist at your database')
%             disp('Note: Save more pictures to the group for the best recognition')
%             disp(strcat('The similar of this face has an ID, number--> ',num2str(pminf)));
%             ldinfo
            found = 0;
            id = pminf;
            return
        end
    else        
%         disp('IMAGE PROCESSING IS NOT AVAILABLE')
%         disp('*********************************')
%         disp('Possible Reasons:                ')
%         disp(' ')
%         disp('1- Database is empty')
%         disp('2- The size of the selected image is not suitable for processing')
%         disp('3- The color or format is not matching with database')
%         disp(' ')
        found = 0;
        id = 0;
    end
catch  me
    disp(me.message);
%     clc
%     disp(' ')
%     disp('NO FACE HAS BEEN SELECTED!!')
%     pause
%     clear all
%     bdrfacerec
end

    