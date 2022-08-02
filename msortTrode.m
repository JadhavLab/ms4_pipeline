function msortTrode(mtnSortFolder, varargin)
% Inputs, in order:
% mtnSortFolder - folder name and path to create for all mtnsort files
% 
% Optional:
% sourceTrodeFileName - raw Trode continuous data - mda file, w/ path
%
% Optional: use name-value pairs e.g. color, 'blue',. order of each pair
% doesn't matter.
% maskArtifacts - boolean : whether to mask artifacts during preprocesing.
% haveTimestamps - boolean : true false whether timestamps needs to be
%                           found and copied (true) or needs to be done
% cuttingParams - struct : all cluster cutting parrameters can be added
%                          to this struct and passed in.

%% Parse Inputs
p = inputParser;
p.StructExpand = false;
validStr = @(x) isstring(x) || ischar(x);
addRequired(p,'mtnSortFolder');
addOptional(p,'sourceTrodeFileName',[],validStr);
addParameter(p,'maskArtifacts',true);
addParameter(p,'needTimeStamps',false);
addParameter(p,'cuttingParams',struct('samplerate',30000));

parse(p,mtnSortFolder,varargin{:});

%% Create mtnSortDir.
if ~isempty(p.Results.sourceTrodeFileName) 
    createMtnSortDir(p.Results.sourceTrodeFileName, p.Results.mtnSortFolder,...
        p.Results.cuttingParams, p.Results.needTimeStamps);
end

%% Preprocessing
diary([mtnSortFolder filesep 'ml_sorting.log'])
fprintf('\n\n------\nBeginning analysis of %s\nDate: %s\n\nBandpass Filtering, Masking out artifacts and Whitening...\n------\n',...
    mtnSortFolder,datestr(datetime('Now')));

% filter mask and whiten
% TODO: Add check to make sure there is data in the mda files, maybe up in mda_util
[processesdFileName,maskErrors] = ml_filter_mask_whiten(mtnSortFolder,...
    'mask_artifacts',p.Results.maskArtifacts);
% returns path to pre.mda.prv file

fprintf('\n\n------\nPreprocessing of data done. Written to %s\n------\n',...
    processesdFileName)

%% Autosort Cluster Cutting (MountainSort) 
fprintf('\n------\nBeginning Sorting and curation...\n------\n')
% Sort and curate
sortOutput = ml_sort_on_segs(mtnSortFolder);
% returns paths to firings_raw.mda, metrics_raw.json and firings_curated.mda
%fprintf('\n\nSorting done. outputs saved at:\n    %s\n    %s\n    %s\n',out2{1},out2{2},out2{3})
fprintf('\n\n------\nSorting done. outputs saved at:\n    %s\n    %s\n------\n',...
    sortOutput{1},sortOutput{2})

if maskErrors
    fprintf('\n######\nMasking error for this trode. Masking Artifacts skipped. Spikes may be noisy\n######\n')
end

diary off


end