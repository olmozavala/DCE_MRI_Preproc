% This file is used to create the animations that show the classification of different files
% and to modify the second DCE-MRI image to take into account the classification
function makeAnimationsAndEnhanceImage()

close all;
clear all;
clc;
applyClassifier(1);%This correspond to the NaiveBayes classifier
close all;
clear all;
clc;
applyClassifier(2);%This correspond to the Regression Tree classifier

function applyClassifier(classifier)


    % Loads nifti library
    addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_CreateNifti/External_Tools');
    imagesFolder ='/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
    % These are the training 
    folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};
    %folders={ '3107404_p7_ok', '4030560_p10_ok', '2004235_p9_ok'};
    framesPerSecond = 6;

    % This is used to create and display the animations of the classifications
    makeAnimations = false;
    % This is used to use the classification to enhance the original nifti
    makeEnhancement = true;
    % Avoid saving the new enhanced nifti file
    saveNifti = false;
    % This are the weights used for the enhancement
    lessionWeight = 1.3;
    nonLessionWeight= 0.7;
    z = 50; % Z value that is displayed

    for i = 1:length(folders)
        % ---------- Loads the classificaiton of this specific case ---------
        display('Reading classified files ...');
        if(classifier == 1)
            load(strcat(imagesFolder,folders{i},'/ClassifiedPixelsNB'));
        else
            load(strcat(imagesFolder,folders{i},'/ClassifiedPixels'));
        end

        if(makeEnhancement )
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
            maxVal = max(max(max(oldData)))*.9;

            % -------- Creates new nii
            if(saveNifti)
                fprintf('Creating new nifti file....\n');
                newnii = make_nii(imgData, [0.972 0.972 1], [ 0 0 0], 16, '');
                if(classifier == 1)% NB classifier
                    save_nii(newnii, strcat(imagesFolder,folders{i},'/2_enhancedNB.nii'));
                else
                    save_nii(newnii, strcat(imagesFolder,folders{i},'/2_enhanced.nii'));
                end
            end

            %--------- Dipplays new and old data --------
            fprintf('Displaying differences...\n');
            sp = figure('Position',[400 200 700 800]);
            subplot(1,2,1); imshow(oldData(:,end:-1:1,z)',[0 maxVal]);
            title('Before pre-processing');
            subplot(1,2,2); imshow(imgData(:,end:-1:1,z)',[0 maxVal]);
            title('After pre-processing');
            if(classifier == 1)% NB classifier
                saveas(sp, strcat('EnhancementFigures/NB',num2str(i)),'png');
                print(sp, strcat('EnhancementFigures/NBPrint',num2str(i)),'-dpng');
            else
                saveas(sp, strcat('EnhancementFigures/',num2str(i)),'png');
                print(sp, strcat('EnhancementFigures/Print',num2str(i)),'-dpng');
            end

            % Saving just the post-process image for test with the segmentation in 2D
            singleImg = single((squeeze(imgData(:,end:-1:1,z)')));
            maxVal = single(maxVal);
            if(classifier == 1)% NB classifier
                imwrite( singleImg./maxVal ,strcat('EnhancementFigures/SingleNB',num2str(i),'.png'));
            else
                imwrite( singleImg./maxVal ,strcat('EnhancementFigures/SingleRT',num2str(i),'.png'));
            end
            pause(.01);
        end

        if(makeAnimations)
            % -------- Displaying and saving the animation
            display('Making the animation...');
            pause(.1);
            fig = figure('Position',[200 200 400 400]);
            if(classifier == 1)% NB classifier
                fileName = strcat('Animations/classified_nb_',folders{i}),'.avi';
            else
                fileName = strcat('Animations/classified_',folders{i}),'.avi';
            end
            aviobj = VideoWriter(fileName);
            aviobj.FrameRate = framesPerSecond;
            open(aviobj);
            hold on

            %Colors for each of the classes, 0 is white
            
            %color = [
            %        [0 0 0];
            %        [1 1 0];
            %        [0 1 0];
            %        [1 0 0]; ];

            color = [
                    [0 0 .2];
                    [.3 .3 0];
                    [0 .2 0];
                    [.5 0 0]; ];


            classified = classified + 1;
            for frame=1:size(classified,3)
                temp = squeeze(classified(:,end:-1:1,frame));
                % We need to ensure that all the slides have at least one pixel 0,1,2,3 or the images will
                % have different intensities, we assign specifc values to the first four pixels of the whole image
                temp(1) = 1; temp(2) = 2; temp(3) = 3; temp(4) = 4;
                %test =  mat2gray(temp);
                test =  label2rgb(temp,color);
                imshow(test);
                writeVideo(aviobj,test);
                pause(.01);
            end
            close(aviobj);
        end
    end
