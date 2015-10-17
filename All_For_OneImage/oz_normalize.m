% This file is used to create the animations that show the classification of different files
% and to modify the second DCE-MRI image to take into account the classification
function oz_normalize(imagesFolder,classifier)

    if(classifier == 'NB')% NB classifier
        secondNifti = strcat(imagesFolder,'2_enhancedNB.nii');
    else
        secondNifti = strcat(imagesFolder,'2_enhancedRT.nii');
    end

    nii = load_nii(secondNifti);
    normData= nii.img;
    maxVal = max(max(max(normData)));
    normData= normData/maxVal;

    fprintf('Creating new nifti file normalized....\n');
    newnii = make_nii(normData, [0.972 0.972 1], [ 0 0 0], 16, '');

    % -------- Creates new nii
    if(classifier == 'NB')% NB classifier
        save_nii(newnii, strcat(imagesFolder,'2_enhancedNB_norm.nii'));
    else
        save_nii(newnii, strcat(imagesFolder,'2_enhancedRT_norm.nii'));
    end

    % Displays some important info from the file
    dims = size(normData);

    dimrows = dims(1);
    dimcols = dims(2);
    dimdepth = dims(3);

    newdimrows = (floor(dimrows/32)*32)/2;
    newdimcols = (floor(dimcols/32)*32)/2;
    newdimdepth =(floor(dimdepth/32)*32)/2;

    redNormData = normData(1:2:newdimrows*2,1:2:newdimcols*2,1:2:newdimdepth*2);
    newnii = make_nii(redNormData, [0.972 0.972 1], [ 0 0 0], 16, '');

    if(classifier == 1)% NB classifier
        save_nii(newnii, strcat(imagesFolder,'2_enhancedNB_normRed.nii'));
    else
        save_nii(newnii, strcat(imagesFolder,'2_enhancedRT_normRed.nii'));
    end
end
