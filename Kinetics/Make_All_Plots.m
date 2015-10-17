% This function is used to generate all the images related with the pre-processing
% of the images using kinetic information, used on my thesis

% Separating the data in the four classes 'background', 'softtissue', 'chest', 'lesion'
function drawAll()
close all;
clear all;
clc;

addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
addpath('/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/');
addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/Kinetics/Kinetic_Curves_by_classes');
addpath('/home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/Kinetics/ext_lib');
saveFolder = '/home/olmozavala/Dropbox/Thesis_Phd/LatexFiles/images/OurWork/kinetics/classifier/train/';

titleFS = 17;
legendFS = 12;
axisFS = 18;
axisLegend = 18;

[background chest lesions stissue] = loadKineticInfo();
plotKineticCurves(background,chest,lesions,stissue,saveFolder,titleFS, legendFS, axisFS, axisLegend)
plotKineticCurvesError(background,chest,lesions,stissue, saveFolder,titleFS, legendFS, axisFS, axisLegend )


% This function reads all the kintif info from the already generated files
function [background chest lesions stissue]=loadKineticInfo()
    load('background')
    load('chest')
    load('lesions')
    load('stissue')

% This function plots the mean curves off all the classes
function plotKineticCurves(background,chest,lesions,stissue,saveFolder,titleFS, legendFS, axisFS,axisLegend)
    f = figure('Position',[200 200 800 400])
    plot(mean(lesions),'*-r');
    hold on;
    plot(mean(chest),'*-y');
    plot(mean(stissue),'*-g');
    plot(mean(background),'*-b');
    title('Mean kinetic curves','FontSize',titleFS);

    legend( 'Lesion','Chest','Normal Tissue','Background','Location',[.69 .65 .2 .1]) ;

    ylabel('Intensity value','FontSize',axisLegend);
    xlabel('Acquisition time','FontSize',axisLegend);

    set(gca,'xTick',[1:5]);
    set(gca,'XTickLabel',['Pre-cont';'Post 1  ';'Post 2  ';'Post 3  ';'Post 4  '],'FontSize',legendFS);

    saveas(f,strcat(saveFolder,'MeanKineticCurves'),'png');
    
% This function plots the variance of each kinetic curve
function plotKineticCurvesError(background,chest,lesions,stissue,saveFolder,titleFS, legendFS, axisFS,axisLegend)
    marker = ':'
    f = figure('Position',[200 200 800 400])
    errorbar(mean(lesions),std(lesions),strcat(marker,'r'),'LineWidth',2);
    hold on;
    errorbar(mean(stissue),std(stissue),strcat(marker,'g'),'LineWidth',2.5);
    errorbar(mean(chest),std(chest),strcat(marker,''),'Color',[.81 .81 0.07],'LineWidth',1.5);
    errorbar(mean(background),std(background),strcat(marker,'b'));
    title('Standard deviation','FontSize',titleFS);

    legend( 'Lesion','Chest','Normal Tissue','Background','Location','NorthWest') ;

    ylabel('Intensity value','FontSize',axisFS);
    xlabel('Acquisition time','FontSize',axisFS);

    set(gca,'xTick',[1:5]);
    set(gca,'XTickLabel',['Pre-cont';'Post 1  ';'Post 2  ';'Post 3  ';'Post 4  '],'FontSize',legendFS);

    saveas(f,strcat(saveFolder,'MeanKineticCurvesError'),'png');

