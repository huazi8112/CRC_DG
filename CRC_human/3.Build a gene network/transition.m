%Gene kinetic transformation
function A = transition(t_data)
Q=[];
for i = 0:20:100
    Q1 = prctile (t_data(:),i);
    Q = [Q,Q1];
end
A = zeros(size(t_data,1),length(Q)-1);
for i = 1 : size(t_data,1)
    a = histcounts(t_data(i,:),Q);
    A(i,:) = a;
end