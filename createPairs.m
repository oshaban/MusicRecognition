function [f1 f2 t1 delTPoints] = createPairs(peaks,timeBinSec)
%createPairs   Pairs local peaks of a spectrogram matrix by treating each
%peak in the matrix as an anchor point, then pairing the anchor point with
%the first numPairsMax number of points within it's target zone. The target
%zone height and width are set below
%
%@param peaks           Matrix of 0's and 1's representing location of local
%                       maxima of the spectrogram matrix
%@param timeBinSec      The number of seconds per time bin
%@return f1             Vector containing anchor point frequency
%@return f2             Vector containing frequency point of a peak matched
%                       with anchor point from f1
%@return t1             Vector containing anchor point time
%@return deltaTpoints   Vector containing time between anchor point and its
%                       paired local maxima

    [rowSizeSpec, colSizeSpec] = size(peaks); %Gets size of the peaks matrix
    [rowPeakLoc,colPeakLoc] = find(peaks); %Finds index of each peak in the matrix
    numPeaks = length(rowPeakLoc); %Gets the total number of peaks 

    deltaT = 30; %Targetzone "width" in timebins; searches to the right of anchor point
    deltaF = 15; %Targetzone search, searches up and down from the anchor point
    deltaTInit = 5; %Target zone initial distance from anchor point

    numPairsMax = 5; %Max limit on number of pairs an anchor point can have
        %Play with this since too large will cost excessive storage, but too
        %little and it will be difficult to match
        
    %Initialize vectors that make up the hash
    f1=0; 
    f2=0;
    t1=0;
    delTPoints=0;

    for i=1:numPeaks %each peak is considered as an anchor point

        %Gets index of current anchor point
        anchorPtRow = rowPeakLoc(i); 
        anchorPtCol = colPeakLoc(i);

        maxDistRight = anchorPtCol+deltaT+deltaTInit;%The farthest right of our target zone
        maxDistLeft = anchorPtCol + deltaTInit;
        
        if(maxDistRight > colSizeSpec) %Check target zone is within the spectrogram matrix
           maxDistRight = colSizeSpec; 
        end
        
        if(maxDistLeft > colSizeSpec) %Check target zone is within the spectrogram matrix
           maxDistLeft = colSizeSpec; 
        end

        %Find indicies of rows that will be searched up and down
        maxDistUp = anchorPtRow+deltaF;
        maxDistDown = anchorPtRow-deltaF;

        %Check that the index is within bounds of spectrogram matrix
        if(maxDistDown<1)
           maxDistDown = 1; 
        end
        if(maxDistUp>rowSizeSpec)
           maxDistUp = rowSizeSpec; 
        end

        counter=0; %Counter to keep track of how many pairings have been made for the current anchor point

        %Go through target zone and check for peaks near anchor point
        for j=maxDistDown:maxDistUp
            for k=anchorPtCol:maxDistRight
                
                if(counter<numPairsMax) %Check limit of pairings is not exceeded
                    
                    for m=1:numPeaks %Go through all peaks and see if they are in the target zone

                        if( j==rowPeakLoc(m) && k==colPeakLoc(m) ) %Then we found a peak within the target zone

                            if(anchorPtRow == rowPeakLoc(m) && anchorPtCol == colPeakLoc(m) )
                               %Check the anchor point is not being paired
                               %to itself
                            else
                                
                                %Add values to the vectors
                                if(f1(1)~=0) %vectors are initalized to zero, so remove this inital value
                                    f1(1) = [anchorPtRow];
                                    f2(1) = [rowPeakLoc(m)];
                                    t1(1) = [anchorPtCol.*timeBinSec];
                                    delTPoints(1) = [(colPeakLoc(m) - anchorPtCol).*timeBinSec];
                                else
                                    f1 = [f1, anchorPtRow];
                                    f2 = [f2, rowPeakLoc(m)];
                                    t1 = [t1, anchorPtCol.*timeBinSec];
                                    delTPoints = [delTPoints, (colPeakLoc(m) - anchorPtCol).*timeBinSec];
                                end

                                counter = counter + 1; %Keep track of how many pairs have been made
                             

                            end %end if-else

                        end %end if
                    end %end for

                end %end if

            end %end for
        end %end for

    end

end %end function

