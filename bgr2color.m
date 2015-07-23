function [ image ] = bgr2color( filename, filter, thresh, h )
% BGR to Color
% Aligns a set of images of the same subject matter that were taken with a
% red, green and blue filter respectively, to produce a colour image.

% Filter
if ~exist( 'filter' )
    filter = 'sobel';
end
if ~exist( 'thresh' )
    fThresh = false;
else
    fThresh = true;
end
if ~exist( 'h' )
    fH = false;
else
    fH = true;
end

% Read Image
image = imread( filename );

% Split Image
% Splits the image vertically into 3 equal size images.
[h w] = size( image );
h = floor( h/3 ); % Height / 3 (round down)
imageB = image( 1:h, : );         % 1st third
imageG = image( h+1:h*2, : );     % 2nd third
imageR = image( (h*2)+1:h*3, : ); % 3rd third

% Subsample Images
% Subsamples the images by 4 (0.25) & 2 (0.5).
imageSub1R = imresize( imageR, 0.25 ); % Pass 1
imageSub1G = imresize( imageG, 0.25 ); % Pass 1
imageSub1B = imresize( imageB, 0.25 ); % Pass 1
imageSub2R = imresize( imageR, 0.5 );  % Pass 2
imageSub2G = imresize( imageG, 0.5 );  % Pass 2
imageSub2B = imresize( imageB, 0.5 );  % Pass 2

% Filtered Images
% Provides edge detected images for 3 passes.
if fThresh == false % Filter ('sobel' default)
    imageEdge1R = edge( imageSub1R, filter ); % Pass 1
    imageEdge1G = edge( imageSub1G, filter ); % Pass 1
    imageEdge1B = edge( imageSub1B, filter ); % Pass 1
    imageEdge2R = edge( imageSub2R, filter ); % Pass 2
    imageEdge2G = edge( imageSub2G, filter ); % Pass 2
    imageEdge2B = edge( imageSub2B, filter ); % Pass 2
    imageEdge3R = edge( imageR, filter ); % Pass 3
    imageEdge3G = edge( imageG, filter ); % Pass 3
    imageEdge3B = edge( imageB, filter ); % Pass 3
elseif fH == false % User specified thresh value
    imageEdge1R = edge( imageSub1R, filter, thresh ); % Pass 1
    imageEdge1G = edge( imageSub1G, filter, thresh ); % Pass 1
    imageEdge1B = edge( imageSub1B, filter, thresh ); % Pass 1
    imageEdge2R = edge( imageSub2R, filter, thresh ); % Pass 2
    imageEdge2G = edge( imageSub2G, filter, thresh ); % Pass 2
    imageEdge2B = edge( imageSub2B, filter, thresh ); % Pass 2
    imageEdge3R = edge( imageR, filter, thresh ); % Pass 3
    imageEdge3G = edge( imageG, filter, thresh ); % Pass 3
    imageEdge3B = edge( imageB, filter, thresh ); % Pass 3
else % User specified thresh & h values
    imageEdge1R = edge( imageSub1R, filter, thresh, h ); % Pass 1
    imageEdge1G = edge( imageSub1G, filter, thresh, h ); % Pass 1
    imageEdge1B = edge( imageSub1B, filter, thresh, h ); % Pass 1
    imageEdge2R = edge( imageSub2R, filter, thresh, h ); % Pass 2
    imageEdge2G = edge( imageSub2G, filter, thresh, h ); % Pass 2
    imageEdge2B = edge( imageSub2B, filter, thresh, h ); % Pass 2
    imageEdge3R = edge( imageR, filter, thresh, h ); % Pass 3
    imageEdge3G = edge( imageG, filter, thresh, h ); % Pass 3
    imageEdge3B = edge( imageB, filter, thresh, h ); % Pass 3
end

