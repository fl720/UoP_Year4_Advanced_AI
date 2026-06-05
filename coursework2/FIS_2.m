% =========================================================
% M33176 Coursework 2 — Medical Insurance Fuzzy Network
% STEP 2: Sub-FIS 2 (Lifestyle Risk)
%
% Sub-FIS 2 inputs:  smoker   (NonSmoker / Smoker)
%                    children (None / Few / Several)
% Sub-FIS 2 output:  lifestyle_risk  (Low / Medium / High)
%
% Data grounding:
%   Smoker mean charges:     $32,050  (vs non-smoker $8,441)
%   Children effect is weak: $7,625 (0) → $8,795 (1-2) → $9,811 (3+)
%   → smoker is the dominant driver; children adds secondary gradient
% =========================================================

% NOTE: Run step1_data_and_subfis1.m first to load data into workspace.
% fis1 and Ttrain/Ttest should already be in your workspace.
% If starting fresh, uncomment and run the two lines below:
% run('step1_data_and_subfis1.m');

%% ── SUB-FIS 2 — LIFESTYLE RISK ───────────────────────────
%
%  Input 1: smoker  — universe [0, 1]  (0=no, 1=yes)
%    • NonSmoker : trimf [0   0   0.5]
%    • Smoker    : trimf [0.5 1   1  ]
%    Binary encoding; shoulder MFs ensure crisp 0/1 maps cleanly.
%
%  Input 2: children — universe [0, 3]  (clipped at 3)
%    • None    : trimf [0  0  1.5]   → 0 children
%    • Few     : trimf [0.5 1.5 2.5] → 1–2 children
%    • Several : trimf [1.5 3  3  ]  → 3+ children
%    Breakpoints reflect clip at 3; distribution: 573/564/157 records
%
%  Output: lifestyle_risk — universe [0, 1]
%    • Low    : trimf [0   0   0.35]
%    • Medium : trimf [0.2 0.5 0.75]
%    • High   : trimf [0.6 1   1   ]
%    (Same output universe as Sub-FIS 1 — required for merging step)
%
%  Rules (6 total = 2 smoker terms × 3 children terms)
%  Cross-tabulation means:
%    NonSmoker+None    = $7,625  → Low
%    NonSmoker+Few     = $8,795  → Low
%    NonSmoker+Several = $9,811  → Low-Medium
%    Smoker+None       = $31,341 → High
%    Smoker+Few        = $32,781 → High
%    Smoker+Several    = $31,974 → High
%  Smoker overwhelmingly dominates; children effect is secondary.

fis2 = mamfis('Name', 'LifestyleRisk');

% ── Input 1: smoker ──────────────────────────────────────
fis2 = addInput(fis2, [0 1], 'Name', 'smoker');
fis2 = addMF(fis2, 'smoker', 'trimf', [0   0   0.5], 'Name', 'NonSmoker');
fis2 = addMF(fis2, 'smoker', 'trimf', [0.5 1   1  ], 'Name', 'Smoker');

% ── Input 2: children (clipped at 3) ─────────────────────
fis2 = addInput(fis2, [0 3], 'Name', 'children');
fis2 = addMF(fis2, 'children', 'trimf', [0   0   1.5], 'Name', 'None');
fis2 = addMF(fis2, 'children', 'trimf', [0.5 1.5 2.5], 'Name', 'Few');
fis2 = addMF(fis2, 'children', 'trimf', [1.5 3   3  ], 'Name', 'Several');

% ── Output: lifestyle_risk ────────────────────────────────
fis2 = addOutput(fis2, [0 1], 'Name', 'lifestyle_risk');
fis2 = addMF(fis2, 'lifestyle_risk', 'trimf', [0   0   0.35], 'Name', 'Low');
fis2 = addMF(fis2, 'lifestyle_risk', 'trimf', [0.2 0.5 0.75], 'Name', 'Medium');
fis2 = addMF(fis2, 'lifestyle_risk', 'trimf', [0.6 1   1   ], 'Name', 'High');

% ── Rules ─────────────────────────────────────────────────
% Format: [smoker_MF  children_MF  output_MF  weight  AND/OR]
%   smoker:   1=NonSmoker  2=Smoker
%   children: 1=None  2=Few  3=Several
%   risk:     1=Low   2=Medium  3=High

