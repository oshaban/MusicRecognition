function fingerprint=create_constellation_adaptive_threshold(song_name)
%feed the name of a song to the function and it spits out a constellation


newfs = 8192; %8192 is new sampling rate of signal. Corresponds to the highest note on a piano.


[song, Fs] = audioread(song_name);
% sums to mono
if length(song(1,:))>1
    song_mono = ((song(:,1)+song(:,2))./2)';
else
    song_mono=song'; % no DC offset for a mono source.
end
song_mono = song_mono - mean(song_mono); %Removes DC bias
song_rs = resample(song_mono, newfs,Fs);

% works with frequencies from 1000 as low frequency content is unreliable.
otherfs = 500:2:4096;

timePerWindow = 0.1; %100 ms window

window = round(timePerWindow*newfs); %Number of samples per window
noverlap = round(0.75*window); %Number of samples from adjacent chunks that will overlap

[song_spect,fspec,tspec] = spectrogram(song_rs,window,noverlap,otherfs,newfs,'yaxis'); 

magSpec = abs(song_spect); %Only care about magnitude of Spectrogram

%%FINDING PEAKS

gs = 3;
peaks = ones(size(magSpec)); % 2D boolean array indicating position of local peaks
for horShift = -gs:gs
    for vertShift = -gs:gs
        if(vertShift ~= 0 || horShift ~= 0) % Avoid comparing to self
            peaks = peaks.*( magSpec > circshift(magSpec,[horShift,vertShift]) );
        end
    end
end

peakMags = peaks.*magSpec;

%% Adaptive Threshold

%For example, this will take columns 1 to 256
%of the original spectrogram, find the top 30 peaks in this area, and set
%all other values to zero that are below this value. This filtered chunk
%will be stored in a new array and the next chunk of the old array will be
%worked on.  num_peaks does not necessarily reflect the exact number of
%peaks per section as some magnitudes may be repeated.

% this is similar to my "naive" threshold which is basically the same thing
% as Omar's threshold.  Though, this splits the spectrogram into smaller
% chunks and works on those chunks, giving more uniform results.

num_peaks=30;
% number of peaks per unit time
song_spect_threshold = [];
% empty array to dump thresholded segments
threshold_size = floor((8192/(window/4))*1);
%this is the index size for each chunk of the magnitude spectrogram that
%the threshold will work on. the '1' reflects that each this threshold will
%work on 1 second chunks of the spectrogram.  This can be changed.
i = 0;
while 1
    i=i+threshold_size;
    if i-(threshold_size-1)>length(tspec)
        break
    end
    if i>length(tspec)
        % this section handles the last section of the spectrogram that may or
        % may not be exactly one threshold_size of columns
        song_spect_part=peakMags(:,i-(threshold_size-1):length(tspec));
        sorted_part = sort(song_spect_part(:),'descend');
        threshold = sorted_part(ceil(num_peaks*((i-length(tspec))/threshold_size)));
    else
        % this section handles most of the iterations through the filtered
        % spectrogram.
        song_spect_part=peakMags(:,i-(threshold_size-1):i);
        sorted_part = sort(song_spect_part(:),'descend');
        threshold = sorted_part(num_peaks);
    end
    song_spect_part(song_spect_part<threshold)=0;
    song_spect_threshold = [song_spect_threshold, song_spect_part];
    %adds thresholded chunk to the growing collection of thresholded
    %chunks.
end


[f1 f2 delTPoints] = createPairs_adjustable(song_spect_threshold,tspec,otherfs);
fingerprint = [f1;f2;delTPoints];

end
