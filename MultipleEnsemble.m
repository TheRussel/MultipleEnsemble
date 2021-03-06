
 
 
 
%Multiple Ensemble Code
 
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
 
% Clear the command line and workspace before running the rest of the
% program. Also, shuffle the random number generator so each experiment is
% not predictable.
clear all;
close all;
clc;
rng('shuffle');
 
try
    
    %% Initialization
    
    % Get initials of participant, will later write data to folder named by
    % user's initials.
    int = input('Participant Initial: ', 's');
    nameID = upper(int);
    
    % Get the current directory and create a folder for the partipant data
    % if it does not already exist.
    current = pwd();
    if ~isfolder(strcat(strcat(current,'/Participant_Data/'),nameID))
        mkdir(strcat(strcat(current,'/Participant_Data/'),nameID));
    end
    
    % Create the window, allow transparency, and hide the mouse.
    Screen('Preference', 'SkipSyncTests', 1);
    [window, rect] = Screen('OpenWindow', 0);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor();
    
    % Initialize the window dimensions.
    window_w = rect(3);
    window_h = rect(4);
    
    % Unify keyboard keys across all platforms, program can be run on
    % windows or mac.
    KbName('UnifyKeyNames');
    
    % Get the metadata for the stimuli images.
    cd('./UCB_Stimuli');
    image_data = csvread('UCB_Stimuli.csv');
    raw_textures = [];
    
    % Initialize and store all the textures of the stimuli.
    for i = 1:200
        tmp_bmp = imread([num2str(i) '.png']);
        raw_textures(i) = Screen('MakeTexture', window, uint8(tmp_bmp));
    end
    
    % Goes back out to folder of the program.
    cd('../');
    
    % Cat images are loaded into catex and catex2
    cat = imread('cat thing.jpg');
    catex = Screen('MakeTexture', window, uint8(cat));
    cat2 = imread('congrats.jpeg');
    catex2 = Screen('MakeTexture', window, uint8(cat2));
    
    % the input keys image is loaded
    key_im = imread('key_im.png');
    keytex = Screen('MakeTexture', window, uint8(key_im));
    [key_w, key_h, na] = size(key_im);
    
    % Gives instructions to user
    enabled_keys = [40];
    DisableKeysForKbCheck(setdiff([1:256], [enabled_keys]));
    
    Screen('DrawText', window,'The experiment will present faces then ask questions based on the faces shown.',window_h/2-150,window_w/2-400);
    Screen('DrawText', window,'Answer the questions on a scale 1-10 with 0 representing 10.',window_h/2-50,window_w/2-300);
    Screen('DrawText', window,'Press enter to continue.',window_h/2+150,window_w/2-200);
    rect = [(window_h/2+250)-key_h/2; (window_w/2)-key_w/2;(window_h/2+250)+key_h/2; (window_w/2)+key_w/2]
    Screen('DrawTexture', window, keytex, [], rect);
    Screen('Flip',window);
    
    KbWait;
    
    
    % Create the grid positions.
    xStart = window_w*0.25;
    xEnd = window_w*0.75;
    yStart = window_h*(1/3);
    yEnd = window_h*(2/3);
    nRows = 2;
    nCols = 3;
    numSecs = 1;
    h_img = 250;
    w_img = 250;
    [x,y] = meshgrid(linspace(xStart ,xEnd ,nCols), ...
        linspace(yStart ,yEnd ,nRows));
    xy_rect = [x(:)'-w_img/2; y(:)'-h_img/2; x(:)'+w_img/2; y(:)'+h_img/2];
    
    % Initialize the matrix where all the data will be written to.
    experiment_data = [];
    
    %% Run the trials
    
    % Run 150 trials, max 3 aspects tested, 50 trials for each aspect
    % number.
    for num_of_aspects = 1:3
        % Enable only the number keys.
        enabled_keys = [30 31 32 33 34 35 36 37 38 39];
        DisableKeysForKbCheck(setdiff([1:256], [enabled_keys]));
        
        showing_six = [0 1];
        showing_six = repmat(showing_six,25);
        
        for trial_num = 1:50
            
            %% Initialize the face(s)
            
            % Determine whether 1 or 6 face(s) will be shown.
            face_shown = 0;
            if (showing_six(1,trial_num) == 0)
                face_shown = randi(6);
            end
            
            % Determine which face(s) will be shown.
            faces_shown = floor(randperm(200, 6));
            
            % Determine the correct values for each aspect.
            avg_values = zeros(1,3);
            for face_number = 1:6
                avg_values(1) = avg_values(1)+image_data(faces_shown(face_number),1);
                avg_values(2) = avg_values(2)+image_data(faces_shown(face_number),2);
                avg_values(3) = avg_values(3)+image_data(faces_shown(face_number),3);
            end
            avg_values(:) = avg_values(:)/6;
            
            %% Draw the face(s) & mask
            
            % Draw the face(s).
            if (showing_six(1,trial_num) == 1)
                Screen('DrawTextures', window,...
                    raw_textures(faces_shown), [], xy_rect);
            else
                Screen('DrawTexture', window, raw_textures(faces_shown(face_shown)));
            end
            Screen('Flip', window);
            
            % Show the face(s) for numSecs amount of seconds.
            WaitSecs(numSecs);
            
            % Create and show the mask.
            mask_mem = (rand(floor(window_w/4), floor(window_h/4))-1)*255;
            mask_mem = resizem(255.*round(rand(floor(rect(4)/10), floor(rect(3)/10))), [rect(4), rect(3)]);
            mask_mem_Tex = Screen('MakeTexture', window, mask_mem);  % make the mask_memory texture
            Screen('DrawTexture', window, mask_mem_Tex, [], [0, 0, window_w, window_h]); % draw the noise texture
            Screen('Flip',window);
            WaitSecs(numSecs);
            
            %% Ask the user about aspects of the crowd
            
            % Determine which aspects will be questioned about.
            aspects_tested = randperm(3);
            aspects_tested = aspects_tested(1:num_of_aspects);
            
            % Initialize the response and time matrices.
            responses = zeros(1, 3);
            times = zeros(1, 3);
            
            % Ask about 1, 2, or 3 aspects.
            for aspect_num = 1:length(aspects_tested)
                
                % Draw the questions.
                if (aspects_tested(aspect_num) == 1)
                    Screen('DrawText', window,'What was the average race of the crowd?',window_h/2,window_w/2-350);
                    Screen('DrawText', window,'Rate 1-10 with the number keys (Key 0 is 10). 1 is African American, 10 is Caucasian.',window_h/2-200,window_w/2-250);
                elseif (aspects_tested(aspect_num) == 2)
                    Screen('DrawText', window,'What was the average gender of the crowd?',window_h/2,window_w/2-350);
                    Screen('DrawText', window,'Rate 1-10 with the number keys (Key 0 is 10). 1 is Male, 10 is Female.',window_h/2-150,window_w/2-250);
                elseif (aspects_tested(aspect_num) == 3)
                    Screen('DrawText', window,'What was the average emotion of the crowd?',window_h/2,window_w/2-350);
                    Screen('DrawText', window,'Rate 1-10 with the number keys (Key 0 is 10). 1 is Neutral, 10 is Happy.',window_h/2-150,window_w/2-250);
                end
                
                Screen('Flip',window);
                
                % Initialize the clock (timing the response) and record the
                % user's response.
                t0 = clock;
                key_number = 29;
                KbWait;
                while key_number < 30 || key_number > 39
                    key_number = 29;
                    [keyIsDown,seconds,keyCode] = KbCheck(-1);
                    while key_number <= 39 && keyCode(key_number) == 0
                        key_number = key_number+1;
                    end
                end
                response = key_number-29;
                responses(1, aspects_tested(aspect_num)) = response;
                while keyIsDown == 1
                    [keyIsDown,seconds,keyCode] = KbCheck(-1);
                end
                
                % Clear the window and end the timer.
                Screen('Flip',window);
                time = (round(etime(clock,t0) * 1000));
                times(aspects_tested(aspect_num)) = time;
            end
            
            %% Record the data
            
            % Assemble all the data for the trial and add it to the
            % master matrix.
            trial_data = horzcat(horzcat(horzcat(horzcat(responses, avg_values*9+1), faces_shown), times), face_shown);
            if (num_of_aspects == 0 && trial_num == 0)
                experiment_data = trial_data;
            else
                experiment_data = vertcat(experiment_data, trial_data);
            end
        end
        
        if num_of_aspects == 3
            Screen('DrawTexture', window, catex2);
        else
            Screen('DrawTexture', window, catex);
        end
        
        Screen('DrawText', window,'Press enter to continue.',window_h/2+150,window_w/2);
        
        Screen('Flip',window);
        
        enabled_keys = [40];
        DisableKeysForKbCheck(setdiff([1:256], [enabled_keys]));
        
        KbWait;
        
    end
    
    %% Write the data
    
    % Write the data to Results.mat.
    cd(strcat(strcat(current,'/Participant_Data/'),nameID));
    save('Results.mat', 'experiment_data');
    cd('../');
catch
    Screen('CloseAll');
    rethrow(lasterror);
end
Screen('CloseAll');
 
 
 




