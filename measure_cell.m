% note that the number of frames is inconsistent with the reported length of experiment;
% (287-1 frames)(5 frames/s) \neq 15 min

% read each frame of mp4 file into grayscale matrix

vidObj = VideoReader('9530_web.mp4');

frameRate = vidObj.FrameRate;
numFrames = vidObj.NumFrames;
frames = cell(numFrames, 1);

k = 1;
while hasFrame(vidObj)
    frame = readFrame(vidObj);
    frames{k} = rgb2gray(frame);
    k = k + 1;
end

% initialize parameters
fudgeFactor = 0.40;
se1 = strel('disk', 12);
se2 = strel('disk', 3);
se3 = strel('disk', 4);

% write video with outline
vidObj = VideoWriter('Yao_optional_part1.mp4', 'MPEG-4');
vidObj.FrameRate = frameRate;

open(vidObj);

for i = 1:numFrames
    I = frames{i};
    
    % detect cell against background
    [~, threshold] = edge(I, 'sobel');
    BWs = edge(I, 'sobel', threshold*fudgeFactor);
    
    % fill in holes and blur edges
    BWsdil = imdilate(BWs, se1);
    BWdfill = imfill(BWsdil, 'holes');
    BWdfill = imerode(BWdfill, se3);
    BWdfill = imerode(BWdfill, se3);
    
    % remove connected objects
    BWnobord = imclearborder(BWdfill, 4);

    % blur edges
    BWfinal = imerode(BWnobord, se3);
    BWfinal = imerode(BWfinal, se3);
    BWfinal = imerode(BWfinal, se3);

    if ~all(BWfinal(:) == 0)
        % keep only regions with area greater than 1000 for label
        cc = bwconncomp(BWfinal);
        stats = regionprops(cc, 'Area');
        keep = find([stats.Area] > 1000);
        BWfinal = false(size(BWfinal));
    
        for idx = keep
            BWfinal(cc.PixelIdxList{idx}) = true;
        end
    
        s = regionprops(BWfinal, 'centroid');
        centroids = cat(1, s.Centroid);

        % outline object in original image
        BWoutline = bwperim(BWfinal);
        BWoutline = imdilate(BWoutline, se2);
    end

    Segout = I;
    Segout(BWoutline) = 255;
    
    % add label
    Segout = insertText(Segout, centroids, 'CHO K1 Cell');

    % add title
    area = stats.Area;
    area = area(keep);
    title = [ 'Frame: ', num2str(i-1), '. Time: ', num2str(5*i-5), ' s. Area: ', num2str(floor(0.1073*area)), ' microns.'];
    Segout = insertText(Segout, [50, 50], title);

    writeVideo(vidObj, Segout);
end

close(vidObj);