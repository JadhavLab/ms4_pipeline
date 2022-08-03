function recFolders = findRecFolders(animalDir,pattern,sessionList)
% Finds the desired folders based on pattern, and limited to days that are
% included in sessionInds.

%% Input handling:
if isempty(pattern)
    pattern = '(?<animalID>[A-Z]+[0-9]+)_D(?<recID>[0-9]{2})';
end
if animalDir(end)==filesep
    animalDir = animalDir(1:end-1);
end

if isfolder(animalDir)
    recFolders = dir(animalDir);
    if isempty(recFolders)
            disp('no valid tetrode files');
    else
        recsToProcess = zeros(numel(recFolders),1);
        for iRec = numel(recFolders):-1:1
            if strcmpi(recFolders(iRec).name,'.') || strcmpi(recFolders(iRec).name,'..')
                recsToProcess(iRec) = -1;
            else
                parsed = regexp(recFolders(iRec).name,pattern,'names');
                if ~isempty(parsed)
                    recsToProcess(iRec) = str2double(parsed.recID);
                    recFolders(iRec).animalID = str2double(parsed.animalID);
                    recFolders(iRec).recID = str2double(parsed.recID);
                end
            end
        end
        % Axe not real folders.
        recFolders(recsToProcess<=0) = [];
        recsToProcess(recsToProcess<=0) = [];

        % Trim directories not included in fn input, and display if not all
        % expected sessions are found.
        if ~isempty(sessionList)
            disp('restricting to sessions:')
            disp(sessionList')
            missing = setdiff(sessionList,[recFolders.recID]);
            recFolders(rmv) = [];
            if ~isempty(missing)
                disp('Could not find data for days:');
                disp(missing);
            end
            [~,keepInd] = intersect([recFolders.recID],recsToProcess);
            recFolders = recFolders(keepInd);
        end
    end
else
    disp('not a valid folder');
end

end