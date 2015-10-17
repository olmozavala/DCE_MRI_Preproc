function PreProcessingDCE_MRI()
    close all;
    clear all;
    clc;

    matlabpool close force 'local'
    matlabpool open 4 
    folders = {'3107404_p7_ok' '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};
    %folderId = 1;

    for folderId = 1:length(folders)
        addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_CreateNifti/External_Tools/');

        % From which images are we going to do the preprocessing
        imagesFolder = strcat('/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/',folders{folderId},'/');
        optimizer = 'grad'; % grad or evol
        classifier = 'NB'; % RT or NB
        z = 87; % Z level to show in every step 

        % Read post-contrast image 1 and display 

    %    for i=1:5
    %        tempNii = load_nii(strcat(imagesFolder,num2str(i),'.nii'));
    %        preNii = tempNii.img; % Pre
    %        subplot(1,5,i); showNii(preNii,z);
    %    end
        tempNii = load_nii(strcat(imagesFolder,'1.nii'));
        preNii = tempNii.img; % Pre
        tempNii = load_nii(strcat(imagesFolder,'2.nii'));
        origPostNii = tempNii.img;
        showNii(origPostNii,z);
        %view_nii(tempNii);

        %% ========================== Registration ==========================================

        % Read post-contrast image 1 registered and show comparison with not registered one
        if(optimizer == 'grad')
            file = strcat(imagesFolder,'Reg_2.nii')
        else
            file = strcat(imagesFolder,'Reg_Evol_2.nii')
        end
        if(not(exist(file)))
            display('Making registration....');
            oz_registration(imagesFolder,'grad');
        else
            display('Loading previous registration....');
            tempNii = load_nii(file);
        end

        regNii = tempNii.img;
        display('Visualizing registration results ....');
        visualizedisparity( preNii, origPostNii, regNii, z);


        %% ========================== Classification ==========================================

        % Making the classification and enhancement of the images
        display('Making classification ....');

        if(classifier == 'RT')
            file = strcat(imagesFolder,'ClassifiedPixelsRT.mat')
        else
            file = strcat(imagesFolder,'ClassifiedPixelsNB.mat')
        end

        if(not(exist(file)))
            fprintf('\nReading nifti files for: %s ... \n',imagesFolder);
            niftis = readNifti(imagesFolder, optimizer);
            classified = oz_imageclassify(niftis, imagesFolder, optimizer, classifier,z);
        else
            display('Loading previous classification ....');
            load(file)
        end

        % Show classification of the image
        display('Visualizing classification results....');
        classifiedViz = classified + 1;%It doesn't take into account the 0
        colors = [0 0 .25;
        .29 .56 .29;
        .72 .73 .30;
        .79  .1 .1 ];

        figure
        imshow(classifiedViz(:,:,z)', colors);

        %% ========================== Enhancement ==========================================

        display('Making enhancement....');

        if(classifier == 'RT')
            file = strcat(imagesFolder,'2_enhancedRT.nii');
        else
            file = strcat(imagesFolder,'2_enhancedNB.nii');
        end

        if(not(exist(file)))
            if(not(exist('niftis')))
                fprintf('\nReading nifti files for: %s ... \n',imagesFolder);
                niftis = readNifti(imagesFolder, optimizer);
            end
            enhanced = oz_imageenhance(classified, niftis, imagesFolder, classifier,z);
        else
            display('Loading previous classification ....');
            enhancedNii = load_nii(file);
            enhanced= enhancedNii.img;
        end

        % Read and show enhanced image
        display('Visualizng enhanced image....');
        figure
        subplot(1,2,1); showNii(origPostNii,z);
        subplot(1,2,2); showNii(enhanced,z);

        %% ========================== Normalization ==========================================
        fprintf('Creating normalized and reduced size files...');

        if(classifier == 'RT')
            file = strcat(imagesFolder,'2_enhancedRT.nii');
        else
            file = strcat(imagesFolder,'2_enhancedNB.nii');
        end

        if(not(exist(file)))
            if(not(exist('niftis')))
                fprintf('\nReading nifti files for: %s ... \n',imagesFolder);
                niftis = readNifti(imagesFolder, optimizer);
            end
            enhanced = oz_imageenhance(classified, niftis, imagesFolder, classifier,z);
        else
            display('Loading previous classification ....');
            enhancedNii = load_nii(file);
            enhanced= enhancedNii.img;
        end
        oz_normalize(imagesFolder,classifier);

        fprintf('DONE!!!!');
    end %For of folder

end

%%%%%%%%%%%%%%%%%%%%%  used to visualize the disparity between the images %%%%%%%%%%%%%%%%%%%%%  
function visualizedisparity(base, orig, regis, z )
    figure
    subplot(1,2,1); imshowpair(base(:,:,z)', orig(:,:,z)');
    subplot(1,2,2); imshowpair(base(:,:,z)', regis(:,:,z)');
    %subplot(1,2,2);  showNii(regis,z);

end

% This function is used to read 5 nifti files for each imagesFolder
function niftis = readNifti(imagesFolder, optimizer)

    fileName = strcat(imagesFolder,'1.nii');
    nii = load_nii(fileName);
    % We smooth the image with gaussian blur
    niftis(1,:,:,:) = smooth3(nii.img);

    for i=2:5
        if(optimizer == 'grad')
            fileName = strcat(imagesFolder,'Reg_',num2str(i),'.nii');
        else
            fileName = strcat(imagesFolder,'Reg_Evol',num2str(i),'.nii');
        end
        nii = load_nii(fileName);
        % We smooth the image with gaussian blur
        niftis(i,:,:,:) = smooth3(nii.img);
    end
end


