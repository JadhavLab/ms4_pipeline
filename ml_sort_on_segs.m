function out = ml_sort_on_segs(tetResDir,varargin)
    % out = ml_sort_on_segs(tetResDir,varargin) will spike sort the data in the
    % given folder where tetResDir is the .nt#.mountain folder in the direct
    % directory and contains pre.mda.prv and (optional) params.json
    % This function will sort spikes, compute cluster metrics and create
    % curation tags. All params can be oveerriden via Name-Value pairs in the
    % input or via the params.json file (which has priority)
    % NAME-VALUE Pairs:
    %   geom    : path to csv file with electrode geometry (default = [] for tetrodes)
    %   adjacency_radius    : see ml-spec ephys.ms4alg -p (default = -1 for tetrodes)
    %   detect_sign     : sign of spikes to detect (default = 1)
    %   samplerate      : sampling rate of the data in Hz (default = 30000)
    %   firing_rate_thresh  : for curation, firing rate must be above this (default = 0.05)
    %   isolation_thresh    : for curation, isolation value must be above this (default = 0.95)
    %   noise_overlap_thresh: for curation, noise overlap must be below this (default = 0.03)
    %   peak_snr_thresh     : for curation, peak snr must be above this (default = 1.5)
    %   curation defaults are built into the ms4alg.create_label_map processor


    geom = []; % optional csv defining electrode geometry (not needed for tetrodes)
    adjacency_radius = -1; % use all channels are one neighborhood (for tetrodes)
    detect_sign=1; % sign of spikes to detect
    detect_threshold = 3; % detection threshold for spike in st. dev from mean
    samplerate = 30000;
    % Curation parameters
    firing_rate_thresh = [];
    isolation_thresh = [];
    noise_overlap_thresh = [];
    peak_snr_thresh = [];

    assignVars(varargin)

    % TODO: Use timeseries.mda from day directory to determine epoch offsets
    % TODO: Split into epoch segments using pyms
    % TODO: Sort each segment
    % TODO: Anneal Segments
    
    sortParams = struct('adjacency_radius',adjacency_radius,'detect_sign',detect_sign,'detect_threshold',detect_threshold);
    metParams = struct('samplerate',samplerate);
    curParams = struct('firing_rate_thresh',firing_rate_thresh,'isolation_thresh',isolation_thresh,'noise_overlap_thresh',noise_overlap_thresh,'peak_snr_thresh',peak_snr_thresh);
    if exist([tetResDir filesep 'params.json'],'file')
        paramTxt = fileread([tetResDir filesep 'params.json']);
        params = jsondecode(paramTxt);
        sortParams = setParams(sortParams,params);
        metParams = setParams(metParams,params);
        curParams = setParams(curParams,params);
    end

    % Sort entire file at once

    % Sort 
    pName = 'ms4alg.sort';
    sortInputs.timeseries = [tetResDir filesep 'pre.mda.prv'];
    sortOutputs.firings_out = [tetResDir filesep 'firings_raw.mda'];
    if ~isempty(geom)
        sortInputs.geom = geom;
    end
    console_out = ml_run_process(pName,sortInputs,sortOutputs,sortParams);
    % output file have array NxL where the rows are
    % channels_used,timestamp,cluster_labels and L is num data points

    % Compute cluster metrics
    pName = 'ephys.compute_cluster_metrics';
    metInputs.firings = sortOutputs.firings_out;
    metInputs.timeseries = sortInputs.timeseries;
    metOutputs.metrics_out = [tetResDir filesep 'metrics_raw.json'];
    console_out = ml_run_process(pName,metInputs,metOutputs,metParams);

    % Add Curation Tags (9/13 RN: no idea what this actually is, gonna test it out)
    % error in curation_spec.py.mp so skipping curation for now (9/13/18 RN)
    %pName = 'ms4alg.create_label_map';
    %curInputs = struct('metrics',metOutputs.metrics_out);
    %curOutputs = struct('label_map_out',[tetResDir filesep 'label_map.mda.prv']);
    %console_out = ml_run_process(pName,curInputs,curOutputs,curParams);
    % 
    %pName = 'ms4alg.apply_label_map';
    %appInputs = struct('firings',sortOutputs.firings_out,'label_map',curOutputs.label_map_out);
    %appOutputs = struct('firings_out',[tetResDir filesep 'firings_curated.mda']);
    %console_out = ml_run_process(pName,appInputs,appOutputs);

    %out = {sortOutputs.firings_out;metOutputs.metrics_out;appOutputs.firings_out};
    out = {sortOutputs.firings_out;metOutputs.metrics_out};

function newParams = setParams(old,new)
    FNs = fieldnames(old);
    newParams = old;
    for k=1:numel(FNs)
        if isfield(new,FNs{k})
            newParams.(FNs{k}) = new.(FNs{k});
        end
        if isempty(newParams.(FNs{k}))
            newParams = rmfield(newParams,FNs{k});
        end
    end
    if isempty(fieldnames(newParams))
        newParams = [];
    end
