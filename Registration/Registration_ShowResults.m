% This function is used to create nice figures showing the results of the registration algorithm
function showRegistrationResults()

    close all;
    clear all;
    clc;

    % Create curve for specific point in the image
    folderImage  = '/home/olmozavala/Dropbox/TestImages/nifti/RealExample1/';

    addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
    addpath('ResultsFromTestImage/RegisteredImages/');
    addpath('../lib/');
    addpath(folderImage);

    fontsize = 14;
    totImages = 5;

    % Location of the image to show
    x = 264;
    y = 289;
    z = 56;

    % ------------- Reads the original image --------
    fileName = '1.nii';

    % Loading the data 
    nii = load_nii(fileName);
    imgData= nii.img;

    % Removing unwanted regions
    ROI_start = 190;
    ROI_end = 320;
    sizeImg = 20;
    y = ROI_end-y; 

    sampleOriginal = imgData(:,ROI_end:-1:ROI_start,:);
    plotIdx = 1;
    visualizeDisparity(sampleOriginal,totImages, x,y,z,sizeImg,folderImage, ROI_end, ROI_start, fontsize)
    H= figure('Position',[100 100 1600 800]);
    for  i=2:totImages
        fileNameOrig = strcat(folderImage,num2str(i),'.nii');
        fileNameRegis = strcat('Reg_',num2str(i),'.nii');
        fileNameRegisEvol = strcat('Reg_Evol_',num2str(i),'.nii');
        % Loading the image
        display('Loading the images...');
        nii = load_nii(fileNameOrig);
        niiReg = load_nii(fileNameRegis);
        niiRegEvol = load_nii(fileNameRegisEvol);
        % Accessing the data
        display('Accessing data...');
        imgData= nii.img;
        imgDataReg= niiReg.img;
        imgDataRegEvol= niiRegEvol.img;
        % Cuts to display just one region
        display('Cutting chest...');
        sample = imgData(:,ROI_end:-1:ROI_start,:);
        sampleReg = imgDataReg(:,:,:);
        sampleRegEvol = imgDataRegEvol(:,:,:);
        display('Displaying results...');
        plotIdx = dispResults(sampleOriginal, sample, sampleReg, sampleRegEvol, plotIdx, x, y, z, sizeImg,fontsize-5, i);
        %plotIdx = dispResults(sampleOriginal, sample, sampleReg, sampleRegEvol, plotIdx, x, y, z, -1,fontsize);
    end
    saveas(H,'Results/RegistrationResults','png');

%%%%%%%%%%%%%%%%%%%%%  Used to visualize the  Registration performance of each algorithm %%%%%%%%%%%%%%%%%%%%%  
function plotIdx = dispResults(par_sampleOriginal, par_sample, par_sampleReg, par_sampleRegEvol, plotIdx, x, y, z, sizeImg, fontsize, T)
    %if sizeImg = -1 then we display the whole resolution
    if(sizeImg~=-1)
        sample = par_sample(x-sizeImg:x+sizeImg,y-sizeImg:y+sizeImg,:);
        sampleReg = par_sampleReg(x-sizeImg:x+sizeImg,y-sizeImg:y+sizeImg,:);
        sampleRegEvol = par_sampleRegEvol(x-sizeImg:x+sizeImg,y-sizeImg:y+sizeImg,:);
        sampleOriginal = par_sampleOriginal(x-sizeImg:x+sizeImg,y-sizeImg:y+sizeImg,:);
    else
        sample = par_sample;
        sampleReg = par_sampleReg;
        sampleRegEvol = par_sampleRegEvol;
        sampleOriginal = par_sampleOriginal;
    end
    % Display the disparrity between the images
    subplot(4,6,plotIdx); imshowpair(sampleOriginal(:,:,z)', sample(:,:,z)');
    title(strcat('No Registration t=',num2str(T)) ,'FontSize',fontsize-1);
    plotIdx = plotIdx+1;
    % ---- Show the registered image
    subplot(4,6,plotIdx); imshowpair(sampleOriginal(:,:,z)', sampleReg(:,:,z)');
    title(strcat('Gradient Descent t=',num2str(T)),'FontSize',fontsize-1);
    plotIdx = plotIdx+1;
    % ---- Show the registered image
    subplot(4,6,plotIdx); imshowpair(sampleOriginal(:,:,z)', sampleRegEvol(:,:,z)');
    title(strcat('Evolutionary algorithm t=',num2str(T)),'FontSize',fontsize-1);
    plotIdx = plotIdx+1;
    % -------- Computes the SSD ----
    MSE_def = squeeze(sum(sum((par_sampleOriginal-par_sample).^2)));
    MSE = squeeze(sum(sum((par_sampleOriginal-par_sampleReg).^2)));
    MSE_Evol = squeeze(sum(sum((par_sampleOriginal-par_sampleRegEvol).^2)));
    % ------- Plot the SSD
    subplot(4,6,[plotIdx:plotIdx+2]); plot(MSE_def);hold on;
    title(strcat('SSD for each Z slice t=',num2str(T)),'FontSize',fontsize+2);
    plot(MSE,'r'); 
    plot(MSE_Evol,'g');    
    % --------- Compute and plot the mean of SSD --------
   % plot([1:length(MSE_def)],mean(MSE_def),'b'); axis([1 length(MSE_def) 1 6*10^9]);
   % plot([1:length(MSE)],mean(MSE),'r'); 
   % plot([1:length(MSE_Evol)],mean(MSE_Evol),'g'); 
    legend('No registration','Gradient Descent', 'Evolutionary algorithm','Location','EastOutside');
    axis([1 length(MSE) 1 6*10^9]); hold off;
    plotIdx = plotIdx+3;

%%%%%%%%%%%%%%%%%%%%%  used to visualize the disparity between the images %%%%%%%%%%%%%%%%%%%%%  
function visualizedisparity(imgdata, totimages, x, y, z, sizeimg,folder, roi_end, roi_start,fontsize)
    h= figure('position',[100 100 1300 800]);
    sizeimg = 20;
    sampleoriginal = imgdata(x-sizeimg:x+sizeimg,y-sizeimg:y+sizeimg,z);
    h = subplot(4,4,[1:8]);hold on;
    set(h,'xtick',[],'ytick',[]);
    axis([0 352 0 171 ]);
    imshow(imgdata(:,:,z)',[0 3500],'initialmagnification','fit');
    rectangle('position',[x-sizeimg, y-sizeimg, 2*sizeimg, 2*sizeimg],'edgecolor','r');
    title('region of interst','fontsize',fontsize);

    plotidx = 9;

    for  i=2:totimages
        filename = strcat(folder,num2str(i),'.nii');
        % loading the image
        nii = load_nii(filename);
        imgdata= nii.img;
        imgdata = imgdata(:,roi_end:-1:roi_start,:);
        sample = imgdata(x-sizeimg:x+sizeimg,y-sizeimg:y+sizeimg,z);
        subplot(4,4,plotidx);
        imshow(sample(:,:,:)',[0 3500],'initialmagnification','fit');
        title(strcat('mri at t=',num2str(i)),'fontsize',fontsize);
        subplot(4,4,plotidx+4);
        imshowpair(sampleoriginal(:,:,:)', sample(:,:,:)');
        title(strcat('difference t=0 vs t=',num2str(i)),'fontsize',fontsize-1);
        plotidx= plotidx+1;
    end
    tightfig;

    saveas(h,'results/mismatch','png');
