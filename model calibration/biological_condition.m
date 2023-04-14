function Out1=biological_condition(tmp_rdouts)

if max(tmp_rdouts) > 0.01
    Out1= 0;
else
    Out1 = 1./(0.01 + max(tmp_rdouts));
end

