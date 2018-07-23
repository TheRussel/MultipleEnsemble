
 
 
 
% Multiple Ensemble Code
 
% At the start of the experiment, the user will input
% their initials so we can store data alongside their
% participants. Then, a window will open. For any given
% trial, a set of faces will be shown at set spots on
% the screen for a set amount of time (1s). For the
% first N trials, we show the faces, then ask for 1
% aspect (average emotion, gender, or race) of the set.
% Then, for the next N trials, we ask for 2 aspects of
% the set, and so on up to M aspects. Thus, the total
% amount of trials will be N*M. The user will input
% their response by typing a number 1-10 (key 0 will
% correspond to 10), where the endpoints on the scale
% will be told (i.e. african american to caucasian,
% sad to happy). Sets of 1 face will also be mixed
% in with larger sets.
 
 
clear all;
close all;
clc;
 
try
    
    % Setup for rest of experiment.
    int = input('Participant Initial: ', 's');
    nameID = upper(int);
    
    current = pwd();
    
    if ~isfolder(strcat(strcat(current,'/Participant_Data/'),nameID))
        mkdir(strcat(strcat(current,'/Participant_Data/'),nameID));
    end
    
    Screen('Preference', 'SkipSyncTests', 1);
    [window, rect] = Screen('OpenWindow', 0);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor();
    
    window_w = rect(3);
    window_h = rect(4);
 
    KbName('UnifyKeyNames');
    
    cd('./UCB_Stimuli');
    image_data = csvread('UCB_Stimuli.csv');
    raw_textures = [];
    
    for i = 1:200
        tmp_bmp = imread([num2str(i) '.png']);
        raw_textures(i) = Screen('MakeTexture', window, uint8(tmp_bmp));
    end
 
    %% Creating Grid Positions
    xStart = window_w*0.25;
    xEnd = window_w*0.75;
    yStart = window_h*(1/3);
    yEnd = window_h*(2/3);
    nRows = 2;
    nCols = 3;
    numSecs = 1;
    h_img = 250;
    w_img = 250;
    
    % enter in your starting and ending coordinates and how many rows and
    % columns you want in your grid pattern
 
    [x,y] = meshgrid(linspace(xStart ,xEnd ,nCols), ...
    linspace(yStart ,yEnd ,nRows));
    % this will output the x & y coordinates in a symmetrical grid pattern
 
    % combining all the positions into one matrix
    xy_rect = [x(:)'-w_img/2; y(:)'-h_img/2; x(:)'+w_img/2; y(:)'+h_img/2];
 
    
    for num_of_aspects = 1:3
        for trial_num = 1:50
            faces_shown = floor(randperm(200, 6));
            
            avg_values = zeros(1,3);
            for face_number = 1:6
                avg_values(1) = avg_values(1)+image_data(faces_shown(face_number),1);
                avg_values(2) = avg_values(2)+image_data(faces_shown(face_number),2);
                avg_values(3) = avg_values(3)+image_data(faces_shown(face_number),3);
            end
            avg_values(:) = avg_values(:)/6;
 
 
            Screen('DrawTextures', window,...       
            raw_textures(faces_shown), [], xy_rect);
            Screen('Flip', window);
            WaitSecs(numSecs);
            
            mask_mem = (rand(floor(window_w/4), floor(window_h/4))-1)*255;
	      %mask_mem = resizem(255.*round(rand(rect(4)/10, rect(3)/10)), [rect(4), rect(3)]);
            mask_mem_Tex = Screen('MakeTexture', window, mask_mem);  % make the mask_memory texture
            Screen('DrawTexture', window, mask_mem_Tex, [], [0, 0, window_w, window_h]); % draw the noise texture
            Screen('Flip',window);
            WaitSecs(numSecs);
            
            if num_of_aspects == 1
                Screen('DrawText', window,'What is the average race of the crowd?',window_h/2,window_w/2,[255 0 255]);
            elseif num_of_aspects == 2
                Screen('DrawText', window,'What is the average race and gender of the crowd?',window_h/2,window_w/2,[255 0 255]);
            else
                Screen('DrawText', window,'What is the average race, gender, and emotion of the crowd?',window_h/2,window_w/2,[255 0 255]);
            end
            Screen('Flip',window);
            KbWait;
        end
    end
catch
    Screen('CloseAll');
    rethrow(lasterror);
end
Screen('CloseAll');
