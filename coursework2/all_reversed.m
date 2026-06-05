% =========================================================
% M33176 Coursework 2 - Medical Insurance Fuzzy Network
% COMPLETE REVISED SCRIPT - Steps 1 to 4
%
% ARCHITECTURE CHANGE:
%   RB1: smoker(2) x age(3) -> risk_index(3)   [6 rules, 6x3 matrix]
%   RB2: risk_index(3)      -> charge_cat(2)   [3 rules, 3x2 matrix]
%   horizontal_merging: RB1(6x3) * RB2(3x2) -> merged(6x2)
%   inputs=[2,3], outputs=[2]
%   meaning: (smoker, age) -> (LowMedium / High)
%
% WHY THIS WORKS:
%   Smoker is the #1 predictor (92.8% accuracy alone at $16k threshold)
%   Age is the #2 predictor among non-smokers
%   BMI is #3 - handled separately in FIS1 (age+bmi -> body_risk)
%   This architecture uses horizontal_merging correctly AND maximises accuracy
%
% Run Steps 1&2 first for fis1, fis2, Ttrain, Ttest in workspace.
% =========================================================

fprintf('==============================================\n');
fprintf('  REVISED FUZZY NETWORK - COMPLETE EVALUATION\n');
fprintf('==============================================\n\n');

%% STEP 1 - Reload data (run step1 script first)
% Assumes Ttest and Ttrain are already in workspace from step1 script.

%% STEP 2 - Reload FIS2 (run step2 script first)
% Assumes fis2 is already in workspace.

%% STEP 3 REVISED - New RB1 and RB2 with smoker+age inputs
fprintf('--- STEP 3: Building Revised Fuzzy Network ---\n\n');

% RB1: smoker(2) x age(3) -> risk_index(3)
% Row order: (smoker1,age1)(smoker1,age2)(smoker1,age3)
%            (smoker2,age1)(smoker2,age2)(smoker2,age3)
% = NonSmoker+Young, NonSmoker+Middle, NonSmoker+Senior,
%   Smoker+Young,    Smoker+Middle,    Smoker+Senior
%
% Data-grounded mapping:
%   NonSmoker+Young  mean=$5,173  -> Low (index 1)
%   NonSmoker+Middle mean=$7,322  -> Low (index 1)
%   NonSmoker+Senior mean=$12,571 -> Medium (index 2)
%   Smoker+Young     mean=$23,936 -> High (index 3)
%   Smoker+Middle    mean=$28,404 -> High (index 3)
%   Smoker+Senior    mean=$32,010 -> High (index 3)
%
% Cols: [Low  Medium  High]
%         1      2      3

boolRB1 = [
%  L  M  H
   1  0  0;   % NonSmoker + Young  -> Low
   1  0  0;   % NonSmoker + Middle -> Low
   0  1  0;   % NonSmoker + Senior -> Medium
   0  0  1;   % Smoker    + Young  -> High
   0  0  1;   % Smoker    + Middle -> High
   0  0  1;   % Smoker    + Senior -> High
];

inputLTCounts_RB1  = [2 3];   % smoker:2, age:3
outputLTCounts_RB1 = [3];     % risk_index:3

fprintf('RB1 (smoker x age -> risk_index):\n');
fprintf('  Shape: %d x %d, Inputs=[%s], Outputs=[%s]\n', ...
    size(boolRB1), num2str(inputLTCounts_RB1), num2str(outputLTCounts_RB1));

% Validate RB1
groups1 = {1:2, 3:5, 6:8};
colsets = {[1 2], [3 4 5], [6 7 8]};
% Simple check: each row sums to 1 (one output active)
assert(all(sum(boolRB1,2)==1), 'RB1 row sums must be 1');
fprintf('  Validation: OK (each rule activates exactly 1 output term)\n\n');

% RB2: risk_index(3) -> charge_category(2)
% Rows must equal cols(RB1) = 3
% Cols: [LowMedium  High]
%          1           2
%
% Data-grounded:
%   index=Low    (non-smoker young/middle) -> LowMedium charges
%   index=Medium (non-smoker senior)       -> LowMedium (mean $12,571 < $16k)
%   index=High   (smoker any age)          -> High charges

