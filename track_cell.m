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

conversion = 50 / 21;
centroidhistory = zeros(1, 1024);

vidObj = VideoWriter('Yao_optional_part2c.mp4', 'MPEG-4');
vidObj.FrameRate = frameRate;

open(vidObj);

tracknumber = 22;

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

    label = cellarea > 1;
    numObjects = 1:numObjects;
    numObjects = numObjects(label);

    % for j = numObjects
    %     I = insertText(I, [cellcentroid(2*j-1), cellcentroid(2*j)], num2str(floor(conversion*cellarea(j))));
    % end

    % for j = numObjects
    %     I = insertText(I, [cellcentroid(2*j-1), cellcentroid(2*j)], num2str(j));
    % end

    if i == 1
        trackcentroid = [cellcentroid(tracknumber*2-1), cellcentroid(tracknumber*2)];
        centroidhistory(1:2) = trackcentroid;
    end

    x = centroidhistory(2*i-1);
    y = centroidhistory(2*i);

    distance2 = zeros(1, size(numObjects, 2));
    for j = numObjects
        xdistance = cellcentroid(2*j-1) - x;
        ydistance = cellcentroid(2*j) - y;
        distance2(j) = xdistance^2 + ydistance^2;
    end

    [~, closest] = min(distance2);
    newcentroid = [cellcentroid(2*closest-1), cellcentroid(2*closest)];
    centroidhistory(2*i+1:2*i+2) = newcentroid;
    
    dx = centroidhistory(2*i+1) - x;
    dy = centroidhistory(2*i+2) - y;
    ds2 = dx^2 + dy^2;

    if ds2 >= 256
        if i <= 2
            xpredicted = 2*centroidhistory(2*i-1) - centroidhistory(2*i-3);
            ypredicted = 2*centroidhistory(2*i) - centroidhistory(2*i-2);
        elseif i <= 3
            xpredicted = centroidhistory(2*i-1) + (3*centroidhistory(2*i-1) - 4*centroidhistory(2*i-3) + centroidhistory(2*i-5)) / 2;
            ypredicted = centroidhistory(2*i) + (3*centroidhistory(2*i) - 4*centroidhistory(2*i-2) + centroidhistory(2*i-4)) / 2;
        else
            xpredicted = centroidhistory(2*i-1) + 11/6*centroidhistory(2*i-1) - 3*centroidhistory(2*i-3) + 3/2*centroidhistory(2*i-5) - 1/3*centroidhistory(2*i-7);
            ypredicted = centroidhistory(2*i) + 11/6*centroidhistory(2*i) - 3*centroidhistory(2*i-2) + 3/2*centroidhistory(2*i-4) - 1/3*centroidhistory(2*i-6);
        end
        centroidhistory(2*i+1:2*i+2) = [xpredicted, ypredicted];
    end
    I = insertText(I, centroidhistory(2*i+1:2*i+2), num2str(tracknumber));

    title = [ 'Frame: ', num2str(i-1), '. Number of Cells: ' num2str(size(numObjects, 2))];
    I = insertText(I, [0, 0], title);

    writeVideo(vidObj, I);
end

% for i = 3:numFrames
%     I = frames{i};
%     I = I - (I - text);
% 
%     background = imopen(I, se1);
% 
%     I = I - background;
% 
%     I = imadjust(I);
% 
%     bw = imbinarize(I);
% 
%     BWsdil = imdilate(bw, se2);
%     BWdfill = imfill(BWsdil, 'holes');
%     BWdfill = imerode(BWdfill, se3);
% 
%     bw = bwareaopen(BWdfill, 8);
% 
%     cc = bwconncomp(bw, 4);
% 
%     numObjects = cc.NumObjects;
% 
%     celldata = regionprops(cc, 'basic');
%     cellarea = [celldata.Area];
%     cellcentroid = [celldata.Centroid];
% 
%     I = frames{i};
% 
%     label = cellarea > 4;
%     numObjects = 1:numObjects;
%     numObjects = numObjects(label);
% 
%     xpredicted = centroidhistory(2*i-1) + (3*centroidhistory(2*i-1) - 4*centroidhistory(2*i-3) + centroidhistory(2*i-5)) / 2;
%     ypredicted = centroidhistory(2*i) + (3*centroidhistory(2*i) - 4*centroidhistory(2*i-2) + centroidhistory(2*i-4)) / 2;
% 
%     distance2 = zeros(1, size(numObjects, 2));
%     for j = numObjects
%         xdistance = cellcentroid(2*j-1) - xpredicted;
%         ydistance = cellcentroid(2*j) - ypredicted;
%         distance2(j) = xdistance^2 + ydistance^2;
%     end
% 
%     [~, closest] = min(distance2);
%     newcentroid = [cellcentroid(2*closest-1), cellcentroid(2*closest)];
%     centroidhistory(2*i+1:2*i+2) = newcentroid;
% 
%     dx = centroidhistory(2*i+1) - xpredicted;
%     dy = centroidhistory(2*i+2) - ypredicted;
%     ds2 = dx^2 + dy^2;
% 
%     if ds2 <= 128
%         I = insertText(I, newcentroid, num2str(floor(conversion*cellarea(closest))));
%     else
%         centroidhistory(2*i+1:2*i+2) = [xpredicted, ypredicted];
%     end
% 
%     title = [ 'Frame: ', num2str(i-1), '. Number of Cells: ' num2str(size(numObjects, 2))];
%     I = insertText(I, [0, 0], title);
% 
%     writeVideo(vidObj, I);
% end

close(vidObj);