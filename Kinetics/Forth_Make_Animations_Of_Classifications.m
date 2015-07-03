% This file is used to create the animations that show the classification of different files

close all;
clear all;
clc;

imagesFolder ='/media/USBSimpleDrive/BigData_Images_and_Others/PhD_Thesis/DCE_MRI/';
folders={ '8256301_p1_ok', '7585734_p14_ok_huge_tumor', '6107252_p2_ok', '5641445_p1_ok_non-mass_from_mass', '0847664_p6_ok'};
framesPerSecond = 6;

for i = 1:length(folders)
    % Read all 5 niftis
    display('Reading classified files ...');
    load(strcat(imagesFolder,folders{i},'/ClassifiedPixels'));

    % - Saving 
    display('Making the animation...');
    pause(.1);
    fig = figure('Position',[200 200 400 400]);
    fileName = strcat('Animations/classified_',folders{i}),'.avi';
    aviobj = VideoWriter(fileName);
    aviobj.FrameRate = framesPerSecond;
    open(aviobj);
    hold on
    for frame=1:size(classified,3)
        temp = squeeze(classified(:,end:-1:1,frame));
        % We need to ensure that all the slides have at least one pixel 0,1,2,3 or the images will
        % have different intensities
        temp(1) = 0; temp(2) = 1; temp(3) = 2; temp(4) = 3;
        test =  mat2gray(temp);
        imshow(test);
        writeVideo(aviobj,test);
        pause(.01);
    end
    close(fig);
    close(aviobj);
end
