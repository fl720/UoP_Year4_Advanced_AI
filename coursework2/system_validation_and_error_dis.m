% =========================================================
% M33176 Coursework 2
% STEP 2b: Export validation data for Designer Simulation panel
%
% This script prepares input/output data in the exact format
% the Designer's "Input Data: Select" and "Output Data: Select"
% panels expect, then runs evalfis on the test set so you have
% prediction results ready for the report.
% =========================================================

% Run Step 1 first if workspace is empty
% run('step1_data_and_subfis1.m');
% run('step2_subfis2.m');

%% ── 1. PREPARE INPUT ARRAYS FOR DESIGNER ─────────────────
% Designer expects a plain matrix where each row = one sample
% FIS 1 inputs: [age, bmi]
% FIS 2 inputs: [smoker_num, children_clipped]

% Use the test set (267 rows)
inputData_fis1 = [Ttest.age, Ttest.bmi];
inputData_fis2 = [Ttest.smoker_num, Ttest.children_clipped];

% True output (actual charges) — used for error analysis
actualCharges   = Ttest.charges;

fprintf('Input data prepared:\n');
fprintf('  FIS1 input matrix: %d x %d\n', size(inputData_fis1));
fprintf('  FIS2 input matrix: %d x %d\n', size(inputData_fis2));

%% ── 2. SAVE TO WORKSPACE VARIABLES DESIGNER CAN SEE ──────
% In Designer: click "Input Data: Select" → choose from workspace
% These variable names will appear in the dropdown

fis1_InputData = inputData_fis1;   % select this for FIS1 simulation
fis2_InputData = inputData_fis2;   % select this for FIS2 simulation

fprintf('\nWorkspace variables ready for Designer:\n');
fprintf('  fis1_InputData  (%d x %d) → use for HealthRisk simulation\n', ...
    size(fis1_InputData));
fprintf('  fis2_InputData  (%d x %d) → use for LifestyleRisk simulation\n', ...
    size(fis2_InputData));
fprintf('\nIn Designer: Input Data → Select → pick "fis1_InputData"\n');
fprintf('Then click the simulate/run button (triangle icon) in Simulation panel.\n');

%% ── 3. EVALUATE FIS ON TEST SET (code-side validation) ───
% This gives you the numbers for the report regardless of Designer

fprintf('\n── Evaluating Sub-FIS 1 on test set ──\n');
pred_body_risk      = evalfis(fis1, inputData_fis1);

fprintf('── Evaluating Sub-FIS 2 on test set ──\n');
pred_lifestyle_risk = evalfis(fis2, inputData_fis2);

%% ── 4. COMBINED RISK SCORE ────────────────────────────────
% Simple weighted average: health risk has higher weight
% (age+BMI are stronger actuarial predictors than children)
% Smoker captured in lifestyle_risk which already dominates
w1 = 0.45;   % weight for body_risk
w2 = 0.55;   % weight for lifestyle_risk (smoker dominates here)
combined_risk = w1 .* pred_body_risk + w2 .* pred_lifestyle_risk;

%% ── 5. MAP RISK SCORE → CHARGE CATEGORY ──────────────────
% Thresholds grounded in dataset charge percentiles:
%   Low    : < 25th pct = $4,746
%   Medium : 25th–75th  = $4,746–$16,658
%   High   : 75th–90th  = $16,658–$34,833
%   VeryHigh: > 90th    = $34,833

% Map actual charges to categories
actualCat = zeros(height(Ttest), 1);
actualCat(actualCharges < 4746)                            = 1; % Low
actualCat(actualCharges >= 4746  & actualCharges < 16658)  = 2; % Medium
actualCat(actualCharges >= 16658 & actualCharges < 34833)  = 3; % High
actualCat(actualCharges >= 34833)                          = 4; % VeryHigh

% Map predicted risk score to categories
predCat = zeros(length(combined_risk), 1);
predCat(combined_risk < 0.25)                              = 1; % Low
predCat(combined_risk >= 0.25 & combined_risk < 0.5)       = 2; % Medium
predCat(combined_risk >= 0.5  & combined_risk < 0.75)      = 3; % High
predCat(combined_risk >= 0.75)                             = 4; % VeryHigh