% Translation Coordinates
% Calculates the vertical & horizontal translation coordinates for the red
% & blue images for the 3 passes.
[h w] = size( imageEdge1G );
h = ceil( h/2 ); % Height / 2 (round up)
w = ceil( w/2 ); % Width / 2 (round up)
% Default shift values
shift1R = sum( sum( ( imageEdge1G-imageEdge1R).^2) );
shift1B = sum( sum( ( imageEdge1G-imageEdge1B).^2) );
shift2R = sum( sum( ( imageEdge2G-imageEdge2R).^2) );
shift2B = sum( sum( ( imageEdge2G-imageEdge2B).^2) );
shift3R = sum( sum( ( imageEdge3G-imageEdge3R).^2) );
shift3B = sum( sum( ( imageEdge3G-imageEdge3B).^2) );
shift1VR = 0; % Shift vertical value pass 1
shift1HR = 0; % Shift horizontal value pass 1
shift1VB = 0; % Shift vertical value pass 1
shift1HB = 0; % Shift horizontal value pass 1
shift2VR = 0; % Shift vertical value pass 2
shift2HR = 0; % Shift horizontal value pass 2
shift2VB = 0; % Shift vertical value pass 2
shift2HB = 0; % Shift horizontal value pass 2
shift3VR = 0; % Shift vertical value pass 3
shift3HR = 0; % Shift horizontal value pass 3
shift3VB = 0; % Shift vertical value pass 3
shift3HB = 0; % Shift horizontal value pass 3
% Loop all possible translation coordinates pass 1
for i = -h:h
    for j = -w:w
        % Shift value
        shift = sum( sum( ( imageEdge1G-circshift( imageEdge1R, [i, j] ) ).^2) );
        % If new shift value is less than current shift value
        % Then set new shift horizontal & vertical values
        if shift < shift1R
            shift1R = shift;
            shift1VR = i;
            shift1HR = j;
        end
        % Shift value
        shift = sum( sum( ( imageEdge1G-circshift( imageEdge1B, [i, j] ) ).^2) );
        % If new shift value is less than current shift value
        % Then set new shift horizontal & vertical values
        if shift < shift1B
            shift1B = shift;
            shift1VB = i;
            shift1HB = j;
        end
    end
end
h = ceil( h/2 ); % Height / 2 (round up)
w = ceil( w/2 ); % Width / 2 (round up)
% Loop all possible translation coordinates pass 2
for i = -h:h
    for j = -w:w
        % Shift value
        shift = sum( sum( ( imageEdge2G-circshift( imageEdge2R, [shift1VR+i, shift1HR+j] ) ).^2) );
        % If new shift value is less than current shift value
        % Then set new shift horizontal & vertical values
        if shift < shift2R
            shift2R = shift;
            shift2VR = i;
            shift2HR = j;
        end
        % Shift value
        shift = sum( sum( ( imageEdge2G-circshift( imageEdge2B, [shift1VB+i, shift1HB+j] ) ).^2) );
        % If new shift value is less than current shift value
        % Then set new shift horizontal & vertical values
        if shift < shift2B
            shift2B = shift;
            shift2VB = i;
            shift2HB = j;
        end
    end
end
h = ceil( h/2 ); % Height / 2 (round up)
w = ceil( w/2 ); % Width / 2 (round up)
% Loop all possible translation coordinates pass 3
for i = -h:h
    for j = -w:w
        % Shift value
        shift = sum( sum( ( imageEdge3G-circshift( imageEdge3R, [shift2VR+i, shift2HR+j] ) ).^2) );
        % If new shift value is less than current shift value
        % Then set new shift horizontal & vertical values
        if shift < shift3R
            shift3R = shift;
            shift3VR = i;
            shift3HR = j;
        end
        % Shift value
        shift = sum( sum( ( imageEdge3G-circshift( imageEdge3B, [shift2VB+i, shift2HB+j] ) ).^2) );
        % If new shift value is less than current shift value
        % Then set new shift horizontal & vertical values
        if shift < shift3B
            shift3B = shift;
            shift3VB = i;
            shift3HB = j;
        end
    end
end

% Shift Images
% Shifts the red & blue images to align with the green image.
imageOriginalR = imageR;
imageOriginalB = imageB;
imageR = circshift( imageR, [shift3VR, shift3HR] ); % Shifts image
imageB = circshift( imageB, [shift3VB, shift3HB] ); % Shifts image

% Display Colour Original & Colour Aligned Images
% Creates the colour images and 2 figures for the colour original and
% colour aligned images.
imageOriginal = cat( 3, imageOriginalR, imageG, imageOriginalB );
image = cat( 3, imageR, imageG, imageB );
figure( 'Name', 'Colour Original', 'NumberTitle', 'off' );
imshow( imageOriginal );
figure( 'Name', 'Colour Aligned', 'NumberTitle', 'off' );
imshow( image );

end