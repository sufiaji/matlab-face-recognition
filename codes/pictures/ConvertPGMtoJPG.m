for i=1:40
    cd(strcat('s',num2str(i)));
    for j=1:10
        a=imread(strcat(num2str(j),'.pgm'));
        imwrite(a,strcat('R',num2str(i),'-',num2str(j),'.jpg'),'jpg');
    end
    cd ..
end