%% ── 6. CLASSIFICATION ACCURACY ───────────────────────────
correct  = sum(predCat == actualCat);
total    = length(actualCat);
accuracy = correct / total * 100;

fprintf('\n════════════════════════════════════════\n');
fprintf('  CLASSIFICATION RESULTS (test set)\n');
fprintf('════════════════════════════════════════\n');
fprintf('  Total test samples : %d\n', total);
fprintf('  Correct classified : %d\n', correct);
fprintf('  Accuracy           : %.1f%%\n', accuracy);

% Per-category breakdown
catNames = {'Low','Medium','High','VeryHigh'};
fprintf('\n  Per-category accuracy:\n');
for c = 1:4
    idx  = actualCat == c;
    n    = sum(idx);
    corr = sum(predCat(idx) == c);
    if n > 0
        fprintf('    %-10s : %3d samples, %3d correct (%.0f%%)\n', ...
            catNames{c}, n, corr, corr/n*100);
    end
end

%% ── 7. CONFUSION MATRIX ──────────────────────────────────
C = confusionmat(actualCat, predCat);
fprintf('\n  Confusion matrix (rows=actual, cols=predicted):\n');
fprintf('             Low  Med  High  VHigh\n');
rowLabels = {'Actual Low  ','Actual Med  ','Actual High ','Actual VHigh'};
for r = 1:4
    fprintf('  %s', rowLabels{r});
    fprintf('%4d ', C(r,:));
    fprintf('\n');
end

%% ── 8. ERROR DISTRIBUTION PLOT ───────────────────────────
figure('Name', 'Risk Score Distribution by Actual Charge Category');

subplot(2,2,1);
histogram(combined_risk(actualCat==1), 'BinWidth', 0.05, ...
    'FaceColor', '#1d9e75', 'EdgeColor', 'none');
title('Actual: Low charges (<$4.7k)');
xlabel('Predicted risk score'); ylabel('Count');
xlim([0 1]);

subplot(2,2,2);
histogram(combined_risk(actualCat==2), 'BinWidth', 0.05, ...
    'FaceColor', '#378ADD', 'EdgeColor', 'none');
title('Actual: Medium charges ($4.7k–$16.7k)');
xlabel('Predicted risk score'); ylabel('Count');
xlim([0 1]);

subplot(2,2,3);
histogram(combined_risk(actualCat==3), 'BinWidth', 0.05, ...
    'FaceColor', '#EF9F27', 'EdgeColor', 'none');
title('Actual: High charges ($16.7k–$34.8k)');
xlabel('Predicted risk score'); ylabel('Count');
xlim([0 1]);

subplot(2,2,4);
histogram(combined_risk(actualCat==4), 'BinWidth', 0.05, ...
    'FaceColor', '#E24B4A', 'EdgeColor', 'none');
title('Actual: Very High charges (>$34.8k)');
xlabel('Predicted risk score'); ylabel('Count');
xlim([0 1]);

sgtitle('Fuzzy Network: Predicted Risk Score by Actual Charge Category');

%% ── 9. SCATTER: predicted risk vs actual charges ─────────
figure('Name', 'Predicted Risk Score vs Actual Charges');
scatter(combined_risk, actualCharges, 20, actualCharges, 'filled', 'MarkerFaceAlpha', 0.5);
colormap(parula);
colorbar;
xlabel('Combined fuzzy risk score [0–1]');
ylabel('Actual insurance charges ($)');
title('Fuzzy Network Output vs Actual Charges (test set)');
yline(4746,  '--', '$4,746 (25th pct)',  'Color', '#1d9e75', 'LabelHorizontalAlignment', 'left');
yline(16658, '--', '$16,658 (75th pct)', 'Color', '#EF9F27', 'LabelHorizontalAlignment', 'left');
yline(34833, '--', '$34,833 (90th pct)', 'Color', '#E24B4A', 'LabelHorizontalAlignment', 'left');

fprintf('\n✓ Step 2b complete.\n');
fprintf('Key number for report: Classification Accuracy = %.1f%%\n', accuracy);
fprintf('Screenshot both figures for Results section.\n');