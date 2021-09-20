function success =Bpod2Bonsai_Sensors()
global BpodSystem S
%% Bonsai exe and protocol location
bonsaiEXE_Path='C:\Users\kepecs\AppData\Local\Bonsai\Bonsai32.exe';
bonsaiPro_Path='C:\Users\kepecs\Documents\Data\Sensors\Bonsai\Pupillometry_trigger.bonsai';
%% From Bpod
DataPath=BpodSystem.DataPath;
DataPath_split=strsplit(DataPath,filesep);
FileName=DataPath_split{end}(1:end-4);
SessionNb=FileName(end-7:end);
ProtoName=DataPath_split{end-2};
AnimalName=DataPath_split{end-3};
thisDate=datestr(now,'yyyymmdd');
trialDuration = 20;
trialDuration.Format = 'hh:mm:ss';
trialDuration = sprintf('%s', trialDuration);
%% Directory
bonsaiData_Path=fullfile('C:\Users\kepecs\Documents\Data\Sensors\Bonsai\',AnimalName);
mkdir(bonsaiData_Path);
bonsaiData_Path=fullfile(bonsaiData_Path,FileName);
mkdir(bonsaiData_Path);
%% Video file name
bonsaiData_Name=[AnimalName '_' thisDate '_.avi'];
%% Full path
bonsaiData_Full=fullfile(bonsaiData_Path,bonsaiData_Name);
%% start Bonsai
success = startBonsai(bonsaiEXE_Path,bonsaiPro_Path,'FileName',bonsaiData_Full, 'TrialDuration', trialDuration);

end