boolRB2 = [
%  LM   H
   1    0;   % Low risk_index    -> LowMedium charge
   1    0;   % Medium risk_index -> LowMedium charge
   0    1;   % High risk_index   -> High charge
];

inputLTCounts_RB2  = [3];   % risk_index:3
outputLTCounts_RB2 = [2];   % charge_cat:2

fprintf('RB2 (risk_index -> charge_category):\n');
fprintf('  Shape: %d x %d, Inputs=[%s], Outputs=[%s]\n', ...
    size(boolRB2), num2str(inputLTCounts_RB2), num2str(outputLTCounts_RB2));

% Compatibility check
fprintf('\nCompatibility: cols(RB1)=%d, rows(RB2)=%d -> ', ...
    size(boolRB1,2), size(boolRB2,1));
if size(boolRB1,2) == size(boolRB2,1)
    fprintf('COMPATIBLE\n\n');
else
    fprintf('INCOMPATIBLE - cannot merge\n');
    return;
end

% Horizontal merging
[boolRB_merged, inputLT_merged, outputLT_merged] = ...
    horizontal_merging(boolRB1, inputLTCounts_RB1, outputLTCounts_RB1, ...
                       boolRB2, inputLTCounts_RB2, outputLTCounts_RB2);

fprintf('MERGED NETWORK STRUCTURE:\n');
fprintf('  inputLTCounts  : [%s] -> smoker(2), age(3)\n', num2str(inputLT_merged));
fprintf('  outputLTCounts : [%s] -> LowMedium(1), High(2)\n', num2str(outputLT_merged));
fprintf('  Merged RB size : %d x %d\n', size(boolRB_merged));
fprintf('  Total rules    : %d\n\n', size(boolRB_merged,1));

% Display rule table
fprintf('  Merged rule table:\n');
fprintf('  %-30s  LowMedium  High\n', 'Input combination');
fprintf('  %s\n', repmat('-',1,48));
combo_labels = {
    'NonSmoker + Young '
    'NonSmoker + Middle'
    'NonSmoker + Senior'
    'Smoker    + Young '
    'Smoker    + Middle'
    'Smoker    + Senior'
};
for i = 1:size(boolRB_merged,1)
    fprintf('  %s      %d         %d\n', ...
        combo_labels{i}, boolRB_merged(i,1), boolRB_merged(i,2));
end

% Save
save('merged_fuzzy_network_v2.mat', ...
    'boolRB_merged','inputLT_merged','outputLT_merged', ...
    'boolRB1','boolRB2', ...
    'inputLTCounts_RB1','outputLTCounts_RB1', ...
    'inputLTCounts_RB2','outputLTCounts_RB2');
fprintf('\nSaved to merged_fuzzy_network_v2.mat\n\n');

%% STEP 4 - EVALUATION
fprintf('--- STEP 4: EVALUATION ---\n\n');

actualCharges = Ttest.charges;
actualCat = (actualCharges >= 16000) + 1;  % 1=LowMedium, 2=High
catNames = {'LowMedium','High'};

n_lm = sum(actualCat==1); n_hi = sum(actualCat==2);
fprintf('Test set: n=%d | LowMedium=%d | High=%d\n\n', height(Ttest), n_lm, n_hi);

% Discretise smoker (already 0/1, map to 1/2 for row index)
smoker_disc = Ttest.smoker_num + 1;  % 1=NonSmoker, 2=Smoker

% Discretise age
age_test = Ttest.age;
age_disc = ones(height(Ttest),1) * 2;  % default Middle
age_disc(age_test < 30) = 1;            % Young
age_disc(age_test >= 50) = 3;           % Senior

% Map to row index in merged RB (1-6)
% Row order: NonSmoker+Young(1) NonSmoker+Middle(2) NonSmoker+Senior(3)
%            Smoker+Young(4)    Smoker+Middle(5)    Smoker+Senior(6)
rowIdx = (smoker_disc - 1)*3 + age_disc;

