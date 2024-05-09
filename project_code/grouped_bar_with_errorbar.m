function grouped_bar_with_errorbar(dat_mn,dat_std,colorcode)

% % a mean of data
% dat_mn=[0,1,0,0;
% 4,3,2,1;
% 2,2,1,3;
% 1,0,0,0;
% 2,2,1,3;
% 1,0,0,0;
% 1,0,0,0];
%
% dat_std=[0,1,0,0;
% 1,2,1,1;
% 1,1,1,2;
% 1,1,1,2;
% 1,1,1,2;
% 1,1,1,2;
% 1,0,0,0];


ctrs = 1:size(dat_mn,2);


if nargin ==3


    hBar = bar(ctrs, dat_mn,'FaceColor',colorcode);

    for k1 = 1:size(dat_mn,1)
        ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
        ydt(k1,:) = hBar(k1).YData;
    end
    hold on
    er = errorbar(ctr, ydt, dat_std);
    er.Color = colorcode;
    er.Marker = '.';
    er.LineStyle = 'none';
    hold off

elseif nargin == 2

    hBar = bar(ctrs, dat_mn);

    for k1 = 1:size(dat_mn,1)
        ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
        ydt(k1,:) = hBar(k1).YData;
    end
    hold on
    er = errorbar(ctr, ydt, dat_std,'.k');
    hold off
end



