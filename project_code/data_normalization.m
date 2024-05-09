function dat = data_normalization(dat,dim)
% (1) row-wise - initial value
% (2) column-wise - initial value
% (3) row-wise - max
% (4) column-wise - max (*)


if dim == 1
    dat = dat./repmat(dat(:,1),1,size(dat,2));
elseif dim == 2
    dat = dat./repmat(dat(1,:),size(dat,1),1);
elseif dim == 3
     dat = dat./repmat(max(dat,[],2),1,size(dat,2));    
elseif dim == 4
    dat = dat./repmat(max(dat,[],1),size(dat,1),1);
  
end