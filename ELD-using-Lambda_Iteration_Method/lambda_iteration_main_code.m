clc
ELD_data
N = length(PG_data(:,1));
temp_pg=pd/N;
a = PG_data(:,1);
b = PG_data(:,2);
c = PG_data(:,3);
pg_min = PG_data(:,4);
pg_max = PG_data(:,5);
pd; % demand value
pg=zeros(1,N);
ploss=(temp_pg^2*PG_data(:,7));
total_ploss=sum(ploss);
pf=1./(1-2*temp_pg.*PG_data(:,7)); 
fprintf("pf(1) : %f\n",pf(1))
fprintf("pf(2) : %f\n",pf(2))
fprintf("pf(3) : %f\n",pf(3))
ploss_temp=sum(ploss);

for iteration = 1:10000
    fprintf("ploss_temp = %f\n",ploss_temp)
    pg=lambda_iteration_function(ploss_temp,pf);
    pf_new=1./(1-2*pg.*PG_data(:,7));
    ploss_new=sum(PG_data(:,7)'.*pg.^2);
    diff_ploss=ploss_new-ploss_temp;
    ploss_temp = ploss_new;
    if abs(diff_ploss)<error_tolerance_ploss_diff
        break
    end
end

fprintf(" pg_1 = %f\n",pg(1))
fprintf(" pg_2 = %f\n",pg(2))
fprintf(" pg_3 = %f\n",pg(3))
fprintf(" sum of pg = %f\n",sum(pg))
fprintf(" pf_1 = %f\n",pf(1))
fprintf(" pf_2 = %f\n",pf(2))
fprintf(" pf_3 = %f\n",pf(3))
fprintf(" ploss = %f\n",ploss)
fprintf(" sum(ploss) = %f\n", sum(ploss))
fprintf(" ploss_new = %f\n",ploss_new)
fprintf(" sum(ploss_new) = %f\n", sum(ploss_new))
fprintf(" ploss_new+pd = %f\n",sum(ploss_new)+pd)