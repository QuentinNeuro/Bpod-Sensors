% Sensors Project

animalName = BpodSystem.GUIdata.SubjectName

%% Don't do anything if Dummy Subject
if regexp(animalName, 'Dummy')
    return
end

%% Pop up surveys/reminders/instructions

% Remind user to clean up
msgbox({'Stop Bonsai' 'Switch off photodetectors'}, 'Please remember to:', 'warn')

% Initiate GDocs survey
surveyLink = 'https://docs.google.com/forms/d/e/1FAIpQLSdg4kv6s4wTSwCwDNBg8obF0-nFfm-HpvFJBaa2kcWigvgSeA/viewform?usp=sf_link';
web(surveyLink, '-browser')


