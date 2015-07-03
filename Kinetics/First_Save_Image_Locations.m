% Info about view_nii.m
% The new positions get updated at 'set_image_value' line 2914
% The mouse click to update the position is 'catched' at line 583
% The positions are saved at /home/olmozavala/Dropbox/OzOpenCL/Matlab_ImagePreProcessing_Kinetic/
% in a file called  TEMP.txt
close all;
clear all;
clc;

addpath('/home/olmozavala/Dropbox/OzOpenCL/MatlabActiveContours/Load_NIfTI_Images/External_Tools');
addpath('/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/7585734_p14_ok_huge_tumor');

% The tested folders/files are: 
% '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};

fileName = '2.nii';

% Loading the image
nii = load_nii(fileName);

imgData= nii.img;
% To visuazlie the data
% FROM IMAGE WE CHANGE X-y and Y-x because images are flipped
x = 264;
y = 257;
z = 56;
opt.setviewpoint = [x y z];
view_nii(nii, opt);
return
