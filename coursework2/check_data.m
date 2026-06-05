% =========================================================
% M33176 Coursework 2 — Medical Insurance Fuzzy Network
% STEP 1: Data Preparation + Sub-FIS 1 (Health Risk)
%
% Sub-FIS 1 inputs:  age  (Young / Middle / Senior)
%                    bmi  (Normal / Overweight / Obese)
% Sub-FIS 1 output:  body_risk  (Low / Medium / High)
%
% All membership function breakpoints are grounded in
% the dataset statistics and WHO BMI clinical thresholds.
% =========================================================

clear; clc;

%% ── 1. LOAD & CLEAN DATA ─────────────────────────────────
T = readtable('insurance.csv');

% Remove the one duplicate row confirmed in Python analysis
T = unique(T);                        % 1338 → 1337 rows

% Encode categorical variables as numbers
%   smoker: yes=1, no=0
%   sex:    male=1, female=0  (kept for reference, not used in FIS)
T.smoker_num  = double(strcmp(T.smoker,  'yes'));
T.sex_num     = double(strcmp(T.sex,     'male'));

% Clip children at 3  (children=4 and 5 have only 43 records combined)
T.children_clipped = min(T.children, 3);

% Quick sanity check
fprintf('Dataset loaded: %d rows, %d columns\n', height(T), width(T));
fprintf('Age   range : %d – %d\n',  min(T.age),     max(T.age));
fprintf('BMI   range : %.1f – %.1f\n', min(T.bmi),  max(T.bmi));
fprintf('Charges range: $%.0f – $%.0f\n', min(T.charges), max(T.charges));

%% ── 2. TRAIN / TEST SPLIT (80 / 20) ─────────────────────
rng(42);                              % fix random seed for reproducibility
n          = height(T);
idx        = randperm(n);
trainIdx   = idx(1 : round(0.8*n));
testIdx    = idx(round(0.8*n)+1 : end);

Ttrain = T(trainIdx, :);
Ttest  = T(testIdx,  :);

fprintf('\nTrain rows: %d  |  Test rows: %d\n', height(Ttrain), height(Ttest));

%% ── 3. SUB-FIS 1 — HEALTH RISK ──────────────────────────
%
%  Inputs
%  ------
%  age  : universe [18, 64]
%    • Young  : 18–30   (triangular, peak 18, shoulder to 30)
%    • Middle : 26–50   (triangular, peak 38)
%    • Senior : 44–64   (triangular, peak 64)
%    Breakpoints grounded in dataset 33rd/66th percentiles (30 / 47)
%
%  bmi  : universe [15, 55]
%    • Normal    : 15–27   (trimf, peak 21)   WHO: <25 normal
%    • Overweight: 23–33   (trimf, peak 28)   WHO: 25–30
%    • Obese     : 29–55   (trimf, peak 55)   WHO: >30
%    Breakpoints grounded in WHO clinical thresholds
%
%  Output
%  ------
%  body_risk : universe [0, 1]
%    • Low    : [0,   0.35]
%    • Medium : [0.2, 0.7 ]
%    • High   : [0.6, 1.0 ]
%
%  Rules (9 total = 3 age terms × 3 bmi terms)
%  Data-grounded means (from cross-tabulation):
%    Young+Normal=$6,769  Young+Overweight=$7,317  Young+Obese=$11,884
%    Middle+Normal=$11,295 Middle+Overweight=$9,955 Middle+Obese=$14,926
%    Senior+Normal=$14,408 Senior+Overweight=$15,340 Senior+Obese=$18,729
%  Risk levels assigned proportionally across $6,769–$18,729 range.

fis1 = mamfis('Name', 'HealthRisk');

% ── Input 1: age ─────────────────────────────────────────
fis1 = addInput(fis1, [18 64], 'Name', 'age');
fis1 = addMF(fis1, 'age', 'trimf', [18 18 32], 'Name', 'Young');
fis1 = addMF(fis1, 'age', 'trimf', [26 38 52], 'Name', 'Middle');
fis1 = addMF(fis1, 'age', 'trimf', [44 64 64], 'Name', 'Senior');

