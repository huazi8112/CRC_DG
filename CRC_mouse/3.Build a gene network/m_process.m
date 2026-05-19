load m_t.mat
load m_kmeans.mat %Import categorical metrics

%% Consolidate data based on cluster labels
c_set = unique(clusterIndices);
Rec_time = zeros(length(c_set),size(t_data,2)); % Store categorical data
name = num2cell(zeros(length(c_set),1)); % Record the best subclass under the large category
Rec_point = zeros(length(c_set),1);
for i = 1 : length(c_set)
    datai = t_data(clusterIndices==i,:);
    pointi = point(clusterIndices==i,:);
    [~,b_p] = max(sum(datai,2));
    name(i) = pointi(b_p);
    datai_mean = mean(datai);
    Rec_time(i,:) = datai_mean;
end
c_clust = num2cell(clusterIndices);
Rec_point = [point,c_clust];
Rec_A = transition(Rec_time);

%% Plot a heat map of the correlation coefficient
rho = corr(Rec_time'+0.001);

% ===== 统一定义阈值 =====
thr = 0.60;   % 相关系数阈值，可调整

C = [0.141176470588235	0	0.847058823529412
    0.113725490196078	0.180392156862745	0.976470588235294
    0.207843137254902	0.458823529411765	1
    0.329411764705882	0.678431372549020	1
    0.490196078431373	0.847058823529412	1
    0.674509803921569	0.949019607843137	1
    0.890196078431373	0.996078431372549	1
    1	0.992156862745098	0.890196078431373
    1	0.898039215686275	0.674509803921569
    1	0.713725490196078	0.490196078431373
    1	0.450980392156863	0.329411764705882
    0.988235294117647	0.207843137254902	0.227450980392157
    0.886274509803922	0.105882352941176	0.192156862745098
    0.647058823529412	0	0.129411764705882];

fheatmap = setHandel(12,8);
hh = heatmap(rho,'Colormap',C);
outpng(fheatmap,12,8,'m_heatmap')

maprho = zeros(size(rho));
maprho(abs(rho) >= thr) = 1;
for i = 1 : size(maprho,1)
    maprho(i,i) = 0;
end
save m_pre.mat maprho Rec_A Rec_time name Rec_point

%% === 6) 基于相关矩阵绘制网络图（紧凑 & 黑边大节点 & 大号编号）===
K = size(Rec_time,1);
A = maprho;
[i, j] = find(triu(A, 1));
if isempty(i)
    warning('在阈值 %.2f 下没有边，试着降低 thr。', thr);
end

% 边权重
w_signed = rho(sub2ind([K K], i, j));
w_abs    = abs(w_signed);
G = graph(i, j, w_abs, K);

% 节点尺寸
p_base = 8;
degG = degree(G);
if any(degG)
    scale = 1 + 0.25*(degG - min(degG)) / (max(degG)-min(degG)+eps);
else
    scale = ones(K,1);
end
MS = p_base * mean(scale);

% 边线宽
lw = 0.6 + 1.8 * (w_abs - min(w_abs)) / (max(w_abs) - min(w_abs) + eps);
% 边颜色
edge_sign  = sign(w_signed);
edge_cdata = (edge_sign > 0) + 1;
% 标签
labels = arrayfun(@num2str, 1:K, 'UniformOutput', false);

% 绘制网络
f2 = figure('Color','w','Position',[100 100 960 800]);
p  = plot(G, 'NodeLabel', []);
p.EdgeAlpha = 0.95;
p.EdgeCData = edge_cdata;
p.LineWidth = lw;
p.MarkerSize = 0.1;
layout(p, 'force', 'UseGravity', true, 'Iterations', 500, 'WeightEffect', 'direct');

% 调整布局
p.XData = p.XData + 0.01*randn(size(p.XData));
p.YData = p.YData + 0.01*randn(size(p.YData));
xc = mean(p.XData); yc = mean(p.YData);
compact = 0.36;
p.XData = xc + compact*(p.XData - xc);
p.YData = yc + compact*(p.YData - yc);

% 拉回孤点
rad = 0.18 * max(range(p.XData), range(p.YData));
lowdeg = (degG <= 1);
if any(lowdeg)
    p.XData(lowdeg) = xc + rad*randn(sum(lowdeg),1);
    p.YData(lowdeg) = yc + rad*randn(sum(lowdeg),1);
end

% 画节点
hold on;
node_face = [0.94 0.94 0.97];
sz = (MS * 3.2).^2;
scatter(p.XData, p.YData, sz, 'o', 'MarkerFaceColor', node_face, ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1.2);

% 节点编号
LBL_FONTSIZE = 18;
LBL_COLOR    = [0.10 0.10 0.10];
for kk = 1:K
    text(p.XData(kk), p.YData(kk), labels{kk}, 'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', 'FontSize', LBL_FONTSIZE, ...
        'FontWeight','bold', 'Color', LBL_COLOR, 'Clipping','on');
end
hold off;

% 颜色映射 & 坐标轴
colormap(f2, [0.85 0.33 0.10; 0.00 0.45 0.74]);
ax = ancestor(p, 'axes');
axis(ax,'equal');
axis(ax,'tight');
ax.Visible='off';
ax.FontSize=12;

% 横向小图例放右上角
cb = colorbar;
cb.Ticks = [1 2];
cb.TickLabels = {'Negative','Positive'};
cb.FontSize = 10; % 小字体
cb.Location = 'northoutside'; % 横向
cb.Box = 'off';
cb.Label.Position = [1.1 0 0]; % 标签位置微调
pos = cb.Position;
cb.Position = [0.70 0.92 0.25 0.03]; % 右上角位置 [x y 宽 高] 可调

% 标题 & 保存
title(sprintf('Correlation Network (K=%d, |r| \\ge %.2f)', K, thr), 'FontWeight','bold');
exportgraphics(f2, 'm_network.png', 'Resolution', 600);
disp('网络图已保存：m_network.png');
