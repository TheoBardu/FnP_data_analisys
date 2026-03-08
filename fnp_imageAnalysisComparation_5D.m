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
bin_dir = "/Volumes/theo2/FnP/data/IMG/pomodoro/2024-01-11/"; %directory of the data


%Aero image importing
aero_img = imread( ...
    bin_dir + "aero1.JPG");
%Normal
norm_img = imread( ...
    bin_dir + "norm1.JPG");

% Visualization options
auto_segmentation = "no"; %put yes or no if you want the auto-segmentation
show_ORimages = "yes"; %put yes or no if you want to show the original images
show_SEGimages = "yes"; %put yes or no if you want to show the segmented images

% Saving data
save_data = "yes"; %if you want to save the RGB spectrum of the analysed




% ============================================================
% SHOWING ORIGINAL IMAGES

if show_ORimages == "yes"
    disp('Showing original images')
    figure(1), subplot(2,3,1), imshow(aero_img);
    figure(1), subplot(2,3,4), imshow(norm_img);
elseif show_ORimages == "no"
    disp('Original images not showed')
else
    error('Write yes or no to show or not original images')
end


% ============================================================
% SEGMENTING THE CENTRAL PART OF THE aeroIMAGE

if auto_segmentation == "yes"
    disp('Images segmentation...')
    [BWaero, maskedImageAero] = segmentImage(aero_img);
    [BWnorm, maskedImageNorm] = segmentImage(norm_img);
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
        '"maskedInageAero" for the aerophonics image and "maskedImageNorm" for normal tecqnique.\n' ...
        'Gives also the names:\n' ...
        '"BWaero" for the BW map of aerophonics and "BWnorm" for BW map of normal growht tc.\n'])
    
   
  
else
    error("Write yes or no for auto-segmentation")

end

%%

    if show_SEGimages == "yes"
        disp('Showing segmented images')
        %figure; imshow(segment_mapAero);
        figure(1), subplot(2,3,2), imshow(maskedImageAero);
%         figure, imshow(maskedImageAero);
    
        %figure; imshow(segment_mapNorm);
        figure(1), subplot(2,3,5), imshow(maskedImageNorm);
%         figure, imshow(maskedImageNorm);
    
    elseif show_ORimages == "no"
        disp('Segmented images not showed')
    else
        error('Write yes or no to show or not segmented images')
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
figure(1), subplot(2,3,3), plot(Raero,'r')
hold on, plot(Gaero,'g')
plot(Baero,'b');
hold off
title("RGB spectra of aerophonics")
xlim([0,255])

figure(1), subplot(2,3,6), plot(Rnorm,'r')
hold on, plot(Gnorm,'g')
plot(Bnorm,'b');
hold off
title("RGB spectra of normal")
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


str2print = sprintf("R_{aero}: %i\t\tR_{norm}: %i\n" + ...
    "G_{aero}: %i\t\tG_{norm}: %i\n" + ...
    "B_{aero}: %i\t\tB_{norm}: %i\n", ...
    IRmax_aero, IRmax_norm, IGmax_aero, IGmax_norm, IBmax_aero, IBmax_norm);


annote(figure(1),str2print)


% ============================================================
% SAVING DATA

%Saving the RGB spectra
save_data = input("Do you want to save the data? (y/n)  ",'s');
if save_data == "y"
    bin_save = bin_dir+"spectra/";
    
    disp("Press enter to save the data in" + bin_save)
    
    pause;
    tic;
    
    mkdir(bin_save);
    

    %open the file in writing mode
    fidRaero = fopen(bin_save + "aero.r", 'w');
    fidGaero = fopen(bin_save + "aero.g", 'w');
    fidBaero = fopen(bin_save + "aero.b", 'w');

    fidRnorm = fopen(bin_save + "norm.r", 'w');
    fidGnorm = fopen(bin_save + "norm.g", 'w');
    fidBnorm = fopen(bin_save + "norm.b", 'w');


    
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

    savefig(figure(1), bin_dir + "analysed.svg");

elseif save_data == "n"
    disp("Data NOT saved")
else
    error("Type y or n in -saving_data-")
   
end

% ============================================================
% ============================================================








function [BW,maskedImage] = segmentImage(RGB)
%segmentImage Segment image using auto-generated code from imageSegmenter app
%  [BW,MASKEDIMAGE] = segmentImage(RGB) segments image RGB using
%  auto-generated code from the imageSegmenter app. The final segmentation
%  is returned in BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 30-Dec-2023
%----------------------------------------------------


% Convert RGB image into L*a*b* color space.
X = rgb2lab(RGB);

% Graph cut
foregroundInd = [9099997 9886233 10073430 10234422 10335510 10451574 10552662 10612566 10784790 10945782 11136726 11293974 11439986 11615954 11818134 12035289 12095193 12110169 12166329 ];
backgroundInd = [8763037 8763053 8763080 8763100 8763142 8763158 8777986 8778153 8792931 8822868 8838061 8852804 8867768 8893973 8908941 8923909 8953845 8953853 8954129 8968810 8968821 8969105 8984081 9100145 9287345 9317002 9781553 10028370 10174677 10335381 10743769 10859545 11163097 11192765 11515033 11600873 11818025 11949065 12020480 12110057 12241101 12357165 12413325 12428576 12529389 12529664 12544365 12544633 12559341 12559364 12574402 12574449 12574499 12574538 12574558 ];
L = superpixels(X,105232,'IsInputLab',true);

% Convert L*a*b* range to [0 1]
scaledX = prepLab(X);
BW = lazysnapping(scaledX,L,foregroundInd,backgroundInd);

% Active contour
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

function [] = annote(figure,str)
annotation(figure,'textbox',...
    [0.422428571428571 0.449769585253456 0.198553571428572 0.114285714285715],...
    'String',{str},...
    'FitBoxToText','off');
end

