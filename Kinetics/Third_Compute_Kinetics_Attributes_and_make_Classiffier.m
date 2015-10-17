% This function reads the curves for each class, obtain a list of features from them, creates a classifier 
function makeClassifier()
close all;
clear all;
clc;

addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/Kinetics/Kinetic_Curves_by_classes/');
%folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};
folders={ '3107404_p7_ok', '4030560_p10_ok', '2004235_p9_ok'};

% ----------- Reads the curves for each class ----------
fprintf('Reading the curves...\n'); 
load('lesions.mat')
load('background.mat')
load('stissue.mat')
load('chest.mat')

fprintf('Plotting the mean curves...\n'); 
hold on
plot(mean(lesions),'r','LineWidth',3);
plot(mean(background),'k','LineWidth',3);
plot(mean(stissue),'g','LineWidth',3);
plot(mean(chest),'b','LineWidth',3);
legend( 'Lesion','Background','Soft Tissue','Chest') ;
pause(.2);
%figure
%hold on
%plot(lesions','--r','LineWidth',1);
%plot(background','--k','LineWidth',1);
%plot(stissue','--g','LineWidth',1);
%plot(chest','--b','LineWidth',1);

% ========= Put everything in a big matrix =======
% The attributes are:
% intensities  [1:5] 
% slopes       [6:9]
% mean value   [10] 
% time to peak [11]
% time of max slope [12]
% non-decreasing function [13]

% 5 files x 30 lesions x 20 background x 30 soft tissue x 30 chest
fprintf('Putting everything ina big matrix...');
totSize = 550;
attributes = 13;
curveMatrix = zeros(totSize,attributes);
outputVector = zeros(totSize,1);
classes = {'Background 0','Chest 1','Soft Tissue 2','Lesion 3'};
currIdx = 1;

% ------ Fill lesions ------
currSize = 150;
curveMatrix(1:currIdx+currSize-1,1:5) = lesions;
outputVector(1:currIdx+currSize-1) = 3;

% ------ Fill background ------
currIdx = currIdx+currSize;
currSize = 100;
curveMatrix(currIdx:currIdx+currSize-1,1:5) = background;
outputVector(currIdx:currIdx+currSize-1) = 0;

% ------ Fill stissue------
currIdx = currIdx+currSize;
currSize = 150;
curveMatrix(currIdx:currIdx+currSize-1,1:5) = stissue;
outputVector(currIdx:currIdx+currSize-1) = 2; 

% ------ Fill chest------
currIdx = currIdx+currSize;
currSize = 150;
curveMatrix(currIdx:currIdx+currSize-1,1:5) = chest; 
outputVector(currIdx:currIdx+currSize-1) = 1; 

%------------------ Compute slopes -------------
curveMatrix(:,6) = curveMatrix(:,2) - curveMatrix(:,1);
curveMatrix(:,7) = curveMatrix(:,3) - curveMatrix(:,2);
curveMatrix(:,8) = curveMatrix(:,4) - curveMatrix(:,3);
curveMatrix(:,9) = curveMatrix(:,5) - curveMatrix(:,4);

%------------------ Compute mean -------------
curveMatrix(:,10) = mean( curveMatrix(:,1:5),2 );

%------------------ Compute time to peak -------------
[del curveMatrix(:,11)] = max( curveMatrix(:,1:5)');

%------------------ Compute time of max slope -------------
[del curveMatrix(:,12)] = max( curveMatrix(:,6:9)');

%------------------ No 'sharp' decrease -------------
curveMatrix(:,13) = min( (curveMatrix(:,6:9) > -5)')';

% ======================== Construct NB classifier ==========================================
fprintf('Making the classifiers...\n');
NBClassifier = fitcnb(curveMatrix, outputVector)
isGenRate = resubLoss(NBClassifier);
fprintf('Naive Bayes classification error of %4.2f % \n',isGenRate*100);
% Save the NB clasifier 
save('NBClassifier.mat', 'NBClassifier');

TreesClassifier = fitctree(curveMatrix, outputVector)
isGenRate = resubLoss(TreesClassifier);
fprintf('Regression Trees classification error of %4.2f % \n',isGenRate*100);
% Save the RegTree clasifier 
save('RTClassifier.mat', 'TreesClassifier');

% ======================== Classify images ==========================================
fprintf('Classifiying the images...\n');
imagesFolder ='/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/'
addpath(imagesFolder);

for i = 1:length(folders)
    % Read all 5 niftis
    fprintf('\nReading nifti files for: %s ... \n',folders{i});
    niftis = readNifti(folders{i});

    % -------------- Apply the Regression tree classifier into the image ------------- 
    classified = makeMagic(niftis, TreesClassifier);
    % --------------- Saving classification of the matrix features ------------
    save(strcat(imagesFolder,folders{i},'/ClassifiedPixels.mat'),'classified')
    

    % -------------- Apply the NB classifier into the image ------------- 
    classified = makeMagic(niftis, NBClassifier);
    % --------------- Saving classification of the matrix features ------------
    save(strcat(imagesFolder,folders{i},'/ClassifiedPixelsNB.mat'),'classified')
end

% This function is used to read 5 nifti files for each folder
function niftis = readNifti(folder)
    path = '/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
    for i=1:5
        fileName = strcat(path,folder,'/',num2str(i),'.nii');
        nii = load_nii(fileName);
        % We smooth the image with gaussian blur
        niftis(i,:,:,:) = smooth3(nii.img);
    end

% This function classifies a DCE-MRI image using one classifier
function result = makeMagic(niftis, nb)
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
