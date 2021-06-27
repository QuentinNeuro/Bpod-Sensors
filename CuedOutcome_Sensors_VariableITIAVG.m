function NewNidaqDemod=CuedOutcome_Sensors_VariableITIAVG(NidaqDemod)
global BpodSystem S

%% Parameters
% DAQ
decimateFactor=S.GUI.DecimateFactor;
duration=S.GUI.NidaqDuration;
sampleRate=S.GUI.NidaqSamplingRate;
SRDecimated=sampleRate/decimateFactor;
ExpectedSize=duration*SRDecimated;
% Offset
StateZeroOffset='PreState';
ZeroOffset=BpodSystem.Data.RawEvents.Trial{1,end}.States.(StateZeroOffset)(1,1);
ZeroOffsetPoints=ceil(ZeroOffset*SRDecimated);

%% Shaving Data
NewNidaqDemod=NaN(ExpectedSize,3);
NewNidaqDemod(1:ExpectedSize-ZeroOffsetPoints+1,:)=NidaqDemod(ZeroOffsetPoints:end,:);
end