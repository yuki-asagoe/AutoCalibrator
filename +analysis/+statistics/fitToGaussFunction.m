function [amplitude,mu,rho] = fitToGaussFunction(values)
    arguments(Input)
        values (1,:) {mustBeNumeric}
    end
    % Caruana のアルゴリズム を使用
    % MATLABには fit 関数が存在するが Curve Fitting Toolbox のやつなので自前で
    % 戻り値は
    % @(x) amplitude * exp(-((x - mu)^2)/(2*rho^2))
    % という関数のそれぞれに対応する
    
    % 0以下の要素があるとまずいのでそのような要素は0超過の値のうち最小の要素に切り捨てる
    offsetValues=values;
    offsetValues(offsetValues < 0)=min(values(values > 0));

    count=length(offsetValues);
    x=1:count;
    x_sum=sum(x);
    square_x=x.^2;
    square_x_sum=sum(square_x);
    cubic_x=x.^3;
    cubic_x_sum=sum(cubic_x);
    fourthpowered_x_sum=sum(x.^4);
    logvalues=log(offsetValues);

    A=[ ...
        count,x_sum,square_x_sum; ...
        x_sum,square_x_sum,cubic_x_sum; ...
        square_x_sum,cubic_x_sum,fourthpowered_x_sum ...
    ];
    B = [sum(logvalues);dot(x,logvalues);dot(square_x,logvalues)];
    solved=linsolve(A,B);

    amplitude=exp(solved(1)-(solved(2)^2)/(4*solved(3)));
    mu=-solved(2)/(2*solved(3));
    rho=sqrt(-1/(2*solved(3)));
end