% Predict from merged RB
predCat_merged = zeros(height(Ttest),1);
for i = 1:height(Ttest)
    row = boolRB_merged(rowIdx(i),:);
    predCat_merged(i) = find(row==1, 1);
end

acc_merged = sum(predCat_merged==actualCat)/height(Ttest)*100;
fprintf('-- MERGED NETWORK (smoker+age) --\n');
fprintf('   Accuracy: %.1f%%\n', acc_merged);
C_merged = confusionmat(actualCat, predCat_merged);
for c=1:2
    idx=actualCat==c; n=sum(idx); corr=sum(predCat_merged(idx)==c);
    fprintf('   %-12s: %3d samples, %3d correct (%2.0f%%)\n',catNames{c},n,corr,corr/n*100);
end

% FIS2 evaluation (smoker+children -> lifestyle_risk)
pred_lifestyle = evalfis(fis2, [Ttest.smoker_num, Ttest.children_clipped]);
predCat_fis2 = ones(height(Ttest),1);
predCat_fis2(pred_lifestyle >= 0.5) = 2;

acc_fis2 = sum(predCat_fis2==actualCat)/height(Ttest)*100;
fprintf('\n-- FIS2 ALONE (smoker+children) --\n');
fprintf('   Accuracy: %.1f%%\n', acc_fis2);
for c=1:2
    idx=actualCat==c; n=sum(idx); corr=sum(predCat_fis2(idx)==c);
    fprintf('   %-12s: %3d samples, %3d correct (%2.0f%%)\n',catNames{c},n,corr,corr/n*100);
end

% Combined: where both agree use that; else use FIS2 (smoker dominant)
predCat_combined = predCat_fis2;
agree = predCat_merged == predCat_fis2;
predCat_combined(agree) = predCat_merged(agree);

acc_combined = sum(predCat_combined==actualCat)/height(Ttest)*100;
fprintf('\n-- COMBINED SYSTEM --\n');
fprintf('   Accuracy: %.1f%%\n', acc_combined);
for c=1:2
    idx=actualCat==c; n=sum(idx); corr=sum(predCat_combined(idx)==c);
    fprintf('   %-12s: %3d samples, %3d correct (%2.0f%%)\n',catNames{c},n,corr,corr/n*100);
end

C = confusionmat(actualCat, predCat_combined);
fprintf('\n   Confusion matrix:\n');
fprintf('                  Pred:LowMed  Pred:High\n');
fprintf('   Actual LowMed     %3d          %3d\n', C(1,1), C(1,2));
fprintf('   Actual High       %3d          %3d\n', C(2,1), C(2,2));

TP=C(2,2); FP=C(1,2); FN=C(2,1);
prec=TP/(TP+FP); rec=TP/(TP+FN); f1=2*prec*rec/(prec+rec);
fprintf('\n   Precision: %.1f%%  Recall: %.1f%%  F1: %.3f\n', prec*100, rec*100, f1);

% FIS1 standalone (age+bmi -> body_risk continuous)
pred_body = evalfis(fis1, [Ttest.age, Ttest.bmi]);
predCat_fis1 = ones(height(Ttest),1);
predCat_fis1(pred_body >= 0.5) = 2;
acc_fis1 = sum(predCat_fis1==actualCat)/height(Ttest)*100;
fprintf('\n-- FIS1 ALONE (age+bmi -> body_risk) --\n');
fprintf('   Accuracy: %.1f%%  [weaker predictor, no smoker info]\n', acc_fis1);

