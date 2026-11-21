% Create a movie from images 
% Each image is displayed for frameRate/ second in the movie.
ResultsPath = {"BehaviorSpaceResults\MovieFrames-V10T31-019-A1-080826-1Rep","BehaviorSpaceResults\MovieFrames-V10T31-015-C1-080826-1Rep","BehaviorSpaceResults\MovieFrames-V10T31-015-D1-080826-1Rep"};
ResultsString = {"A","C","D"};
for i = 1:length(ResultsString)
    imageFolder = string(ResultsPath(i));           % Folder containing the images
    outputVideo = 'worldMovie'+ string(ResultsString(i)) + '.mp4';
    
    % Video settings
    frameRate = 30;               % 1 frame per second => each image lasts 1 second
    
    v = VideoWriter(outputVideo, 'MPEG-4');
    v.FrameRate = frameRate;
    open(v);
    finalFrame=52*24*7;

    % repeat the first frame for the entire first second of the video
    for j = 1:frameRate
        filename = fullfile(imageFolder, 'worldBefore-1.png');

        if ~isfile(filename)
            warning('File not found: %s', filename);
            continue;
        end
    
        img = imread(filename);
    
        % Convert image to movie frame
        frame = im2frame(img);
        
        % Write frame to video
        writeVideo(v, frame);
    end
    % loop through all the frames for each tick     
    for k = 1:finalFrame
        filename = fullfile(imageFolder, sprintf('world_time_%d.png', k));
        if ~isfile(filename)
            warning('File not found: %s', filename);
            continue;
        end
    
        img = imread(filename);
    
        % Convert image to movie frame
        frame = im2frame(img);
        
        % Write frame to video
        writeVideo(v, frame);
    end
    % repeat the final frame for the entire last second of the video
    k = finalFrame;
    for j = 1:frameRate
        filename = fullfile(imageFolder, sprintf('world_time_%d.png', k));

        if ~isfile(filename)
            warning('File not found: %s', filename);
            continue;
        end
    
        img = imread(filename);
    
        % Convert image to movie frame
        frame = im2frame(img);
        
        % Write frame to video
        writeVideo(v, frame);
    end
    
    close(v);
    
    fprintf('Movie saved as %s\n', outputVideo);
end