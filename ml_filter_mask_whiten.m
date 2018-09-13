function out = ml_filter_mask_whiten(resDir,varargin)
    % outFile = ml_filter_mask_whiten(resDir,varargin) where resDir is the .mountain
    % folder to be processed in the animal direct folder. should contain
    % .nt#.mountain directories each containing raw.mda.prv and params.json
    % This function will use mountainLab bandpass filter the mda files, mask
    % out artifacts and whiten channels 
    % NAME-VALUE Pairs:
    %   freq_min    : min freq for bandpass filter (default = 300). can be overriden by params.json
    %   freq_max    : max freq for bandpass filter (default = 6000). can be overriden by params.json
    %   samplerate  : sampling rate of data in Hz  (default = 30000). can be overriden by params.json
    %   mask_artifacts: 1 to mask artifacts (default = 1)
    %   tet_list    :  list of tetrodes to process. empty processes all tetrodes in results directory (default).
    %   threshold   : number of st. deviations away from the mean to consider as artifacts (default=5). Default from Frank Lab
    %   chuck_size  : number of sample sets to zero if RSS is above threshold (default=2000). Default from Frank Lab

    freq_min = 300;
    freq_max = 6000;
    mask_artifacts = 1;
    samplerate = 30000;
    tet_list = [];
    threshold = 5; % for artifact masking
    chunk_size = 2000; % for artifact masking

    assignVars(varargin)

    % Get tetrode list
    tetDirs = dir([resDir filesep '*.nt*']);
    tetDirs = {tetDirs.name};
    pat = '\w+.nt(?<tet>[0-9]+).\w+';
    tmp = cellfun(@(x) regexp(x,pat,'names'),tetDirs);
    allTets = str2double({tmp.tet});
    if isempty(tet_list)
        tet_list = allTets;
    else
        missing = setdiff(tet_list,allTets);
        tet_list = intersect(tet_list,allTets);
        if ~isempty(missing)
            disp('Cannot find data for tetrodes:')
            disp(missing)
        end
        keep = arrayfun(@(x) find(allTets==x),tet_list);
        tetDirs = tetDirs(keep);
    end


    defParams = struct('freq_min',freq_min,'freq_max',freq_max,'samplerate',samplerate);
    for k=1:numel(tetDirs)
        tD = tetDirs{k};

        % Set and overwrite default params with params.json if available
        samplerate = defParams.samplerate;
        freq_min = defParams.freq_min;
        freq_max = defParams.freq_max;
        if exist([tD filesep 'params.json'],'file')
            paramStr = fileread([tD filesep 'params.json']);
            params = jsondecode(paramStr);
            if isfield(params,'samplerate')
                samplerate = params.samplerate;
            end
            if isfield(params,'freq_min')
                freq_min = params.freq_min;
            end
            if isfield(params,'freq_max')
                freq_max = params.freq_max;
            end
        end 

        % Bandpass filter
        pName = 'ephys.bandpass_filter';
        inFile.timeseries = [tD filesep 'raw.mda.prv'];
        outFile.timeseries_out = [tD filesep 'filt.mda.prv'];
        filtParams = struct('samplerate',samplerate,'freq_min',freq_min,'freq_max',freq_max);
        console_out = ml_run_process(pName,inFile,outFile,filtParams);
        disp(console_out)

        % Mask Artifacts
        if mask_artifacts
            pName = 'ephys.mask_out_artifacts';
            inFile.timeseries = [tD filesep 'filt.mda.prv'];
            outFile.timeseries_out = [tD filesep 'filt.mda.prv'];
            maskParams = struct('threshold',threshold,'chunk_size',chunk_size);
            console_out = ml_run_process(pName,inFile,outFile,maskParams);
            disp(console_out)
        end

        % Whiten
        pName = 'ephys.whiten';
        inFile.timeseries = [tD filesep 'filt.mda.prv'];
        outFile.timeseries_out = [tD filesep 'pre.mda.prv'];
        console_out = ml_run_process(pName,inFile,outFile);
        disp(console_out)
    end

