% Reads the positions of each file and obtains the kinetic curves of all of them,
% separating the data in the four classes 'background', 'softtissue', 'chest', 'lesion'
function dispAverageKinetics()
close all;
clear all;
clc;

% Info about view_nii.m
% The new positions get updated at 'set_image_value' line 2914
% The mouse click to update the position is 'catched' at line 583

addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
addpath('/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/');
filesFolder = '/home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/Kinetics/Data_Positions/';

files={'8256301_F.txt', '7585734_F.txt','6107252.txt','5641445_F.txt','0847664_F.txt'};
folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};
saveFolder = '/home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/Kinetics/Kinetic_Curves_by_classes/';

totFiles = length(files);

padding = 900;
width = 800;
height = 400;

% 5 files x 30 lesions x 20 background x 30 soft tissue x 30 chest
lesions = zeros(5*30,5);
background= zeros(5*20,5);
stissue= zeros(5*30,5);
chest = zeros(5*30,5);

%for i=1:totFiles
for i=1:totFiles
    % Read file
    fname = strcat(filesFolder,files{i});
    fprintf('\n Reading positions file: %S \n',fname);
    fileId = fopen(fname);

    % Read nifti
    display(strcat('Reading nifti files from: ',folders{i}))
    niftis = readNifti(folders{i});

    % --------------- Read lesions -------------- 
    display('Reading lesions positions...');
    pos = readPositions(fileId,1,30);
    % Display kinetic curves
    %figure('Position',[100 100 width height])
    lesions(30*(i-1)+1:30*i,:) = obtainKineticCurves(niftis,folders{i},pos,30);
    %title('Lesion');

    %-------------------- Read background -------------------- 
    display('Reading background positions...');
    pos = readPositions(fileId,0,20);
    % Display kinetic curves
    %figure('Position',[padding 100 width height])
    background(20*(i-1)+1:20*i,:) = obtainKineticCurves(niftis,folders{i},pos,20);
    %title('Background');

    %-------------------- Read Soft tissue -------------------- 
    display('Reading soft tissue positions...');
    pos = readPositions(fileId,0,30);
    % Display kinetic curves
    %figure('Position',[padding padding width height])
    stissue(30*(i-1)+1:30*i,:) = obtainKineticCurves(niftis,folders{i},pos,30);
    %title('Soft tissue');

    %-------------------- Read Chest -------------------- 
    display('Reading chest positions...');
    pos = readPositions(fileId,0,30);
    % Display kinetic curves
    %figure('Position',[100 padding width height])
    chest(30*(i-1)+1:30*i,:) = obtainKineticCurves(niftis,folders{i},pos,30);
    %title('Chest');

    %pause(.5)
    fclose(fileId);
end

fprintf('Displaying the average curves..\n');
hold on
plot(mean(lesions),'r','LineWidth',3);
plot(mean(background),'k','LineWidth',3);
plot(mean(stissue),'g','LineWidth',3);
plot(mean(chest),'b','LineWidth',3);
legend( 'Lesion','Background','Soft Tissue','Chest') ;
figure
fprintf('Displaying all the curves..\n');
hold on
plot(lesions','--r','LineWidth',1);
plot(background','--k','LineWidth',1);
plot(stissue','--g','LineWidth',1);
plot(chest','--b','LineWidth',1);

%========== Saving the curves ============
fprintf('Displaying all the curves..\n');
%save(strcat(saveFolder,'lesions'),'lesions')
%save(strcat(saveFolder,'background'),'background')
%save(strcat(saveFolder,'chest'),'chest')
%save(strcat(saveFolder,'stissue'),'stissue')

% Reads the nifti files from the folder being specified
function niftis = readNifti(folder)
    path = '/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
    for i=1:5
        fileName = strcat(path,folder,'/',num2str(i),'.nii');
        nii = load_nii(fileName);
        niftis(i,:,:,:) = nii.img;
    end

% Reads the positions and indicates how many lines should it read
function pos = readPositions(fileId,jump,readTot)
    %Read folder
    h = fscanf(fileId,'%s\n',jump);
    %Read lesion header
    h = fscanf(fileId,'%s %s %s\n',3);
    display(strcat('First line been read on the file: ', h));
    % Initialize position vector
    pos = zeros(readTot,3);
    for i = 1:readTot
        pos(i,:) = fscanf(fileId,'%d %d %d\n',3);
    end

% This function is usede to read the kinetic curves of the desired position,
% it makes a gaussian of the 2x2 neighbors and computes the average of that curve
function curve = obtainKineticCurves(niftis,folder, pos, tot)

    curve = zeros(tot,5);
    nnsize = 2;
    visualize = false;

    % Iterate over the images
    for i=1:5
        % Loading the image
        imgData = squeeze(niftis(i,:,:,:));
        % Iterate over the positions
        for p = 1:tot
            x = pos(p,1);
            y = pos(p,2);
            z = pos(p,3);
            if(visualize)
                vissize = 2*nnsize;
                sample = imgData(x-vissize:x+vissize,y-vissize:y+vissize,:);
                imshow(sample(:,end:-1:1,z)',[0 1500]);
            end
            % Smoothing with a gaussian
            sm = smooth3(imgData(x-nnsize:x+nnsize,y-nnsize:y+nnsize,z-nnsize:z+nnsize), 'gaussian');
            curve(p,i) = mean(mean(mean(sm)));
        end
    end

    %plot(curve','-*');
    %hold on
    %plot(mean(curve),'--r','LineWidth',3);
