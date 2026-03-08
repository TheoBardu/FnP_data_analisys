% Script that take images of plants from aeroponics and traditional growth
% and compare the spectra.

% NB: For the Auto-Segmentation tool, you need to take a picture of che
% canopy of the plant centerded in the frame of the picture, with the leaf in the orizontal. 
% (Turn on the grid and make sure the canopy is centered in the central
% square.)


clear; close all;

fprintf('\n\n')
disp('-----------------------------')
disp('Running imageAnalysis FnP')
disp('-----------------------------')

tic;

% ============================
% IMPORTING & SETTINGS  
bin_dir = "/Volumes/theo2/FnP/data/IMG/pomodoro/2024-02-29/"; %directory of the data
im1 = "PCR02.jpeg";
im2 = "PCR03.jpeg";

%Aero image importing
aero_img = imread( ...
    bin_dir + im1);
%Normal
norm_img = imread( ...
    bin_dir + im2);

% Visualization options
auto_segmentation = "yes"; %put yes or no if you want the auto-segmentation
show_ORimages = "yes"; %put yes or no if you want to show the original images
show_SEGimages = "yes"; %put yes or no if you want to show the segmented images

% Saving data
save_data = "no"; %if you want to save the RGB spectrum of the analysed




% ============================================================
% SHOWING ORIGINAL IMAGES

if show_ORimages == "yes"
    disp('Showing original images')
    subplot(2,3,1), imshow(aero_img);
    subplot(2,3,4), imshow(norm_img);
elseif show_ORimages == "no"
    disp('Original images not showed')
else
    error('Write yes or no to show or not original images')
end


% ============================================================
% SEGMENTING THE CENTRAL PART OF THE aeroIMAGE &
% PLOTTING THE RGB CHANNEL

if auto_segmentation == "yes"
    disp('Images segmentation...')
    [segment_mapAero, maskedImageAero] = segmentImage(aero_img);
    [segment_mapNorm, maskedImageNorm] = segmentImage(norm_img);
    disp('Images segmented')
    
    
    if show_SEGimages == "yes"
        disp('Showing segmented images')
        %figure; imshow(segment_mapAero);
        subplot(2,3,2), imshow(maskedImageAero);
%         figure, imshow(maskedImageAero);
    
        %figure; imshow(segment_mapNorm);
        subplot(2,3,5), imshow(maskedImageNorm);
%         figure, imshow(maskedImageNorm);
    
    elseif show_ORimages == "no"
        disp('Segmented images not showed')
    else
        error('Write yes or no to show or not segmented images')
    end

elseif auto_segmentation == "no"
    fprintf(['No autosegmentation selected.\n ' ...
        'Please, segment your images with the Image Segmenter Tool giving the names:\n' ...
        '-maskedInageAero- for the aerophonics image and -maskedImageNorm- for normal tecqnique.\n' ...
        'Gives also the names:\n' ...
        '-segment_mapAero- for the BW map of aerophonics and -segment_mapNorm- for BW map of normal growht tc.\n'])
    
   
    if show_SEGimages == "yes"
        disp('Showing segmented images')
        %figure; imshow(segment_mapAero);
        figure; imshow(maskedImageAero);
    
        %figure; imshow(segment_mapNorm);
        figure; imshow(maskedImageNorm);
    
    elseif show_ORimages == "no"
        disp('Segmented images not showed')
    else
        error('Write yes or no to show or not segmented images')
    end
else
    error("Write yes or no for auto-segmentation")

end


% ============================================================
% REMOVING 0 VALUES & PLOT RGB PROFILE
% the 0 values are not included because are the black part of the image,
% after the segmentation

%creating the RGB channel from aeroImage
Iaero = maskedImageAero;
Raero=imhist(Iaero(:,:,1));
Gaero=imhist(Iaero(:,:,2));
Baero=imhist(Iaero(:,:,3));

%creating the RGB channel from normImage
Inorm = maskedImageNorm;
Rnorm=imhist(Inorm(:,:,1));
Gnorm=imhist(Inorm(:,:,2));
Bnorm=imhist(Inorm(:,:,3));


% Normalizing the values of the spectra
Raero = Raero/sum(Raero);
Gaero = Gaero/sum(Gaero);
Baero = Baero/sum(Baero);

Rnorm = Rnorm/sum(Rnorm);
Gnorm = Gnorm/sum(Gnorm);
Bnorm = Bnorm/sum(Bnorm);

%removing 0 values (i.e the first value of the RGB channel, that is the
%black colour, corresponding to 0 value of pixel)
Raero(1)=[];
Gaero(1)=[];
Baero(1)=[];

Rnorm(1)=[];
Gnorm(1)=[];
Bnorm(1)=[];

% Plotting the RGB profile
subplot(2,3,3), plot(Raero,'r')
hold on, plot(Gaero,'g')
plot(Baero,'b');
hold off
title("RGB spectra of" + im1)
xlim([0,255])

subplot(2,3,6), plot(Rnorm,'r')
hold on, plot(Gnorm,'g')
plot(Bnorm,'b');
hold off
title("RGB spectra of" + im2)
xlim([0,255])


