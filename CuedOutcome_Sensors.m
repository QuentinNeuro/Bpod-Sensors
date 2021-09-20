function CuedOutcome_Sensors
%Functions used in this protocol:
%"CuedReward_Phase": specify the phase of the training
%"WeightedRandomTrials" : generate random trials sequence

%"Online_LickPlot"      : initialize and update online lick and outcome plot
%"Online_LickEvents"    : extract the data for the online lick plot
%"Online_NidaqPlot"     : initialize and update online nidaq plot
%"Online_NidaqEvents"   : extract the data for the online nidaq plot

global BpodSystem nidaq S

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
ParamPC=BpodParam_PCdep();
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    CuedOutcome_Sensors_TaskParameters(ParamPC);
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

%% Outcome
S.SmallRew  =   GetValveTimes(S.GUI.SmallReward, S.GUI.RewardValve);
S.InterRew  =   GetValveTimes(S.GUI.InterReward, S.GUI.RewardValve);
S.LargeRew  =   GetValveTimes(S.GUI.LargeReward, S.GUI.RewardValve);

%% Define stimuli and send to sound server
CueA=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.CueA,1,1,S.GUI.CueDuration,0);
CueB=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.CueB,1,1,S.GUI.CueDuration,0);
CueC=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.CueC,1,1,S.GUI.CueDuration,0);
CueD=SoundGenerator(S.GUI.SoundSamplingRate,S.GUI.CueD,1,1,S.GUI.CueDuration,0);
NoCue=zeros(1,S.GUI.CueDuration*S.GUI.SoundSamplingRate);
        
PsychToolboxSoundServer('init');
PsychToolboxSoundServer('Load', 1, CueA);
PsychToolboxSoundServer('Load', 2, CueB);
PsychToolboxSoundServer('Load', 3, CueC);
PsychToolboxSoundServer('Load', 4, CueD);
PsychToolboxSoundServer('Load', 5, NoCue);

BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

%% Define trial types parameters, trial sequence and Initialize plots
[S.TrialsNames, S.TrialsMatrix]=CuedOutcome_Sensors_Phase(S,S.Names.Phase{S.GUI.Phase});
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
S.NumTrialTypes=max(TrialSequence);

FigLick=Online_LickPlot('ini',TrialSequence);
%% NIDAQ Initialization amd Plots
if S.GUI.Photometry || S.GUI.Wheel
    if (S.GUI.DbleFibers+S.GUI.Isobestic405+S.GUI.RedChannel)*S.GUI.Photometry >1
        disp('Error - Incorrect photometry recording parameters')
        return
    end
    Nidaq_photometry('ini',ParamPC);
end
[FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots('ini');

%% Bonsai
if S.GUI.Bonsai
    BpodSystem.Pause=1;
    disp('Adjust ROI  - resume when ready');
    success=Bpod2Bonsai_Sensors()
    HandlePauseCondition;
end
%% Main trial loop
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
for currentTrial = 1:S.GUI.MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
    
%% Initialize current trial parameters
	S.Cue       =	S.TrialsMatrix(TrialSequence(currentTrial),3);
	S.Delay     =	S.TrialsMatrix(TrialSequence(currentTrial),4)+(S.GUI.DelayIncrement*(currentTrial-1));
	S.Valve     =	S.TrialsMatrix(TrialSequence(currentTrial),5);
	S.Outcome   =   S.TrialsMatrix(TrialSequence(currentTrial),6);

    if S.GUI.Phase==3 % L3-SecondaryCue
        S.Cue              =   3;
        S.ExtraDelay       =   S.TrialsMatrix(TrialSequence(currentTrial),4);
        S.ExtraCueDuration =   S.GUI.CueDuration;
        S.ExtraCue         =   S.TrialsMatrix(TrialSequence(currentTrial),3);
    else
        S.ExtraDelay       =   0;
        S.ExtraCueDuration =   0;
        S.ExtraCue         =   0;  
    end
    
    S.ITI = 100;
    while S.ITI > 6 * S.GUI.ITI
        S.ITI = exprnd(S.GUI.ITI);
    end
  
%% Assemble State matrix
 	sma = NewStateMatrix();
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',S.ITI,...
        'StateChangeConditions', {'Tup', 'PreState'},...
        'OutputActions',{});
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','CueDelivery'},...
        'OutputActions',{'BNCState',1});
    %Cue
    sma=AddState(sma,'Name', 'CueDelivery',...
        'Timer',S.GUI.CueDuration,...
        'StateChangeConditions',{'Tup', 'Delay'},...
        'OutputActions', {'SoftCode',S.Cue});
    %Delay
    sma=AddState(sma,'Name', 'Delay',...
        'Timer',S.Delay,...
        'StateChangeConditions',{'Tup', 'ExtraCueDelivery'},...
        'OutputActions',{});
    %Extra Cue for L3-SecondaryCue
    sma=AddState(sma,'Name', 'ExtraCueDelivery',...
        'Timer',S.ExtraCueDuration,...
        'StateChangeConditions', {'Tup', 'ExtraDelay'},...
        'OutputActions', {'SoftCode',S.ExtraCue});
    %Extra Delay for L3-SecondaryCue
    sma=AddState(sma,'Name', 'ExtraDelay',...
        'Timer',S.ExtraDelay,...
        'StateChangeConditions',{'Tup', 'Outcome'},...
        'OutputActions',{});
    %Reward
    sma=AddState(sma,'Name', 'Outcome',...
        'Timer',S.Outcome,...
        'StateChangeConditions', {'Tup', 'PostOutcome'},...
        'OutputActions', {'ValveState', S.Valve});  
    %Post task states
    sma=AddState(sma,'Name', 'PostOutcome',...
        'Timer',S.GUI.PostOutcome,...
        'StateChangeConditions',{'Tup', 'exit'},...
        'OutputActions',{});
    SendStateMatrix(sma);
 
