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



% ============================
% IMPORTING & SETTINGS  
bin_dir = "/Volumes/theo2/FnP/data/IMG/pomodoro/2024-02-29/"; %directory of the data
imgs_names = ["PCR02.jpeg", "PCR03.jpeg","PCR04.jpeg"]; %names of the images


% Visualization options
auto_segmentation = "yes"; %put yes or no if you want the auto-segmentation
show_ORimages = "yes"; %put yes or no if you want to show the original images
show_SEGimages = "yes"; %put yes or no if you want to show the segmented images

% Saving data
save_data = "no"; %if you want to save the RGB spectrum of the analysed



[R,G,B] = analise_images(bin_dir,imgs_names, auto_segmentation, show_ORimages, show_SEGimages, save_data);



% ============================================================
% ============================================================



function[R,G,B] = analise_images(bin_dir, imgs_names, auto_segmentation, show_ORimages,show_SEGimages, save_data )
tic;
    i = 0;
    for img = imgs_names
        fprintf("\n")
        disp("@@@@@@@@@@@@@@@")
        
        i = i+1; % aux variable for figures
        figure(i) %creating for every img the figure
    
        image = imread(bin_dir + img); %read the image
    
        
    % ============================================================
    % SHOWING ORIGINAL IMAGES
    
    if show_ORimages == "yes"
        disp("Showing original " + img)
        subplot(2,2,1), imshow(image);
    elseif show_ORimages == "no"
        disp('Original image not showed')
    else
        error('Write yes or no to show or not original images')
    end
    
    
    % ============================================================
    % SEGMENTING THE CENTRAL PART OF THE IMAGE &
    % PLOTTING THE RGB CHANNEL
    
    if auto_segmentation == "yes"
        disp("Image " + img + " segmentation...")
        [segment_map, maskedImage] = segmentImage(image);
        disp('...Image segmented')
        
        if show_SEGimages == "yes"
            disp("Showing segmented " + img + " image")
            %figure; imshow(segment_mapAero);
            subplot(2,2,2), imshow(maskedImage);
    %         figure, imshow(maskedImageAero);
        
        
        elseif show_ORimages == "no"
            disp('Segmented image not showed')
        else
            error('Write yes or no to show or not segmented images')
        end
    
    elseif auto_segmentation == "no"
        fprintf(['No autosegmentation selected.\n ' ...
            'Please, segment your images with the Image Segmenter Tool giving the names:\n' ...
            '-maskedInage- for the image.\n' ...
            'Gives also the names:\n' ...
            '-segment_map- for the BW map.\n'])
        
       
        if show_SEGimages == "yes"
            disp("Showing segmented " + img + " image")
            %figure; imshow(segment_mapAero);
            figure; imshow(maskedImage);
        
            %figure; imshow(segment_mapNorm);
            figure; imshow(maskedImage);
        
        elseif show_ORimages == "no"
            disp('Segmented image not showed')
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
    
    %creating the RGB channel from maskedImage
    I = maskedImage;
    R=imhist(I(:,:,1));
    G=imhist(I(:,:,2));
    B=imhist(I(:,:,3));
    
    
    % Normalizing the values of the spectra
    R = R/sum(R);
    G = G/sum(G);
    B = B/sum(B);
    
    %removing 0 values (i.e the first value of the RGB channel, that is the
    %black colour, corresponding to 0 value of pixel)
    R(1)=[];
    G(1)=[];
    B(1)=[];
    
    % Plotting the RGB profile
    subplot(2,2,[3,4]), plot(R,'r')
    hold on, plot(G,'g')
    plot(B,'b');
    hold off
    title("RGB spectra of " + img)
    xlim([0,255])
    
    toc;
    
    
    [Rmax,IRmax] = max(R);
    [Gmax,IGmax] = max(G);
    [Bmax,IBmax] = max(B);
    
    
    
    disp("-- Peak Values of " + img + " --")
    fprintf("R: %i\nG: %i\nB: %i\n",IRmax, IGmax, IBmax)
    
    
    %Annotation 
    str2print = sprintf("-- Peak Values of %s --\n" + ...
        "R: %i\nG: %i\nB: %i\n", img, IRmax, IGmax, IBmax);
    annotation(figure(i),'textbox',...
    [0.451446428571428 0.728110599078341 0.118196428571429 0.133640552995392],...
    'String',str2print,...
    'FontSize',16,...
    'FitBoxToText','off','HorizontalAlignment','center');
    
    
    
    % ============================================================
    % SAVING DATA 
    
    %Saving the RGB spectra
    if save_data == "yes"
        disp("Press enter to save the data")
        pause;
        tic;
        %open the file in writing mode
        fidR = fopen(bin_dir + img+".r", 'w');
        fidG = fopen(bin_dir + img+".g", 'w');
        fidB = fopen(bin_dir + img+".b", 'w');
        
        %print the first column for aero RGB
        fprintf(fidR, "%s\t%s\n", "bin", "value");
        fprintf(fidG, "%s\t%s\n", "bin", "value");
        fprintf(fidB, "%s\t%s\n", "bin", "value");
       
    
        %print all the values in the corresponding files
        for i = [1:1:255]
            %save aero data
            fprintf(fidR, "%i\t%i\n", i, R(i));
            fprintf(fidG, "%i\t%i\n", i, G(i));
            fprintf(fidB, "%i\t%i\n", i, B(i));
           
        end
    
        fclose(fidR);
        fclose(fidG);
        fclose(fidB);
    
        toc;
    
    elseif save_data == "no"
        disp("Data NOT saved")
    else
        error("Set yes or no in -saving_data-")
       
    end
    
    end

end




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



