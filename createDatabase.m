function [] = createDatabase()
%Creates constellations for all mp3 files in the current directory with
%specified freq spacing and binsize in
%create_constellation_adaptive_threshold
%Saves them to .txt files, where the data in the text file is the
%constellation corresponding to the hash type [f1,f2,deltaT]
% To read the .txt files into a matrix use dlmread()
    
    %Gets names of all mp3 files in current directory
    audioInDir = dir('*.mp3');
    audioNames = {audioInDir.name};

    if(length(audioNames)==0)
        disp 'No Audio Files in Current Directory'
    else
        %Audio files are present in the directory
        for i=1:length(audioNames)
            
            filename = char(audioNames(i));
            filenameToSave = strcat( filename(1:(length(filename)-4)),'.txt');
                        
            constellation = create_constellation_adaptive_threshold(filename);
            dlmwrite(filenameToSave,constellation,'delimiter',' '); %Writes the constellation to .txt file
            
        end

    end

end

