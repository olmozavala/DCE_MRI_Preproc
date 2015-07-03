%% This function makes the registration of the DCE-Images with 5 images
function oz_registration()
close all;
clear all;
clc;

matlabpool close force 'local'
matlabpool open 4

imagesRootFolder = '/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
addpath(imagesRootFolder);

folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};

totImages = 5; % Total number of images for each DCE-MRI session

% Removing chest regions to reduce image size
ROI_start = 190;
ROI_end = 320;
z = 56;% Which z slice will be shown in the figures

%optimizer = 'evol';
% Registration algorithm to use  'grad' for Gradient Descent and 'evol' for genetic algorithm
optimizer = 'grad'; 

% Iterate over folders
for f = 1:length(folders)
    folder = strcat(imagesRootFolder,folders{f},'/');

    display(strcat('Registration for folder: ',folders{f}));
    % Save the first image as the one 'fixed' one to use for the registration
    fileName = strcat(folder,'1.nii');

    % Loading the data 
    display(strcat('Loading first file: ',fileName));
    nii = load_nii(fileName);
    imgData= nii.img;
    fixedImage = imgData(:,ROI_end:-1:ROI_start,:);
    fixedImageNorm = fixedImage;

    % Iterate over the rest of the images that will be register
    for i=2:totImages
        fileName = strcat(folder,num2str(i),'.nii');

        % Loading the image
        display(strcat('Loading file: ',fileName));
        nii = load_nii(fileName);

        % we select the best 'intensity-based' registration algorithm for our problem
        if( i == 2)
            if(optimizer == 'evol')
                OPTIMIZER = registration.optimizer.OnePlusOneEvolutionary;
                METRIC = registration.metric.MattesMutualInformation;
            else
                %[OPTIMIZER, METRIC] = imregconfig('multimodal');
                [OPTIMIZER, METRIC] = imregconfig('monomodal');
            end
        end

        imgData= nii.img;
        % Remove chest regions to reduce image size
        imgData = imgData(:,ROI_end:-1:ROI_start,:);

        % ----- Normalizes the image using the origina histogram
        %imgDataNorm = oz_norm(imgData);
        imgDataNorm = imgData;

        % ------------------- Apply the registration ------------
        display('doing registration ....');
        %tform = imregtform(imgDataNorm, fixedImageNorm, 'affine', OPTIMIZER, METRIC,'DisplayOptimization',true);
        tform = imregtform(imgDataNorm, fixedImageNorm, 'affine', OPTIMIZER, METRIC);
        display('Done!');

        % ------------ Saving transforamtion matrix ---------
        % This variable stores the final matrix transormations
        display('Saving transformation matrix...');
        if(optimizer == 'evol')
            save(strcat(folder,'/TransfMatricesEvol_',num2str(i)), 'tform');
        else
            save(strcat(folder,'/TrasformMatrix_',num2str(i)), 'tform');
        end

        % -------- Applying transformation ans visualizing
        display('Applying transformation matrix...');
        regVolume = imwarp(imgDataNorm,tform,'OutputView',imref3d(size(fixedImageNorm)));

        % Used to compare the intensity color of the images
        display('Displaying images normalized vs not normalized...');
        figure
        imshowpair(fixedImageNorm(:,:,z), imgDataNorm(:,:,z));
        pause(.1);
        hold on;
        imshowpair(fixedImageNorm(:,:,z), regVolume(:,:,z));
        pause(.1);

        % Saving the 'registered' volume 
        display('Saving registered volume..');
        newnii = make_nii(regVolume, [0.972 0.972 1], [ 0 0 0], 16, '');
        if(optimizer == 'evol')
            save_nii(newnii, strcat(folder,'/Reg_Evol_',num2str(i),'.nii'));
        else
            save_nii(newnii, strcat(folder,'/Reg_',num2str(i),'.nii'));
        end
    end
end

function [normalized] = oz_norm(img, bins, inHist)
    bins = 500
    zsize = size(img,3);% Get the z dimension of the image
    normalized = zeros(size(img));

    for z=1:zsize
        normalized(:,:,z) = histeq(img(:,:,z), imhist(img(:,:,z),bins));
        display('------------');
        max(max(img(:,:,z)))
        max(max(normalized(:,:,z)))
        imshow(img(:,:,z),[0 3500]);
        hold on;
        pause(.1);
        imshow(normalized(:,:,z),[0 1]);
        pause(.1);
        hold off;
    end

