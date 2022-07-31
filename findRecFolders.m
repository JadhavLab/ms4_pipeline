function recFolders = findRecFolders(parentDir,pattern,sessionInds)
% Finds the desired folders based on pattern, and limited to days that are
% included in sessionInds.

recFolders = dir(parentDir);
daysToProcess = zeros(numel(recFolders),1);
for i = numel(recFolders):-1:1
    if strcmpi(recFolders(i).name,'.') || strcmpi(recFolders(i).name,'..')
        daysToProcess(i) = -1;
    else
        parsed = regexp(recFolders(i).name,pattern,'names');
        if ~isempty(parsed) 
            daysToProcess(i) = str2double(parsed.day);
        end
    end
end
% Axe not real folders.
recFolders(daysToProcess<0) = [];
daysToProcess(daysToProcess<0) = [];

% Trim directories not included in fn input, and display if not all
% expected sessions are found.
if ~isempty(sessionInds)
    missing = setdiff(sessionInds,daysToProcess);
    [~,rmv] = setdiff(daysToProcess,sessionInds);
    recFolders(rmv) = [];
    if ~isempty(missing)
        disp('Could not find data for days:');
        disp(missing);
    end
end
recFolders = strcat({recFolders.folder},filesep,{recFolders.name},filesep);

end