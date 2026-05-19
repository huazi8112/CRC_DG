% 读取数据
T = readtable("human_cleaned_expression.xlsx");

% 拆分基因编号和表达量部分
gene_names = T{:,1};                     % 第一列是基因编号
raw_expr_data = T{:,2:end};             % 后面是表达量，可能是 cell 类型

% 强制转换为数值矩阵
expr_data = str2double(raw_expr_data);  % 逐元素转换为 double（非数值将变成 NaN）

% 分组参数
group_size = 40;
[num_genes, num_samples] = size(expr_data);
num_groups = floor(num_samples / group_size);

% 初始化伪时间表达矩阵
pseudo_time_expr = zeros(num_genes, num_groups);

% 每 40 列求一组平均
for i = 1:num_groups
    col_range = (i-1)*group_size + 1 : i*group_size;
    pseudo_time_expr(:,i) = mean(expr_data(:, col_range), 2, 'omitnan');
end

% 构造列名
col_names = ["GeneID", "Time" + string(1:num_groups)];

% 合并为 table 并写出
T_out = [table(gene_names), array2table(pseudo_time_expr)];
T_out.Properties.VariableNames = col_names;

% 保存
writetable(T_out, "pseudo_time_expr.csv");
writetable(T_out, "pseudo_time_expr.xlsx");
