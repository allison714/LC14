function [texStr,stimData] = HowFastYouAreGoing(Q)

    % Created Mar 30 2019

    % This function tests flies' reading comprehension and their adherence
    % to traffic rules
    
    % this is to provide the general structure for the texture generating codes
    % to be used with PTB in this framework. 

    % NOTE: when you create a new stimulus function, you must update the
    % stimlookup table in the folder paramfiles. paramfiles will also hold the
    % text file giving lists of parameters that comprise an experiment

%%  This field contains parameters corresponding to the current epoch designated by the paramfile. In most of the existing stimulus functions this field is inserted into “p” like 
%   p = Q.stims.currParam
%   so that you can easily access your stimulus parameter like p.<parameter name>.
    p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
%   Q.timing stores timestamps in the unit of absolute time and frames. Usually, a stimulus function calculates how many frames deep into the epoch you are by doing
% 	f = Q.timing.framenumber - Q.timing.framelastchange + 1;
%   Some functions do not have +1 and thus counting frames with 0 indexing - beware.    
    f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
%%  Q.stims.stimData
%   This field is loaded as stimData and sent upstream to RunStimulus() 
%   as the second output argument of the stimulus function. As such, 
%   this field can be used as a “memory” for stimulus functions, 
%   which is useful when your stimulus is not entirely deterministic 
%   and some communication between each call of the stimulus function 
%   is necessary. For example, if you want to keep presenting a static 
%   random spatial pattern for many frames, you can generate the pattern 
%   in the first frame of the epoch and save it as something like 
%   stimData.mypattern. Then, in the following calls of the same function, 
%   you can access the pattern you generated in the first call by reading 
%   stimData.mypattern.    

%   Q.stims.stimData.cl, Q.stims.stimData.mat
%   These two reserved fields of Q.stims.stimData are 10 and 20 row matrices, 
%   respectively, and are saved into a stimData.mat file (through WriteStimData() 
%   called by RunStimulus()). The stimData.mat has 34 columns: First corresponding 
%   to time stamp, second to the total frame count, third to the current epoch 
%   number, and 4th through 13th to Q.stims.stimData.cl, 14th through 33rd to 
%   Q.stims.stimData.mat, and then flash state. The stimData.mat file is 
%   automatically loaded and passed to analysis functions if you run analyses 
%   using RunAnalysis(). The content of .cl and .mat are arbitrary (i.e. 
%   determined entirely by your stimulus function) but they are generally 
%   supposed to store internal variables related to closed loop (i.e. position 
%   of the fly in a virtual 2D world etc.) and state of visual stimuli 
%   (i.e. time trace of random noise stimuli).
    stimData = Q.stims.stimData;
    
    numDeg = p.numDeg;

    texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
    texStr.dim = 2; % or 2
    texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

    % 9/14 using numDeg = 1 - maybe go high reso?
    sizeX = round(360/p.numDeg);
%   Q.cylinder
%   This field contains the geometry of the virtual cylinder, and has 
%   cylinderRadius and cylinderHeight (which are respectively set to 
%   15 mm and 40 mm). The bitmap stimulus function is interpreted such 
%   that it wraps around a virtual cylinder around the fly. As a result, 
%   pixel-to-visual angle conversion requires some trigonometry involving 
%   these values if you are presenting 2D stimuli (if you hope to reduce 
%   the amount of distortion to off-equator stimuli -- you can’t really 
%   make this perfect as long as we are using a cylinder. See 
%   MultipleTargets.m for example to see what I ended up doing).
    sizeY = round(2*atand(Q.cylinder.cylinderHeight/2/Q.cylinder.cylinderRadius)/numDeg);
    
    %% Input parameters
    
    %% closed loop stuff
%   Q.flyloc / Q.flyTimeline
%   Q.flyloc stores raw reading form the mouse chip. Q.flyTimeline is a custom 
%   built FlyTimeline class variable that stores a delay-corrected version of 
%   Q.flyloc, so this should be the one used for generating closed loop stimuli.
    [flyTurningSpeed,flyWalkingSpeed,stimData] = GetFlyResponse(Q.timing.framenumber,Q.stims.duration,Q.flyTimeline.curFlyStates,stimData);
    leadFly = stimData.cl(1);
    
    %% things that concern the entire presentation
    
    fPU = p.framesPerUp;
    duration = p.duration; % frames
    mLum = p.mLum;
    
    %% Draw the bitmap

    RGB = insertText(zeros(sizeY,sizeX),[sizeX/2 sizeY/2],flyTurningSpeed(leadFly),'FontSize',24,'AnchorPoint','center');
    bitMap = repmat(RGB(:,:,1),[1,1,fPU]);
      
    bitMap =  mLum * ( 1 + bitMap );
    
    texStr.tex = CreateTexture(bitMap,Q);
end
