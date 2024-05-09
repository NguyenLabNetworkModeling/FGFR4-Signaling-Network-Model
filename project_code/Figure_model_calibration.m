% Figure 2B, S14, S17, S43
% Calibration result of the Model-1/-2/-3, and Reduced model

function Figure_model_calibration

plots = {
    'Figure 2B' % Calibration result of the Mode-l
    'Figure S11' % Calibration result of the Mode-2
    'Figure S17' % % Calibration result of the Mode-3
    'Figure S41' % % Calibration result of the reduced model
    };

figure_number = plots{readInput(plots)}; % Selected

switch figure_number

    case 'Figure 2B'

        file1 = 'Figure_2B.xlsx';

        % BLU dose
        fig2_dat_1 = readtable(file1,'Sheet','BLU9931_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:4));
        dose_exp_avg = table2array(fig2_dat_1(:,5:end));
        fig2_dat_2 = readtable(file1,'Sheet','BLU9931_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:4));
        dose_exp_std = table2array(fig2_dat_2(:,5:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:4);


        figure('Position',[ 584   729   560   152],'Name','BLU9931-dose-response')
        for ii = 1:4
            subplot(1,4,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BLU9931 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)

        end

        % BLU time
        fig2_dat_3 = readtable(file1,'Sheet','BLU9931_time_avg','ReadRowNames',true);
        time_sim_avg = table2array(fig2_dat_3(:,1:4));
        time_exp_avg = table2array(fig2_dat_3(:,5:end));
        fig2_dat_4 = readtable(file1,'Sheet','BLU9931_time_std','ReadRowNames',true);
        time_sim_std = table2array(fig2_dat_4(:,1:4));
        time_exp_std = table2array(fig2_dat_4(:,5:end));
        xtime = cellfun(@str2double, fig2_dat_3.Properties.RowNames);
        time_vars = fig2_dat_3.Properties.VariableNames(1:4);



        figure('Position',[ 584   729   560   152],'Name','BLU9931 time-course')
        for ii = 1:4
            subplot(1,4,ii)
            errorbar(xtime,time_sim_avg(:,ii),time_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xtime,time_exp_avg(:,ii),time_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(time_vars{ii},'(norm.)'))
            %legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)

        end



    case 'Figure S11'

        file1 = 'Figure_S11.xlsx';

        % BLU dose
        fig2_dat_1 = readtable(file1,'Sheet','BLU9931_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:4));
        dose_exp_avg = table2array(fig2_dat_1(:,5:end));
        fig2_dat_2 = readtable(file1,'Sheet','BLU9931_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:4));
        dose_exp_std = table2array(fig2_dat_2(:,5:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:4);


        figure('Position',[ 584   729   560   152],'Name','BLU9931 dose-response')
        for ii = 1:4
            subplot(1,4,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BLU9931 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
        end

        % BLU time
        fig2_dat_3 = readtable(file1,'Sheet','BLU9931_time_avg','ReadRowNames',true);
        time_sim_avg = table2array(fig2_dat_3(:,1:4));
        time_exp_avg = table2array(fig2_dat_3(:,5:end));
        fig2_dat_4 = readtable(file1,'Sheet','BLU9931_time_std','ReadRowNames',true);
        time_sim_std = table2array(fig2_dat_4(:,1:4));
        time_exp_std = table2array(fig2_dat_4(:,5:end));
        xtime = cellfun(@str2double, fig2_dat_3.Properties.RowNames);
        time_vars = fig2_dat_3.Properties.VariableNames(1:4);

        figure('Position',[ 584   729   560   152],'Name','BLU9931 time-course')
        for ii = 1:4
            subplot(1,4,ii)
            errorbar(xtime,time_sim_avg(:,ii),time_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xtime,time_exp_avg(:,ii),time_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(time_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
        end

        % BYL dose
        fig2_dat_1 = readtable(file1,'Sheet','BYL719_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:3));
        dose_exp_avg = table2array(fig2_dat_1(:,4:end));
        fig2_dat_2 = readtable(file1,'Sheet','BYL719_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:3));
        dose_exp_std = table2array(fig2_dat_2(:,4:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:3);

        figure('Position',[591   483   441   152],'Name','BYL719 dose-response')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BYL719 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end


        % BLU9931 dose-response (+BYL719 50nM)
        fig2_dat_1 = readtable(file1,'Sheet','BLU9931_BYL719_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:3));
        dose_exp_avg = table2array(fig2_dat_1(:,4:end));
        fig2_dat_2 = readtable(file1,'Sheet','BLU9931_BYL719_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:3));
        dose_exp_std = table2array(fig2_dat_2(:,4:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:3);

        figure('Position',[591   483   441   152],'Name','BLU9931 dose-response (+BYL719 50nM)')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BLU9931 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end



        % BLU9931 time-course (+BYL719 50nM)

        fig2_dat_1 = readtable(file1,'Sheet','BLU9931_BYL719_time_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:3));
        dose_exp_avg = table2array(fig2_dat_1(:,4:end));
        fig2_dat_2 = readtable(file1,'Sheet','BLU9931_BYL719_time_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:3));
        dose_exp_std = table2array(fig2_dat_2(:,4:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:3);

        figure('Position',[591   483   441   152],'Name','BLU9931 time-response (+BYL719 50nM)')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end




    case 'Figure S17'

        file1 = 'Figure_S17_lines.xlsx';

        % BLU dose
        fig2_dat_1 = readtable(file1,'Sheet','BLU9931_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:4));
        dose_exp_avg = table2array(fig2_dat_1(:,5:end));
        fig2_dat_2 = readtable(file1,'Sheet','BLU9931_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:4));
        dose_exp_std = table2array(fig2_dat_2(:,5:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:4);


        figure('Position',[ 584   729   560   152],'Name','BLU9931 dose-response')
        for ii = 1:4
            subplot(1,4,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BLU9931 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
        end

        % BLU time
        fig2_dat_3 = readtable(file1,'Sheet','BLU9931_time_avg','ReadRowNames',true);
        time_sim_avg = table2array(fig2_dat_3(:,1:4));
        time_exp_avg = table2array(fig2_dat_3(:,5:end));
        fig2_dat_4 = readtable(file1,'Sheet','BLU9931_time_std','ReadRowNames',true);
        time_sim_std = table2array(fig2_dat_4(:,1:4));
        time_exp_std = table2array(fig2_dat_4(:,5:end));
        xtime = cellfun(@str2double, fig2_dat_3.Properties.RowNames);
        time_vars = fig2_dat_3.Properties.VariableNames(1:4);

        figure('Position',[ 614   217   560   152],'Name','BLU9931 time-course')
        for ii = 1:4
            subplot(1,4,ii)
            errorbar(xtime,time_sim_avg(:,ii),time_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xtime,time_exp_avg(:,ii),time_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(time_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
        end

        % BYL dose
        fig2_dat_1 = readtable(file1,'Sheet','BYL719_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:3));
        dose_exp_avg = table2array(fig2_dat_1(:,4:end));
        fig2_dat_2 = readtable(file1,'Sheet','BYL719_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:3));
        dose_exp_std = table2array(fig2_dat_2(:,4:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:3);

        figure('Position',[277   478   457   152],'Name','BYL719 dose-response')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BYL719 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end


        % MK2206 time-course

        fig2_dat_1 = readtable(file1,'Sheet','MK2206_time_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:2));
        dose_exp_avg = table2array(fig2_dat_1(:,3:end));
        fig2_dat_2 = readtable(file1,'Sheet','MK2206_time_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:2));
        dose_exp_std = table2array(fig2_dat_2(:,3:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:2);

        figure('Position',[ 583   488   297   152],'Name','MK2206 time-course')
        for ii = 1:2
            subplot(1,2,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end


        %  Figure S17 : BLU9931 time course (10nM BLU and 100nM BLU)

        file1 = 'Figure_S17_bars.xlsx';

        sheets = {'BLU9931_pIRS_sim','BLU9931_pIGF1R_sim','BLU9931_pERBB_sim',...
            'BLU9931_pIRS_exp','BLU9931_pIGF1R_exp','BLU9931_pERBB_exp'};

        ylabs = {'pIRS(norm.)','pIGF1R(norm.)','pERBB(norm.)',...
            'pIRS(norm.)','pIGF1R(norm.)','pERBB(norm.)'};

        for ii = 1:length(sheets)

            fig2_dat_1 = readtable(file1,'Sheet',sheets{ii},'ReadRowNames',true);

            figure('Position',[448 + 100*(ii-1)   633   205   164])
            dat_avg = table2array(fig2_dat_1(:,1:2));
            dat_std = table2array(fig2_dat_1(:,3:end));
            bar(dat_avg)
            xticklabels({'0','1','24'})
            xlabel('time (hr)')
            ylabel(ylabs{ii})
            legend('10nM BLU','100nM BLU')
            box off

        end


        %  Figure S17 : Lapatinib time course

        sheets = {'Lap_pERBB','Lap_pAKT','Lap_pS6K','Lap_pERK'};
        ylabs = {'pERBB(norm.)','pAKT(norm.)','pS6K(norm.)','pERK(norm.)'};

        for ii = 1:length(sheets)

            fig2_dat_1 = readtable(file1,'Sheet',sheets{ii},'ReadRowNames',true);

            figure('Position',[448 + 100*(ii-1)   318   205   164])
            dat_avg = table2array(fig2_dat_1(:,1:2));
            dat_std = table2array(fig2_dat_1(:,3:end));
            bar(dat_avg)
            xticklabels({'0','24'})
            xlabel('time (hr)')
            ylabel(ylabs{ii})
            legend('sim','exp')
            box off

        end


    case 'Figure S41'


        file1 = 'Figure_S41_lines.xlsx';

        % BLU dose
        fig2_dat_1 = readtable(file1,'Sheet','BLU9931_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:3));
        dose_exp_avg = table2array(fig2_dat_1(:,4:end));
        fig2_dat_2 = readtable(file1,'Sheet','BLU9931_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:3));
        dose_exp_std = table2array(fig2_dat_2(:,4:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:3);


        figure('Position',[ 584   729   560   152],'Name','BLU9931 dose-response')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BLU9931 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
        end

        % BLU time
        fig2_dat_3 = readtable(file1,'Sheet','BLU9931_time_avg','ReadRowNames',true);
        time_sim_avg = table2array(fig2_dat_3(:,1:3));
        time_exp_avg = table2array(fig2_dat_3(:,4:end));
        fig2_dat_4 = readtable(file1,'Sheet','BLU9931_time_std','ReadRowNames',true);
        time_sim_std = table2array(fig2_dat_4(:,1:3));
        time_exp_std = table2array(fig2_dat_4(:,4:end));
        xtime = cellfun(@str2double, fig2_dat_3.Properties.RowNames);
        time_vars = fig2_dat_3.Properties.VariableNames(1:3);

        figure('Position',[ 614   217   560   152],'Name','BLU9931 time-course')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xtime,time_sim_avg(:,ii),time_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xtime,time_exp_avg(:,ii),time_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(time_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
        end

        % BYL dose
        fig2_dat_1 = readtable(file1,'Sheet','BYL719_dose_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:3));
        dose_exp_avg = table2array(fig2_dat_1(:,4:end));
        fig2_dat_2 = readtable(file1,'Sheet','BYL719_dose_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:3));
        dose_exp_std = table2array(fig2_dat_2(:,4:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:3);

        figure('Position',[277   478   457   152],'Name','BYL719 dose-response')
        for ii = 1:3
            subplot(1,3,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('BYL719 (nM)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end


        % MK2206 time-course
        fig2_dat_1 = readtable(file1,'Sheet','MK2206_time_avg','ReadRowNames',true);
        dose_sim_avg = table2array(fig2_dat_1(:,1:2));
        dose_exp_avg = table2array(fig2_dat_1(:,3:end));
        fig2_dat_2 = readtable(file1,'Sheet','MK2206_time_std','ReadRowNames',true);
        dose_sim_std = table2array(fig2_dat_2(:,1:2));
        dose_exp_std = table2array(fig2_dat_2(:,3:end));
        xdose = cellfun(@str2double, fig2_dat_1.Properties.RowNames);
        dose_vars = fig2_dat_1.Properties.VariableNames(1:2);

        figure('Position',[ 583   488   297   152],'Name','MK2206 time-course')
        for ii = 1:2
            subplot(1,2,ii)
            errorbar(xdose,dose_sim_avg(:,ii),dose_sim_std(:,ii),'LineWidth',2)
            hold on
            errorbar(xdose,dose_exp_avg(:,ii),dose_exp_std(:,ii),'LineWidth',2)
            xlabel('time (hr)')
            ylabel(strcat(dose_vars{ii},'(norm.)'))
            % legend('sim','exp')
            pbaspect([4 3 1])
            box off
            set(gca,'LineWidth',1)
            axis([0 inf 0 inf])
        end


        %  Figure S41 : BLU9931 time course (10nM BLU and 100nM BLU)
        file1 = 'Figure_S41_bars.xlsx';

        sheets = {'BLU9931_pIGF1R_sim','BLU9931_pERBB_sim',...
            'BLU9931_pIGF1R_exp','BLU9931_pERBB_exp'};

        ylabs = {'pIGF1R(norm.)','pERBB(norm.)',...
            'pIGF1R(norm.)','pERBB(norm.)'};

        for ii = 1:length(sheets)

            fig2_dat_1 = readtable(file1,'Sheet',sheets{ii},'ReadRowNames',true);

            figure('Position',[448 + 100*(ii-1)   633   205   164])
            dat_avg = table2array(fig2_dat_1(:,1:2));
            dat_std = table2array(fig2_dat_1(:,3:end));
            bar(dat_avg)
            xticklabels({'0','1','24'})
            xlabel('time (hr)')
            ylabel(ylabs{ii})
            legend('10nM BLU','100nM BLU')
            box off

        end


        %  Figure S41 : Lapatinib time course
        sheets = {'Lap_pERBB','Lap_pAKT','Lap_pS6K','Lap_pERK'};
        ylabs = {'pERBB(norm.)','pAKT(norm.)','pS6K(norm.)','pERK(norm.)'};

        for ii = 1:length(sheets)

            fig2_dat_1 = readtable(file1,'Sheet',sheets{ii},'ReadRowNames',true);

            figure('Position',[448 + 100*(ii-1)   318   205   164])
            dat_avg = table2array(fig2_dat_1(:,1:2));
            dat_std = table2array(fig2_dat_1(:,3:end));
            bar(dat_avg)
            xticklabels({'0','24'})
            xlabel('time (hr)')
            ylabel(ylabs{ii})
            legend('sim','exp')
            box off
        end
end

end

