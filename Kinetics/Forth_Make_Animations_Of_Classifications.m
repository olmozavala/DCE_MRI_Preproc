% This file is used to create the animations that show the classification of different files
% and to modify the second DCE-MRI image to take into account the classification

close all;
clear all;
clc;
  
% Loads nifti library
addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');

imagesFolder ='/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};
framesPerSecond = 6;

% This is used to create and display the animations of the classifications
makeAnimations = false;
% This is used to use the classification to enhance the original nifti
makeEnhancement = true;
% This are the weights used for the enhancement
lessionWeight = 1.3;
nonLessionWeight= 0.7;
z = 50; % Z value that is displayed
% Avoid saving the new enhanced nifti file
saveNifti = false;

for i = 1:length(folders)
    % ---------- Loads the classificaiton of this specific case ---------
    display('Reading classified files ...');
    load(strcat(imagesFolder,folders{i},'/ClassifiedPixels'));

    if(makeEnhancement)
        % ---- Loads the second nifti file of the current folder ---
        fprintf('Loading nifti file....\n');
        secondNifti = strcat(imagesFolder,folders{i},'/2.nii');
        nii = load_nii(secondNifti);
        imgData= nii.img;

        % --- Modify the data ----
        % -- If it is classified as a lesion it is multiplied by 1.5, else it is multiplied by 0.5
        fprintf('Modifying data...\n');
        lessionIndex = find(classified == 3);
        nonLessionIndex = find(classified ~= 3);
        %length(lessionIndex)
        %length(nonLessionIndex)
        oldData = imgData;
        imgData(lessionIndex) = imgData(lessionIndex)*lessionWeight;
        imgData(nonLessionIndex) = imgData(nonLessionIndex)*nonLessionWeight;
        maxVal = max(max(max(imgData)))*.9;

        % -------- Creates new nii
        if(saveNifti)
            fprintf('Creating new nifti file....\n');
            newnii = make_nii(imgData, [0.972 0.972 1], [ 0 0 0], 16, '');
            save_nii(newnii, strcat(imagesFolder,folders{i},'/2_enhanced.nii'));
        end

        %--------- Dipplays new and old data --------
        fprintf('Displaying differences...\n');
        sp = figure('Position',[400 200 1600 800]);
        subplot(1,2,1); imshow(oldData(:,:,z),[0 maxVal]);
        title('Before pre-processing');
        subplot(1,2,2); imshow(imgData(:,:,z),[0 maxVal]);
        title('After pre-processing');
        saveas(sp, strcat('EnhancementFigures/',num2str(i)),'png');
        pause(.01);
    end

    if(makeAnimations)
        % -------- Displaying and saving the animation
        display('Making the animation...');
        pause(.1);
        fig = figure('Position',[200 200 400 400]);
        fileName = strcat('Animations/classified_',folders{i}),'.avi';
        aviobj = VideoWriter(fileName);
        aviobj.FrameRate = framesPerSecond;
        open(aviobj);
        hold on
        for frame=1:size(classified,3)
            temp = squeeze(classified(:,end:-1:1,frame));
            % We need to ensure that all the slides have at least one pixel 0,1,2,3 or the images will
            % have different intensities
            temp(1) = 0; temp(2) = 1; temp(3) = 2; temp(4) = 3;
            test =  mat2gray(temp);
            imshow(test);
            writeVideo(aviobj,test);
            pause(.01);
        end
        close(aviobj);
    end
end