% ── Input 2: bmi ─────────────────────────────────────────
fis1 = addInput(fis1, [15 55], 'Name', 'bmi');
fis1 = addMF(fis1, 'bmi', 'trimf', [15 21 27], 'Name', 'Normal');
fis1 = addMF(fis1, 'bmi', 'trimf', [23 28 33], 'Name', 'Overweight');
fis1 = addMF(fis1, 'bmi', 'trimf', [29 55 55], 'Name', 'Obese');

% ── Output: body_risk ────────────────────────────────────
fis1 = addOutput(fis1, [0 1], 'Name', 'body_risk');
fis1 = addMF(fis1, 'body_risk', 'trimf', [0   0   0.35], 'Name', 'Low');
fis1 = addMF(fis1, 'body_risk', 'trimf', [0.2 0.5 0.75], 'Name', 'Medium');
fis1 = addMF(fis1, 'body_risk', 'trimf', [0.6 1   1],    'Name', 'High');

% ── Rules ─────────────────────────────────────────────────
% Format: [age_MF  bmi_MF  output_MF  weight  AND/OR]
%   age:  1=Young  2=Middle  3=Senior
%   bmi:  1=Normal 2=Overweight 3=Obese
%   risk: 1=Low    2=Medium     3=High

ruleList = [
%  age  bmi  risk  wt  op
    1    1    1     1   1   % Young  + Normal      → Low
    1    2    1     1   1   % Young  + Overweight  → Low
    1    3    2     1   1   % Young  + Obese       → Medium
    2    1    2     1   1   % Middle + Normal      → Medium
    2    2    2     1   1   % Middle + Overweight  → Medium
    2    3    2     1   1   % Middle + Obese       → Medium
    3    1    2     1   1   % Senior + Normal      → Medium
    3    2    3     1   1   % Senior + Overweight  → High
    3    3    3     1   1   % Senior + Obese       → High
];

fis1 = addRule(fis1, ruleList);

fprintf('\nSub-FIS 1 (HealthRisk) built successfully.\n');
fprintf('  Inputs  : %d\n', numel(fis1.Inputs));
fprintf('  Outputs : %d\n', numel(fis1.Outputs));
fprintf('  Rules   : %d\n', numel(fis1.Rules));

%% ── 4. QUICK VISUAL CHECK ────────────────────────────────
figure('Name', 'Sub-FIS 1 — Membership Functions');

subplot(1,3,1);
plotmf(fis1, 'input', 1);
title('Input 1: Age');
xlabel('Age (years)'); ylabel('Membership');

subplot(1,3,2);
plotmf(fis1, 'input', 2);
title('Input 2: BMI');
xlabel('BMI (kg/m²)'); ylabel('Membership');

subplot(1,3,3);
plotmf(fis1, 'output', 1);
title('Output: Body Risk');
xlabel('Risk score [0–1]'); ylabel('Membership');

sgtitle('Sub-FIS 1 (Health Risk) — Membership Functions');

%% ── 5. SPOT-CHECK: evaluate a few example inputs ────────
fprintf('\n── Spot-check evaluations ──\n');
examples = [
    18, 21;   % Young  + Normal      → expect Low
    45, 28;   % Middle + Overweight  → expect Medium
    60, 38;   % Senior + Obese       → expect High
    30, 32;   % Middle + Obese       → expect Medium-High
];
labels = {'Young+Normal (→Low)', 'Middle+Overweight (→Med)', ...
          'Senior+Obese (→High)', 'Middle+Obese (→Med-High)'};

for i = 1:size(examples,1)
    result = evalfis(fis1, examples(i,:));
    fprintf('  age=%2d, bmi=%.0f  →  body_risk = %.3f   [%s]\n', ...
        examples(i,1), examples(i,2), result, labels{i});
end

fprintf('\n✓ Step 1 complete. Save fis1 for use in Step 2.\n');

% Save FIS object for next step
writeFIS(fis1, 'subfis1_healthrisk');
fprintf('  Saved as subfis1_healthrisk.fis\n');