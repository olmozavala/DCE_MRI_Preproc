% Classifier can be RT (Regression trees) or NB (Naive Bayes)
% Optimizer can be grad (Gradient Descent) or evol (Evolutionary algorithm) 
function enhanced = oz_imageenhance(classified, niftis, imagesFolder, classifier,z)
    lessionWeight = 1.3;
    nonLessionWeight= 0.7;

    % Reading the classifers 
    load('NBClassifier.mat');
    load('RTClassifier.mat');

    % ======================== Read and Classify images ==========================================
    addpath(imagesFolder);
    
    % ---- Loads the second nifti  ---
    imgData = squeeze(niftis(2,:));

    % --- Modify the data ----
    % -- If it is classified as a lesion it is multiplied by 1.5, else it is multiplied by 0.5
    fprintf('Modifying data...\n');
    lessionIndex = find(classified == 3);
    nonLessionIndex = find(classified ~= 3);
    oldData = imgData;
    imgData(lessionIndex) = imgData(lessionIndex)*lessionWeight;
    imgData(nonLessionIndex) = imgData(nonLessionIndex)*nonLessionWeight;
    maxVal = max(max(max(oldData)))*.9;

    dims = size(niftis);
    enhanced = reshape(imgData,[dims(2),dims(3),dims(4)]);

    % -------- Creates new nii enhanced one
    fprintf('Creating new nifti file....\n');
    newnii = make_nii(enhanced, [0.972 0.972 1], [ 0 0 0], 16, '');
    if(classifier == 'RT')% NB classifier
        save_nii(newnii, strcat(imagesFolder,'2_enhancedRT.nii'));
    else
        save_nii(newnii, strcat(imagesFolder,'2_enhancedNB.nii'));
    end

end

% This function classifies a DCE-MRI image using one classifier
function result = ClassifyOZ(niftis, nb)
    % Iterate over the images
    dims = size(niftis);
    totPixelsPerVolume = dims(2)*dims(3)*dims(4);
    totNumberOfFiles = dims(1);
    numAttribs = 13;
    curveMatrix = zeros(totPixelsPerVolume,numAttribs);

    % Fill the curves with the intensity values
    display('Filling matrix with kinetic values....')
    for i=1:totNumberOfFiles
        curveMatrix(:,i) = squeeze(niftis(i,:));
    end

    display('Computing slopes of kinetic info....')
    %------------------ Compute slopes -------------
    curveMatrix(:,6) = curveMatrix(:,2) - curveMatrix(:,1);
    curveMatrix(:,7) = curveMatrix(:,3) - curveMatrix(:,2);
    curveMatrix(:,8) = curveMatrix(:,4) - curveMatrix(:,3);
    curveMatrix(:,9) = curveMatrix(:,5) - curveMatrix(:,4);

    %------------------ Compute mean -------------
    display('Computing mean of kinetic info....')
    curveMatrix(:,10) = mean( curveMatrix(:,1:5),2 );

    %------------------ Compute time to peak -------------
    display('Computing time to peak....')
    [del curveMatrix(:,11)] = max( curveMatrix(:,1:5)');

    %------------------ Compute time of max slope -------------
    [del curveMatrix(:,12)] = max( curveMatrix(:,6:9)');

    %------------------ No 'sharp' decrease -------------
    curveMatrix(:,13) = min( (curveMatrix(:,6:9) > -5)')';

    % --------- Evaluate the classifier ---------
    display('Classifying the features matrix....')
    result = predict(nb,curveMatrix);
    result = reshape(result,[dims(2),dims(3),dims(4)]);
end
