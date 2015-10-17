
% Classifier can be RT (Regression trees) or NB (Naive Bayes)
% Optimizer can be grad (Gradient Descent) or evol (Evolutionary algorithm) 
function classified = oz_imageclassify(niftis, imagesFolder, optimizer, classifier,z)
    % Reading the classifers 
    load('NBClassifier.mat');
    load('RTClassifier.mat');

    % ======================== Read and Classify images ==========================================
    fprintf('Classifiying the images...\n');
    addpath(imagesFolder);

    if(classifier == 'RT')
        % -------------- Apply the Regression tree classifier into the image ------------- 
        classified = ClassifyOZ(niftis, TreesClassifier);
        save(strcat(imagesFolder,'/ClassifiedPixelsRT.mat'),'classified')
    else
        % -------------- Apply the NB classifier into the image ------------- 
        classified = ClassifyOZ(niftis, NBClassifier);
        save(strcat(imagesFolder,'/ClassifiedPixelsNB.mat'),'classified')
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