toc;


[Rmax_aero,IRmax_aero] = max(Raero);
[Gmax_aero,IGmax_aero] = max(Gaero);
[Bmax_aero,IBmax_aero] = max(Baero);

[Rmax_norm,IRmax_norm] = max(Rnorm);
[Gmax_norm,IGmax_norm] = max(Gnorm);
[Bmax_norm,IBmax_norm] = max(Bnorm);


disp("--Peak Values--")
disp("     # Aero #")
fprintf("R: %i\nG: %i\nB: %i\n",IRmax_aero, IGmax_aero, IBmax_aero)
disp("     # Norm #")
fprintf("R: %i\nG: %i\nB: %i\n",IRmax_norm, IGmax_norm, IBmax_norm)





% ============================================================
% SAVING DATA 

%Saving the RGB spectra
if save_data == "yes"
    disp("Press enter to save the data")
    pause;
    tic;
    %open the file in writing mode
    fidRaero = fopen(bin_dir + "aero.r", 'w');
    fidGaero = fopen(bin_dir + "aero.g", 'w');
    fidBaero = fopen(bin_dir + "aero.b", 'w');

    fidRnorm = fopen(bin_dir + "norm.r", 'w');
    fidGnorm = fopen(bin_dir + "norm.g", 'w');
    fidBnorm = fopen(bin_dir + "norm.b", 'w');


    
    %print the first column for aero RGB
    fprintf(fidRaero, "%s\t%s\n", "bin", "value");
    fprintf(fidGaero, "%s\t%s\n", "bin", "value");
    fprintf(fidBaero, "%s\t%s\n", "bin", "value");
    
    %print the first column for norm RGB
    fprintf(fidRnorm, "%s\t%s\n", "bin", "value");
    fprintf(fidGnorm, "%s\t%s\n", "bin", "value");
    fprintf(fidBnorm, "%s\t%s\n", "bin", "value");
    

    %print all the values in the corresponding files
    for i = [1:1:255]
        %save aero data
        fprintf(fidRaero, "%i\t%i\n", i, Raero(i));
        fprintf(fidGaero, "%i\t%i\n", i, Gaero(i));
        fprintf(fidBaero, "%i\t%i\n", i, Baero(i));
        
        %save norm data
        fprintf(fidRnorm, "%i\t%i\n", i, Rnorm(i));
        fprintf(fidGnorm, "%i\t%i\n", i, Gnorm(i));
        fprintf(fidBnorm, "%i\t%i\n", i, Bnorm(i));
    end

    fclose(fidRaero);
    fclose(fidGaero);
    fclose(fidBaero);

    fclose(fidRnorm);
    fclose(fidGnorm);
    fclose(fidBnorm);
    toc;

elseif save_data == "no"
    disp("Data NOT saved")
else
    error("Set yes or no in -saving_data-")
   
end

% ============================================================
% ============================================================








function [BW,maskedImage] = segmentImage(RGB)
%segmentImage Segment image using auto-generated code from imageSegmenter app
%  [BW,MASKEDIMAGE] = segmentImage(RGB) segments image RGB using
%  auto-generated code from the imageSegmenter app. The final segmentation
%  is returned in BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 26-Dec-2023
%----------------------------------------------------


% Convert RGB image into L*a*b* color space.
X = rgb2lab(RGB);

% Graph cut
foregroundInd = [3996300 4120281 4728093 5193770 5656429 5886250 6028372 6197713 6406359 6645249 6920424 7138142 7183502 7364936 7537301 7688495 7875983 7981819 8057419 8151163 8323531 8492875 8523112 ];
backgroundInd = [3693728 3694255 3694318 3694336 3694340 3702790 3702800 3703255 3720916 3720947 3733065 3733178 3733332 3733372 3751146 3760215 3769284 3800176 3826731 3844868 3875108 4008161 4216811 4386149 4395886 4661326 4954651 5287928 5305435 5752984 6254965 6397701 6623887 6986754 6996425 7440928 7506860 7964064 8057225 8399511 8798676 8825324 9025473 9064785 9073854 9073857 9091439 9100514 9101035 9118674 9119145 9130786 9130814 9149036 9158256 ];
L = superpixels(X,61064,'IsInputLab',true);

% Convert L*a*b* range to [0 1]
scaledX = prepLab(X);
BW = lazysnapping(scaledX,L,foregroundInd,backgroundInd);

% Active contour (refine the contour of the image)
iterations = 200;
BW = activecontour(X, BW, iterations, 'Chan-Vese');

% Create masked image.
maskedImage = RGB;
maskedImage(repmat(~BW,[1 1 3])) = 0;
end

function out = prepLab(in)

% Convert L*a*b* image to range [0,1]
out = in;
out(:,:,1) = in(:,:,1) / 100;  % L range is [0 100].
out(:,:,2) = (in(:,:,2) + 86.1827) / 184.4170;  % a* range is [-86.1827,98.2343].
out(:,:,3) = (in(:,:,3) + 107.8602) / 202.3382;  % b* range is [-107.8602,94.4780].

end



