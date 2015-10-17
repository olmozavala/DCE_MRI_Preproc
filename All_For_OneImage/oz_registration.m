%% This function makes the registration of the DCE-Images with 5 images
% Registration algorithm to use  'grad' for Gradient Descent and 'evol' for genetic algorithm
function oz_registration(imagesRootFolder, optimizer)

    addpath(imagesRootFolder);

    % Iterate over folders
    folder = imagesRootFolder

    % Save the first image as the one 'fixed' one to use for the registration
    fileName = strcat(folder,'1.nii');

    % Loading the data 
    display(strcat('Loading first file: ',fileName));
    nii = load_nii(fileName);
    imgData= nii.img;
    fixedImage = imgData;
    fixedImageNorm = fixedImage;

    if(optimizer == 'evol')
        OPTIMIZER = registration.optimizer.OnePlusOneEvolutionary;
        METRIC = registration.metric.MattesMutualInformation;
    else
        %[OPTIMIZER, METRIC] = imregconfig('multimodal');
        [OPTIMIZER, METRIC] = imregconfig('monomodal');
    end

    totImages = 5
    % Iterate over the rest of the images that will be register
    for i=2:totImages
        fileName = strcat(folder,num2str(i),'.nii');

        % Loading the image
        display(strcat('Loading file: ',fileName));
        nii = load_nii(fileName);

        imgData= nii.img;
        % Remove chest regions to reduce image size
        imgData = imgData;

        % ----- Normalizes the image using the origina histogram
        imgDataNorm = imgData;

        % ------------------- Apply the registration ------------
        display('doing registration ....');
        tform = imregtform(imgDataNorm, fixedImageNorm, 'affine', OPTIMIZER, METRIC);
        display('Done!');

        % -------- Applying transformation ans visualizing
        display('Applying transformation matrix...');
        regVolume = imwarp(imgDataNorm,tform,'OutputView',imref3d(size(fixedImageNorm)));

        % Saving the 'registered' volume 
        display('Saving registered volume..');
        newnii = make_nii(regVolume, [0.972 0.972 1], [ 0 0 0], 16, '');
        if(optimizer == 'evol')
            save_nii(newnii, strcat(folder,'/Reg_Evol_',num2str(i),'.nii'));
        else
            save_nii(newnii, strcat(folder,'/Reg_',num2str(i),'.nii'));
        end
    end
