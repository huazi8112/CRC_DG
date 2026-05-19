% Data Preprocessor
%% Data preprocessing
clear,clc;
[data,txt] = xlsread("pseudo_time_expr.xlsx");%Import merged data
%% 数据预处理
gene_names = txt(2:end, 1);  % 提取基因名（跳过标题）

n = 6;  % 时间点数量：week-0 ~ week-10

% 数据预处理
t_data = data;  % 每行一个基因，每列一个时间点（已平均）
point = gene_names;   % 基因名作为 point 列表

% 删除方差为 0 的基因
var0_index = var(t_data, 0, 2) == 0;
t_data(var0_index, :) = [];
point(var0_index, :) = [];

% 删除平均表达量 <= 1 的基因（低表达）
low_expr_index = mean(t_data, 2) <= 1;
t_data(low_expr_index, :) = [];
point(low_expr_index, :) = [];

%% 样条插值处理（将 5 个时间点插值为更密集的序列）
interp_points = 1:0.1:6;
n_interp = length(interp_points);
t_ex_data = zeros(size(t_data, 1), n_interp);

for i = 1:size(t_data, 1)
    t_ex_data(i, :) = interp1(1:n, t_data(i, :), interp_points, 'spline');
end

% 最终结果
clear t_data
t_data = t_ex_data;

% 保存为 MATLAB 文件
save h_t.mat point t_data;
