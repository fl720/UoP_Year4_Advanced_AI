%% =========================================================
%  EXPLORE_DATA.M  –  Exploratory Data Analysis (EDA)
%
%  HOW TO RUN:
%    1. In Matlab, cd to the nn_osteoporosis folder
%    2. Type:  run('explore_data.m')
%       OR simply:  explore_data
%
%  Produces 4 figures for the report:
%    Fig 1 – Class distribution bar chart
%    Fig 2 – Missing value heatmap
%    Fig 3 – Pearson correlation heatmap
%    Fig 4 – Box plots of key features by class
% =========================================================
clc; clear; close all;

%% ── Load raw data ────────────────────────────────────────
filename = 'M33176_1_CW_REF_DEF_AppendixA Osteoporosis Dataset.xlsx';
if ~isfile(filename)
    error('Cannot find %s – please cd to the correct folder first.', filename);
end

T = readtable(filename, 'VariableNamingRule', 'preserve');
y_raw = T.VBX;
T.VBX = [];
varNames = T.Properties.VariableNames;

for k = 1:numel(varNames)
    col = T.(varNames{k});
    if iscell(col) || isstring(col)
        col = strtrim(string(col));
        col(col == "") = "NaN";
        T.(varNames{k}) = str2double(col);
    end
end
X_raw = table2array(T);

fprintf('Dataset: %d samples, %d features\n', size(X_raw,1), size(X_raw,2));
fprintf('Class 0 (Healthy): %d  |  Class 1 (Fracture): %d\n', ...
        sum(y_raw==0), sum(y_raw==1));

%% ── Fig 1: Class distribution ────────────────────────────
figure('Name','Fig1 Class Distribution','NumberTitle','off');
n0 = sum(y_raw==0);
n1 = sum(y_raw==1);
bar([1 2],[n0 n1],0.5,'FaceColor',[0.25 0.60 0.90]);
set(gca,'XTick',[1 2],'XTickLabel',{'Healthy (VBX=0)','Fracture (VBX=1)'});
ylabel('Number of Samples');
title('Class Distribution – Osteoporosis Dataset');
text(1,n0+8,num2str(n0),'HorizontalAlignment','center','FontWeight','bold','FontSize',11);
text(2,n1+8,num2str(n1),'HorizontalAlignment','center','FontWeight','bold','FontSize',11);
ylim([0 560]); grid on;

%% ── Fig 2: Missing value heatmap ─────────────────────────
figure('Name','Fig2 Missing Values','NumberTitle','off','Position',[100 100 900 420]);
imagesc(double(isnan(X_raw))');
colormap([0.95 0.95 0.95; 0.85 0.15 0.15]);
xlabel('Sample Index'); ylabel('Feature');
title('Missing Value Map  (red = missing)');
yticks(1:numel(varNames)); yticklabels(varNames);
set(gca,'FontSize',8);
colorbar('Ticks',[0.25 0.75],'TickLabels',{'Present','Missing'});

fprintf('\nMissing values:\n');
for k = 1:numel(varNames)
    n_miss = sum(isnan(X_raw(:,k)));
    if n_miss > 0
        fprintf('  %-22s %d/600 (%.1f%%)\n',varNames{k},n_miss,n_miss/600*100);
    end
end

%% ── Median impute for Figs 3 & 4 (visualisation only) ───
X_imp = X_raw;
for j = 1:size(X_raw,2)
    m_idx = isnan(X_imp(:,j));
    if any(m_idx), X_imp(m_idx,j) = median(X_imp(~m_idx,j)); end
end

%% ── Fig 3: Pearson correlation heatmap ───────────────────
C = corr(X_imp,'rows','pairwise');
figure('Name','Fig3 Correlation','NumberTitle','off','Position',[100 100 820 700]);
imagesc(C,[-1 1]);
half=128; r=[linspace(0,1,half),ones(1,half)];
g=[linspace(0,1,half),linspace(1,0,half)];
b=[ones(1,half),linspace(1,0,half)];
colormap([r(:),g(:),b(:)]);
colorbar;
xticks(1:numel(varNames)); xticklabels(varNames); xtickangle(45);
yticks(1:numel(varNames)); yticklabels(varNames);
set(gca,'FontSize',7);
title('Pearson Correlation Matrix – All 25 Features');

%% ── Fig 4: Box plots – key features by class ─────────────
keyIdx  = [2, 4, 5, 6, 7, 14];
keyLbls = varNames(keyIdx);
figure('Name','Fig4 Feature Distributions','NumberTitle','off','Position',[100 100 960 480]);
for k = 1:numel(keyIdx)
    subplot(2,3,k);
    j = keyIdx(k);
    data0 = X_imp(y_raw==0,j); data1 = X_imp(y_raw==1,j);
    boxplot([data0;data1],[zeros(numel(data0),1);ones(numel(data1),1)],...
            'Labels',{'Healthy','Fracture'});
    title(keyLbls{k},'FontSize',9); grid on;
end
sgtitle('Key Feature Distributions by Class');

fprintf('\nEDA complete – 4 figures generated.\n');