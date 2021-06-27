function CuedOutcome_Sensors_TaskParameters(Param)
%
%
global S
    S.Names.Phase={'L1-CuedReward','L2-RewardSize','L3-SecondaryCue','V1-Probability','V2-Extinction','S-RewPun','Habituation','Habituation-Water'};
    S.Names.StateToZero={'PostOutcome','CueDelivery'};
    S.Names.Rig=Param.rig;

%% General Parameters    
    S.GUI.Phase = 7;
    S.GUIMeta.Phase.Style='popupmenu';
    S.GUIMeta.Phase.String=S.Names.Phase;
    S.GUIPanels.Task={'Phase'};
    
    S.GUI.Wheel=1;
    S.GUIMeta.Wheel.Style='checkbox';
    S.GUIMeta.Wheel.String='Auto';
 	S.GUI.Photometry=1;
    S.GUIMeta.Photometry.Style='checkbox';
    S.GUIMeta.Photometry.String='Auto';
    S.GUI.DbleFibers=1;
    S.GUIMeta.DbleFibers.Style='checkbox';
    S.GUIMeta.DbleFibers.String='Auto';
    S.GUI.Isobestic405=0;
    S.GUIMeta.Isobestic405.Style='checkbox';
    S.GUIMeta.Isobestic405.String='Auto';
    S.GUI.RedChannel=0;
    S.GUIMeta.RedChannel.Style='checkbox';
    S.GUIMeta.RedChannel.String='Auto';    
    S.GUIPanels.Recording={'Wheel','Photometry','DbleFibers','Isobestic405','RedChannel'};
    
    S.GUI.TimeMin=-4;
    S.GUI.TimeMax=4;
    S.GUI.NidaqMin=-5;
    S.GUI.NidaqMax=10;
    S.GUIPanels.Plot={'TimeMin','TimeMax','NidaqMin','NidaqMax'};
    
    S.GUITabs.General={'Plot','Recording','Task'};

%% Timing
    S.GUI.MaxTrials=100;
    S.GUI.PreCue=3;
    S.GUI.Delay=1;
    S.GUI.DelayIncrement=0;
    S.GUI.PostOutcome=4;
    S.GUI.ITI=8;
    S.GUIPanels.TaskTiming={'MaxTrials','PreCue','Delay','DelayIncrement','PostOutcome','ITI'};
    
    S.GUI.StateToZero=1;
	S.GUIMeta.StateToZero.Style='popupmenu';
    S.GUIMeta.StateToZero.String=S.Names.StateToZero;
    S.GUI.BaselineBegin=1.5;
    S.GUI.BaselineEnd=2.5;
    S.GUIPanels.PlotTiming={'StateToZero','BaselineBegin','BaselineEnd'};
    S.GUITabs.Timing={'TaskTiming','PlotTiming'};

%% Task Parameters  
    S.GUI.CueDuration=0.5;
    S.GUI.CueA=4000;
    S.GUI.CueB=20000;
    S.GUI.CueC=10000;
    S.GUI.CueD=15000;
	S.GUI.SoundSamplingRate=192000;
    S.GUIPanels.Cue={'CueDuration','CueA','CueB','CueC','CueD','SoundSamplingRate'};

    S.GUI.RewardValve=1;
    S.GUI.SmallReward=2;
    S.GUI.InterReward=5;
    S.GUI.LargeReward=8;
    S.GUI.PunishValve=2;
    S.GUI.PunishTime=0.2;
    S.GUI.OmissionValve=4;
    S.GUIPanels.Outcome={'RewardValve','SmallReward','InterReward','LargeReward','PunishValve','PunishTime','OmissionValve'};
    
    S.GUITabs.Task={'Outcome','Cue'};    
    
    
%% Nidaq and Photometry
    S.GUI.PhotometryVersion=1.0;
    S.GUI.Modulation=1;
    S.GUIMeta.Modulation.Style='checkbox';
    S.GUIMeta.Modulation.String='Auto';
	S.GUI.NidaqDuration=70;
    S.GUI.NidaqSamplingRate=6100;
    S.GUI.DecimateFactor=610;
    S.GUI.LED1_Name='Fiber1 470-BLA';
    S.GUI.LED1_Amp=Param.LED1Amp;
    S.GUI.LED1_Freq=211;
    S.GUI.LED2_Name='Fiber1 405 / 565';
    S.GUI.LED2_Amp=Param.LED2Amp;
    S.GUI.LED2_Freq=531;
    S.GUI.LED1b_Name='Fiber2 470-VS';
    S.GUI.LED1b_Amp=Param.LED1bAmp;
    S.GUI.LED1b_Freq=531;

    S.GUIPanels.Photometry={'PhotometryVersion','Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    S.GUITabs.Photometry={'Photometry'};
end
