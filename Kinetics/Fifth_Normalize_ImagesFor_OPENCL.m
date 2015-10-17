% This file is used to create the animations that show the classification of different files
% and to modify the second DCE-MRI image to take into account the classification
function makeAnimationsAndEnhanceImage()

close all;
clear all;
clc;

% Loads nifti library
addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_CreateNifti/External_Tools/');
imagesFolder ='/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
% These are the training 
folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok', '3107404_p7_ok', '4030560_p10_ok', '2004235_p9_ok'};

displayImages = false;
z = 40;

xfrom = 128;
xto = 319;

zfrom = 2;
zto = 129;

for classifier=1:2% 1 For Dec Trees, 2 for NB
    for i = 1:length(folders)
        % ---------- Loads the classificaiton of this specific case ---------
            % ---- Loads the second nifti file of the current folder ---
            fprintf('Loading nifti file....\n');
            if(classifier == 1)% NB classifier
                secondNifti = strcat(imagesFolder,folders{i},'/2_enhanced.nii');
            else
                secondNifti = strcat(imagesFolder,folders{i},'/2_enhancedNB.nii');
            end
            nii = load_nii(secondNifti);
            imgData= nii.img;

            maxVal = max(max(max(imgData)));
            ysize = size(imgData,1);

            normData = imgData(:,xfrom:xto,zfrom:zto)./maxVal;
            % New image sizes
            %size(normData)

            fprintf('Creating new nifti file....\n');
            newnii = make_nii(normData, [0.972 0.972 1], [ 0 0 0], 16, '');

            if(displayImages)
                figure
                %view_nii(newnii);
                subplot(1,2,1); imshow(imgData(:,end:-1:1,z)',[0 maxVal]);
                subplot(1,2,2); imshow(normData(:,end:-1:1,z)',[0 1]);
            end

            % -------- Creates new nii
            if(classifier == 1)% NB classifier
                save_nii(newnii, strcat(imagesFolder,folders{i},'/2_enhancedNB_norm.nii'));
            else
                save_nii(newnii, strcat(imagesFolder,folders{i},'/2_enhanced_norm.nii'));
            end
    end
end
