function ml_process_animal(animID,rawDir,varargin)
    % ml_process_animal(animID,rawDir,varargin) will setup, preprocess and
    % spike sort data with mountainlab-js. rawDir is the raw data directory
    % containing the day directories. It is expected that mda files were
    % extracted from the rec files already.
    % Requires that day directories inside the rawDir are named day_date (e.g. 01_180819)
    % and that the mda directory inside the day dirs is labelled
    % animID_day_date.mda or animID_day_date_epoch.mda (the latter will only
    % happen if you have 1 epoch), [e.g. RW9_02_1808224.mda]
    % NAME-VALUE Pairs:
    %   dataDir     : path to direct folder for animal. default = rawDir/../animID_direct
    %   sessionNums : array of days to process. default = [] processes all days in rawDir
    %   tet_list    : array of tetrodes to cluster. default = [] processes all tetrodes available
    %   keep_intermediates  : whether to keep the intermediate mda files corresponding to pre.mda.prv and filt.mda.prv, the intermediate files are stored on the local disk in the mountainlab tmp folder (defualt=0)

    if rawDir(end)==filesep
        rawDir = rawDir(1:end-1);
    end
    dataDir = [fileparts(rawDir) filesep animID '_direct'];
    sessionNums = [];
    tet_list = [];
    keep_intermediates = 0;

    assignVars(varargin)

    dayDirs = dir(rawDir);
    daysToProcess = zeros(numel(dayDirs),1);
    for k=numel(dayDirs):-1:1
        if strcmpi(dayDirs(k).name,'.') || strcmpi(dayDirs(k).name,'..')
            daysToProcess(k) = -1;
        else
            pat = '(?<day>[0-9]{2})_(?<date>\d+)';
            parsed = regexp(dayDirs(k).name,pat,'names');
            if isempty(parsed)
                disp(['Could not parse directory name: ' dayDirs(k).name])
                dn = input('What day is this (#)?  ');
            else
                dn = str2double(parsed.day);
            end
            daysToProcess(k) = dn;
        end
    end
    dayDirs(daysToProcess<0) = [];
    daysToProcess(daysToProcess<0) = [];

    if ~isempty(sessionNums)
        missing = setdiff(sessionNums,daysToProcess);
        [rmvDays,rmv] = setdiff(daysToProcess,sessionNums);
        dayDirs(rmv) = [];
        daysToProcess(rmv) = [];
        if ~isempty(missing)
            disp('Could not find data for days:')
            disp(missing)
        end
    end
    dayDirs = strcat({dayDirs.folder},filesep,{dayDirs.name},filesep);

    disp('Processing raw data with mountain lab. Processing:')
    disp(dayDirs')
    if ~isempty(tet_list)
        disp('restricting to tetrodes:')
        disp(tet_list')
    end

    % Run mda_util, returns list of tetrode results directories
    resDirs = mda_util(dayDirs,'tet_list',tet_list,'dataDir',dataDir);

    % For each day and tet sort spikes
    for k=1:numel(resDirs)
        rD = resDirs{k};
        diary([rD filesep 'ml_sorting.log'])
        fprintf('\n\nBeginning analysis of %s\nDate: %s\n\nBandpass Filtering, Masking out artifacts and Whitening...\n',rD,datestr(datetime('Now'))); 
        
        % filter mask and whiten
        out = ml_filter_mask_whiten(rD);
        % returns path to pre.mda.prv file

        fprintf('\n\nPreprocessing of data done. Written to local machine with prv link @ %s\n',out)

        fprintf('Beginning Sorting and curation...\n')

        % Sort and curate
        out2 = ml_sort_on_segs(rD);
        % returns paths to firings_raw.mda, metrics_raw.json and firings_curated.mda
        %fprintf('\n\nSorting done. outputs saved at:\n    %s\n    %s\n    %s\n',out2{1},out2{2},out2{3})
        fprintf('\n\nSorting done. outputs saved at:\n    %s\n    %s\n',out2{1},out2{2})

        %TODO: Convert to FF matlab file

        % Delete intermediate files
        if ~keep_intermediates
            tmpDir = '/tmp/mountainlab-tmp/';
            disp('Removing intermediate processing mda files...')
            delete([tmpDir '*.mda'])
        end

        diary off

    end







        