ruleList2 = [
%  smk  chd  risk  wt  op
    1    1    1     1   1   % NonSmoker + None    → Low
    1    2    1     1   1   % NonSmoker + Few     → Low
    1    3    2     1   1   % NonSmoker + Several → Medium
    2    1    3     1   1   % Smoker    + None    → High
    2    2    3     1   1   % Smoker    + Few     → High
    2    3    3     1   1   % Smoker    + Several → High
];

fis2 = addRule(fis2, ruleList2);

fprintf('Sub-FIS 2 (LifestyleRisk) built successfully.\n');
fprintf('  Inputs  : %d\n', numel(fis2.Inputs));
fprintf('  Outputs : %d\n', numel(fis2.Outputs));
fprintf('  Rules   : %d\n', numel(fis2.Rules));

%% ── VISUAL CHECK ─────────────────────────────────────────
figure('Name', 'Sub-FIS 2 — Membership Functions');

subplot(1,3,1);
plotmf(fis2, 'input', 1);
title('Input 1: Smoker');
xlabel('0 = No  |  1 = Yes'); ylabel('Membership');

subplot(1,3,2);
plotmf(fis2, 'input', 2);
title('Input 2: Children (clipped at 3)');
xlabel('Number of children'); ylabel('Membership');

subplot(1,3,3);
plotmf(fis2, 'output', 1);
title('Output: Lifestyle Risk');
xlabel('Risk score [0–1]'); ylabel('Membership');

sgtitle('Sub-FIS 2 (Lifestyle Risk) — Membership Functions');

%% ── RULE VIEWER (optional but useful for report screenshot) ─
% Uncomment to open interactive rule viewer:
% ruleview(fis2);

%% ── SPOT-CHECK ───────────────────────────────────────────
fprintf('\n── Spot-check evaluations ──\n');
examples2 = [
    0, 0;   % NonSmoker + None     → expect Low
    0, 2;   % NonSmoker + Few      → expect Low
    0, 3;   % NonSmoker + Several  → expect Low-Medium
    1, 0;   % Smoker    + None     → expect High
    1, 2;   % Smoker    + Few      → expect High
    1, 3;   % Smoker    + Several  → expect High
];
labels2 = {
    'NonSmoker+None     (→Low)',
    'NonSmoker+Few      (→Low)',
    'NonSmoker+Several  (→Low-Med)',
    'Smoker+None        (→High)',
    'Smoker+Few         (→High)',
    'Smoker+Several     (→High)'
};

for i = 1:size(examples2, 1)
    result = evalfis(fis2, examples2(i,:));
    fprintf('  smoker=%d, children=%d  →  lifestyle_risk = %.3f   [%s]\n', ...
        examples2(i,1), examples2(i,2), result, labels2{i});
end

%% ── COMBINED SPOT-CHECK: both FIS together ───────────────
fprintf('\n── Combined check: FIS1 + FIS2 on same records ──\n');
fprintf('  (Shows how the two sub-systems complement each other)\n\n');

combExamples = [
%  age  bmi   smoker  children
    18,  21,   0,      0;    % Low risk profile
    45,  28,   0,      2;    % Medium risk profile
    60,  38,   1,      0;    % High risk profile
    35,  32,   1,      3;    % Mixed: middle-obese + smoker
];
combLabels = {
    'Young+Normal+NonSmoker+None',
    'Middle+Overweight+NonSmoker+Few',
    'Senior+Obese+Smoker+None',
    'Middle+Obese+Smoker+Several'
};

fprintf('  %-40s  body_risk  lifestyle_risk\n', 'Profile');
fprintf('  %s\n', repmat('-',1,65));
for i = 1:size(combExamples,1)
    r1 = evalfis(fis1, combExamples(i, 1:2));
    r2 = evalfis(fis2, combExamples(i, 3:4));
    fprintf('  %-40s  %.3f      %.3f\n', combLabels{i}, r1, r2);
end

fprintf('\n✓ Step 2 complete.\n');
fprintf('Both sub-FIS objects (fis1, fis2) ready for merging in Step 3.\n');

% Save for next step
writeFIS(fis2, 'subfis2_lifestylerisk');
fprintf('Saved as subfis2_lifestylerisk.fis\n');