%% NIDAQ Get nidaq ready to start
if S.GUI.Photometry || S.GUI.Wheel
    Nidaq_photometry('WaitToStart');
end
     RawEvents = RunStateMatrix;
    
%% NIDAQ Stop acquisition and save data in bpod structure
if S.GUI.Photometry || S.GUI.Wheel
    Nidaq_photometry('Stop');
    [PhotoData,WheelData,Photo2Data]=Nidaq_photometry('Save');
    if S.GUI.Photometry
        BpodSystem.Data.NidaqData{currentTrial}=PhotoData;
        if S.GUI.DbleFibers || S.GUI.RedChannel
            BpodSystem.Data.Nidaq2Data{currentTrial}=Photo2Data;
        end
    end
    if S.GUI.Wheel
        BpodSystem.Data.NidaqWheelData{currentTrial}=WheelData;
    end
end

%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
end

%% PLOT - extract events from BpodSystem.data and update figures
try
[currentOutcome, currentLickEvents]=Online_LickEvents(S.Names.StateToZero{S.GUI.StateToZero});
FigLick=Online_LickPlot('update',[],FigLick,currentOutcome,currentLickEvents);
[FigPhoto1,FigPhoto2,FigWheel]=Nidaq_Plots('update',FigPhoto1,FigPhoto2,FigWheel,'PreState',currentLickEvents);
catch
    disp('Oups, something went wrong with the online analysis... May be you closed a plot ?') 
end

%% Photometry QC
if currentTrial==1 && S.GUI.Photometry
    thismax=max(PhotoData(S.GUI.NidaqSamplingRate:S.GUI.NidaqSamplingRate*2,1))
    if thismax>4 || thismax<0.5
        disp('WARNING - Something is wrong with fiber #1 - run check-up! - unpause to ignore')
        BpodSystem.Pause=1;
        HandlePauseCondition;
    end
    if S.GUI.DbleFibers
    thismax=max(Photo2Data(S.GUI.NidaqSamplingRate:S.GUI.NidaqSamplingRate*2,1))
    if thismax>4 || thismax<0.5
        disp('WARNING - Something is wrong with fiber #2 - run check-up! - unpause to ignore')
        BpodSystem.Pause=1;
        HandlePauseCondition;
    end
    end
end

%% End of trial
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.BeingUsed == 0
    return
end
end
%% Add killer script + sarah's behavior QC code here + Quick Analysis
try
    ChannelNames={'BLA' 'VS'};
    AP_Launcher_PostRec(BpodSystem,ChannelNames)
    % Figure handle is in Analysis.Figure.PostRec
%     AP_Sensors_Evernote(Analysis,FigLick.water) authentification error
catch
    disp('Post recording analysis failed - check whether analysis pipeline is present')
end
end
