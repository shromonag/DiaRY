%% This function does a basic reordering with expanded functions

function consNum = UpdateReordering(STLnodes, mapImpliesF)
    consNum = [];
    for i = 1 : length(STLnodes)
        for j = 1: length(STLnodes(i).consBreakUp)
            consNum = [consNum [STLnodes(i).consBreakUp(j).cons; 0]];
            if length(consNum(1,:)) == 1 
                consNum(2,end) = consNum(1,end);
            else
                consNum(2,end) = consNum(1,end) + consNum(2,end-1);
            end
        end
    end
    
    updatedInTheEnd = [];
    toDelete = [];
    if length(mapImpliesF) > 0
       for i = 1 : length(mapImpliesF(1,:))
          for j = 1: length(consNum(1,:))
              if mapImpliesF(1,i) <= consNum(2,j)
                loc = j;
                break;
              end
          end
          toDelete = [toDelete loc];
       end
    end
    updatingCons = consNum(:,toDelete);
    consNum(:,toDelete) = [];
    consNum = [consNum updatingCons];
    consNum = [consNum;zeros(2,length(consNum(1,:)))];
    consNum(3,:) = consNum(1,:);
    if length(mapImpliesF) > 0
        pos = length(consNum(1,:))-length(mapImpliesF(1,:)) + 1;
        consNum(3, pos : end) = mapImpliesF(2,:);
    end
    consNum(4,1) = consNum(1,1);
    for i = 2 : length(consNum(1,:))
        consNum(4,i) = consNum(3,i) + consNum(4, i-1);
    end
end