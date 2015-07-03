close all;
clear all;
clc;

addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
addpath('/home/olmozavala/Dropbox/TestImages/nifti/RealExample1');

fileName = '1.nii';
%fileName = 'subtract.nii';

% We are going to show some of the uses of the library 
[header, ext, filetype, machine] = load_untouch_header_only(fileName);

% Displays some important info from the file
dims = header.dime.dim

% Loading the image
nii = load_nii(fileName);

imgData= nii.img;


% Create curve for specific point in the image
folder  = '/home/olmozavala/Dropbox/TestImages/nifti/RealExample1/'

totImages = 5;
% FROM IMAGE WE CHANGE X-y and Y-x because images are flipped
x = 264
y = 257
z = 56
nnsize = 10;
visualize = 1;

% To visuazlie the data
opt.setviewpoint = [x y z];
view_nii(nii, opt);

figure 
fixedImage = imgData;
imshow(fixedImage(:,end:-1:1,z)',[0 1500]);
pause(.4);

curve = zeros(1,totImages);
figure 
for i=1:totImages
    fileName = strcat(folder,num2str(i),'.nii');
    % Loading the image
    nii = load_nii(fileName);

    if(visualize)
        vissize = 2*nnsize;
        imgData= nii.img;
        sample = imgData(x-vissize:x+vissize,y-vissize:y+vissize,:);
        imshow(sample(:,end:-1:1,z)',[0 1500]);
        pause(.4);
    end
    curve(i) = mean(mean(mean(imgData(x-nnsize:x+nnsize,y-nnsize:y+nnsize,z-nnsize:z+nnsize))));
end

figure
plot(curve,'-*');
