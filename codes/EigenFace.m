function EigenFace
%% function to display mean and eigen faces of all faces stored in database
%displays eigenfaces and the mean face if the database is not EMPTY
%partially taken from the software karhunenloeve.m
%Author:Alex Chirokov
%Available at
%http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=6995&objectType=file

% create empty cell array for eigen face
imgEigenMean = {[]};
% load database if exist
if(exist('fdata.dat')==2)
    try
        load('fdata.dat','-mat');
        % initialize array for mean face
        matrice = zeros(size(data{1,1},1),fnumber);
        % calculate mean face
        for ii = 1:fnumber
            matrice(:,ii) = double(data{ii,1});
            imsize = [250 250];
            nPixels = imsize(1)*imsize(2);
            matrice2 = double(matrice)/255;
            avrgx = mean(matrice2')';
            for i = 1:fnumber 
                matrice2(:,i) = matrice2(:,i) - avrgx;
            end
        end
        % calculate eigen face
        imgEigenMean{1} = reshape(avrgx, imsize);
        cov_mat = matrice2'*matrice2;
        [V,D] = eig(cov_mat); 
        V = matrice2*V*(abs(D))^-0.5;
        for ii = 1:fnumber
            imgEigenMean{1+ii} = ScaleImage(reshape(V(:,ii),imsize));
        end
		% plot the face in a new GUI
		% parse the Eigen data to the GUI
        gui_eigen('UserData',imgEigenMean);
    catch me
        e = errordlg(me.message,'Face Recognition');
        uiwait(e);
    end
else
    w = warndlg('Corresponding face database not found !','Face Recognition');
    uiwait(w);
end
    
