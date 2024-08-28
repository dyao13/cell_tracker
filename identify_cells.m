vidObj = VideoReader('24045_web.mp4');

frameRate = vidObj.FrameRate;
numFrames = vidObj.NumFrames;
frames = cell(numFrames, 1);

k = 1;
while hasFrame(vidObj)
    frame = readFrame(vidObj);
    frames{k} = rgb2gray(frame);
    k = k + 1;
end

text = readmatrix('text.csv');
text = uint8(text);

se1 = strel('disk', 3);
se2 = strel('disk', 5);
se3 = strel('disk', 3);

vidObj = VideoWriter('Yao_optional_part2ab.mp4', 'MPEG-4');
vidObj.FrameRate = frameRate;

open(vidObj);


for i = 1:numFrames
    I = frames{i};
    I = I - (I - text);
    
    background = imopen(I, se1);
    
    I = I - background;
    
    I = imadjust(I);
    
    bw = imbinarize(I);

    BWsdil = imdilate(bw, se2);
    BWdfill = imfill(BWsdil, 'holes');
    BWdfill = imerode(BWdfill, se3);

    bw = bwareaopen(BWdfill, 8);
    
    cc = bwconncomp(bw, 4);

    numObjects = cc.NumObjects;
    
    celldata = regionprops(cc, 'basic');
    cellarea = [celldata.Area];
    cellcentroid = [celldata.Centroid];

    I = frames{i};

    label = cellarea > 32;
    numObjects = 1:numObjects;
    numObjects = numObjects(label);

    for j = numObjects
        I = insertText(I, [cellcentroid(2*j-1), cellcentroid(2*j)], num2str(floor(conversion*cellarea(j))));
    end

    % for j = numObjects
    %     I = insertText(I, [cellcentroid(2*j-1), cellcentroid(2*j)], num2str(j));
    % end

    title = [ 'Frame: ', num2str(i-1), '. Number of Cells: ' num2str(size(numObjects, 2))];
    I = insertText(I, [0, 0], title);

    writeVideo(vidObj, I);
end

close(vidObj);