%% COMPARISON TABLE
fprintf('\n=====================================================\n');
fprintf('  PERFORMANCE COMPARISON TABLE (for report)\n');
fprintf('=====================================================\n');
fprintf('  %-42s  %s\n','Method','Performance');
fprintf('  %s\n', repmat('-',1,60));
fprintf('  %-42s  R2=0.744\n','Linear Regression [Orji et al. 2024]');
fprintf('  %-42s  R2=0.826\n','Random Forest [Orji et al. 2024]');
fprintf('  %-42s  R2=0.880\n','XGBoost [Orji et al. 2024]');
fprintf('  %s\n', repmat('-',1,60));
fprintf('  %-42s  %.1f%% (binary)\n','FIS1: HealthRisk (age+bmi)', acc_fis1);
fprintf('  %-42s  %.1f%% (binary)\n','FIS2: LifestyleRisk (smoker+children)', acc_fis2);
fprintf('  %-42s  %.1f%% (binary)\n','Merged Network: smoker+age [this work]', acc_merged);
fprintf('  %-42s  %.1f%% (binary), F1=%.3f\n','Combined Fuzzy Network [this work]', acc_combined, f1);
fprintf('  %s\n', repmat('-',1,60));

%% FIGURES
% Fig 1: Confusion matrix
figure('Name','Fig1 Confusion Matrix');
imagesc(C); colormap(flipud(bone)); colorbar;
set(gca,'XTick',1:2,'XTickLabel',catNames,'YTick',1:2,'YTickLabel',catNames,'FontSize',12);
xlabel('Predicted'); ylabel('Actual');
title(sprintf('Confusion Matrix - Combined Fuzzy Network (Accuracy=%.1f%%)', acc_combined));
maxV=max(C(:));
for r=1:2; for c=1:2
    if C(r,c)>maxV*0.4; tc='w'; else; tc='k'; end
    text(c,r,num2str(C(r,c)),'HorizontalAlignment','center','FontSize',16,'FontWeight','bold','Color',tc);
end; end

% Fig 2: FIS2 output distribution
figure('Name','Fig2 Risk Distribution');
hold on;
histogram(pred_lifestyle(actualCat==1),'BinWidth',0.05,'FaceColor','#1d9e75','FaceAlpha',0.7,'DisplayName','Actual: LowMedium (<$16k)');
histogram(pred_lifestyle(actualCat==2),'BinWidth',0.05,'FaceColor','#e24b4a','FaceAlpha',0.7,'DisplayName','Actual: High (>=$16k)');
xline(0.5,'--k','LineWidth',2,'Label','Decision threshold=0.5');
xlabel('FIS2 Lifestyle Risk Score [0-1]');
ylabel('Count'); title('FIS2 Output Distribution by Actual Charge Category');
legend('Location','north'); grid on; box off;

% Fig 3: Scatter risk score vs charges
figure('Name','Fig3 Scatter');
scatter(pred_lifestyle, actualCharges, 25, actualCharges,'filled','MarkerFaceAlpha',0.6);
colormap(parula); colorbar;
xlabel('Lifestyle Risk Score [0-1] (FIS2)');
ylabel('Actual Insurance Charges ($)');
title('FIS2 Risk Score vs Actual Charges (Test Set n=267)');
yline(16000,'--r','LineWidth',2,'Label','$16,000 decision boundary');
grid on;

fprintf('\n================================\n');
fprintf('KEY NUMBERS FOR YOUR REPORT:\n');
fprintf('================================\n');
fprintf('FIS1 alone     (age+bmi)             : %.1f%%\n', acc_fis1);
fprintf('FIS2 alone     (smoker+children)      : %.1f%%\n', acc_fis2);
fprintf('Merged Network (smoker+age, cascaded) : %.1f%%\n', acc_merged);
fprintf('Combined System                       : %.1f%%\n', acc_combined);
fprintf('High-class F1                         : %.3f\n', f1);
fprintf('High-class Precision                  : %.1f%%\n', prec*100);
fprintf('High-class Recall                     : %.1f%%\n', rec*100);
fprintf('\nML benchmarks (Orji et al. 2024 - regression task):\n');
fprintf('  Linear Regression  R2 : 0.744\n');
fprintf('  Random Forest      R2 : 0.826\n');
fprintf('  XGBoost            R2 : 0.880\n');
fprintf('\nAll steps complete.\n');