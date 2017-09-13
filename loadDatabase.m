function [database,songNames] = loadDatabase()
%Loads text files that correspond to constellations into matrix files
%database is a cell array that stores the constellations
%songNames is a cell array the stores the song names corresponding to the
%constellations

    %Gets names of all txt files in directory
    textInDir = dir('*.txt');
    textNames = {textInDir.name};
    
    database = cell(1,length(textNames)); %1x10 cell
    songNames = cell(1,length(textNames));
    
    
     if(length(textNames)==0) 
        disp 'No Constellation files in current directory'
    else
        %Audio files are present in the directory
        for i=1:length(textNames)
            
           filename = char(textNames(i));
           database{i} =  dlmread(filename);
           
           songNames{i} = filename(1:length(filename)-4)
                        
        end

    end
    


end

