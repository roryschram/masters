function m = MovSum(data,range)

    O = ones(1,range);
    data = conv(data,O);
    L = ceil(range/2);
    m= data(L:length(data)-(L-1));

end