function randomOdorPresentation(numberOfTrials,varargin)



for i = 1 : length(numberOfTrials)
    
    currentOdor = ceil(rand*length(smell.olfactometerOdors.sessionOdors));
    trialOdor = smell.olfactometerOdors.sessionOdors(currentOdor);
    buildSmell('updateFields',[],trialOdor,i,'randomOdorPresentation',[],'trialOdor')
    
    
end

end