###################################################################
#                                                                 #
# DeepCloud: Ground-based Cloud Image Categorization              #
#        using Deep Convolutional Features V1.0                   #
#                                                                 #
#                     Accepted by TGRS                            #
#                                                                 #
###################################################################

The source code was developed under windows with Matlab 2014a.
- The code has been test on 64-bit Windows 7.
- 64-bit Matlab is required. 

- If you use our codes, please cite our papers.

1. Introduction.

DeepCloud is used to extract the visual features of ground-based cloud
images for categorization. It applies the pre-trained CNN（Convolutional
Neural Network）Model to extract multi-scale and multi-level local features
as local pattern descriptors. Then it selects discriminative patterns 
through pattern mining and encoding them via Fisher Vector. Finally, DeepCloud
trains a SVM model as a classifier to categorize the different cloud types.

###################################################################

2. License.

Copyright (C) 2017 Liang Ye 

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. 

###################################################################


3. Library Required.

- To execute this program, following publiced libraries are need:
	1) MATLAB/OCTAVE interface of LIBLINEAR;
	2) VLFeat 0.9.19
	3) MatConvNet: a MATLAB toolbox implementing *Convolutional Neural
	   Networks* (CNNs) for computer vision applications

- "libraryPubliced.rar" includes all of the publiced tools which are need to 
  support this program.

- the pretrained CNN-M model with the file name "imagenet-vgg-m.mat" 
  which is used in this program can be downloaded on following link:
	http://pan.baidu.com/s/1jI7NVnC

- the fine-tuned CNN-M model with the file name "vgg-fine-tune-byYL.mat" 
  which is used in this program can be downloaded on following link:
	http://pan.baidu.com/s/1jI7NVnC

4. Getting Started.

- decompress "libraryPubliced.rar" to the root path
- download the CNN model on the link.
- .\general_function\ includes some functions used in DeepCloud
- "DeepCloud.m" is our experiments code, and the paramters in the code
  can be changed by yourself.
