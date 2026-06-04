function [X, y] = load_and_preprocess(filepath)
%LOAD_AND_PREPROCESS  Load the osteoporosis Excel dataset, clean and
%                     normalise it, then return feature matrix X and
%                     label vector y.
%
%  Dataset: 600 samples, 25 features + label (VBX)
%    Class 0 = Healthy (500 samples)
%    Class 1 = Fracture (100 samples)
%
%  INPUT
%    filepath  – path to the .xlsx file (string)
%
%  OUTPUT
%    X  – [N x 25] double, z-score normalised feature matrix
%    y  – [N x 1]  double, class labels (0 = Healthy, 1 = Fracture)
%
%  MISSING-VALUE STRATEGY
%    Appendix A rule: features >45% missing MAY be excluded.
%    Here we choose to RETAIN Menopause and HRT with targeted imputation
%    because both features have clinical relevance to osteoporosis:
%      - Menopause is a primary risk factor for bone density loss
%      - HRT (Heart Rate) is a physiological marker included in the dataset
%    Retaining them preserves potentially useful information for the NN.
%
%    - Menopause : 56.5% missing → Males (Sex=1) filled with 0
%                  (biologically inapplicable); remaining female
%                  missingness filled with mode of female values
%    - HRT       : 45.7% missing → median imputation (continuous variable)
%    - Smoking   : 0.7%  missing → mode imputation
%    - Ethnic    : 0.2%  missing → mode imputation
%    - Alcohol / Alcohol24 / VitaminD / Calcium : 24% → median imputation
%    - Dose_*    : missing = 0 (patient reported no activity)
% =========================================================

    %% ── Read raw table ───────────────────────────────────
    T = readtable(filepath, 'VariableNamingRule', 'preserve');

    %% ── Separate label ───────────────────────────────────
    y = double(T.VBX);
    T.VBX = [];

    %% ── Convert all object columns to numeric ────────────
    varNames = T.Properties.VariableNames;
    for k = 1:numel(varNames)
        col = T.(varNames{k});
        if iscell(col) || isstring(col)
            col = strtrim(string(col));
            col(col == "") = "NaN";
            T.(varNames{k}) = str2double(col);
        end
    end

    %% ── Missing value imputation ─────────────────────────

    % 1) Menopause – retained despite 56.5% missing (clinical relevance)
    %    Males (Sex=1): Menopause is biologically inapplicable → fill 0
    %    Females (Sex=0) with missing: mode of known female values
    isMale = T.Sex == 1;
    T.Menopause(isnan(T.Menopause) & isMale) = 0;
    femaleMode = mode(T.Menopause(~isMale & ~isnan(T.Menopause)));
    T.Menopause(isnan(T.Menopause) & ~isMale) = femaleMode;

    % 2) HRT (Heart Rate) – retained despite 45.7% missing
    %    Continuous variable → median imputation
    T.HRT = impute_median(T.HRT);

    % 3) Smoking & Ethnic – mode imputation (very few missing)
    T.Smoking = impute_mode(T.Smoking);
    T.Ethnic  = impute_mode(T.Ethnic);

    % 4) Alcohol / Alcohol24 / VitaminD / Calcium – median imputation
    alcCols = {'Alcohol','Alcohol24','VitaminD','Calcium'};
    for k = 1:numel(alcCols)
        T.(alcCols{k}) = impute_median(T.(alcCols{k}));
    end

    % 5) Dose_* columns – empty = 0 (no activity reported)
    doseCols = {'Dose_walk','Dose_moderate','Dose_vigorous', ...
                'Dose_pleasure','Dose_sport','Dose_execise', ...
                'Dose_lightDIY','Dose_heavyDIY'};
    for k = 1:numel(doseCols)
        col = T.(doseCols{k});
        col(isnan(col)) = 0;
        T.(doseCols{k}) = col;
    end

    %% ── Build feature matrix ─────────────────────────────
    X_raw = table2array(T);    % [N x 25]

    % Safety check
    if any(isnan(X_raw(:)))
        warning('NaN values remain – filling with column median.');
        for j = 1:size(X_raw,2)
            m = isnan(X_raw(:,j));
            if any(m)
                X_raw(m,j) = median(X_raw(~m,j));
            end
        end
    end

    %% ── Z-score normalisation ────────────────────────────
    [X, mu, sigma] = zscore(X_raw);
    save('norm_params.mat', 'mu', 'sigma');

    %% ── Report ───────────────────────────────────────────
    fprintf('    Loaded %d samples, %d features (all 25 retained)\n', size(X,1), size(X,2));
    fprintf('    Menopause: males→0, female missing→mode(%d)\n', femaleMode);
    fprintf('    HRT: median imputation\n');
    fprintf('    Missing values imputed successfully\n');
    fprintf('    Z-score normalisation applied\n');
end

% ── Helper: mode imputation ──────────────────────────────
function col = impute_mode(col)
    missing = isnan(col);
    if ~any(missing), return; end
    col(missing) = mode(col(~missing));
end

% ── Helper: median imputation ────────────────────────────
function col = impute_median(col)
    missing = isnan(col);
    if ~any(missing), return; end
    col(missing) = median(col(~missing));
end