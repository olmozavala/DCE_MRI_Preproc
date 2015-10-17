DCE-MRI Image preprocessing for breast lesion segmentation
====

This code contains a set of Matlab scripts to perform the preprocessing
of DCE-MRI images of the breast. The preprocessing has two steps, 
a registration step using affine intensity based transformations; and 
an image enhancement step using machine learning.  

# Requirements
This software uses the NIfTIi and ANALYZE image toolbox available at:
<http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image>

It also assumes that you have access to a group of DCE-MRI images stored somewhere
in separate folders. These are the two paths that are defined in most of the matlab files:
one for the nifti library, one for the DCE-MRI image folders. 

# Description
DCE-MRI images are registered using an intensity based rigid
transformation algorithm based on gradient descent or a genetic algorithm. After the registration, voxels 
that correspond to breast lesions are enhanced using the Naive Bayes machine learning classifier
or a Regression tree. The classifier is trained to identify
four different classes in breast images: lesion, normal tissue,
chest, and background. Training is performed by manually selecting 150 voxels
for each of the four classes from images where breast lesions have been confirmed by 
an expert in the field. Thirteen attributes obtained 
from the kinetic curves of the selected voxels
are later used to train the classifier. Finally, the classifier 
is used to increase the intensity values of voxels labeled as lesions 
and decrease the intensities of all the other voxels. 
 The post-processed images are used for  
volume segmentation of breast lesions using a level set method
based on the Active Contours Without Edges algorithm.


