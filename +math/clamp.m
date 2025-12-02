% clip 関数と同じ
% 旧バージョンのMatlabにはないので自分で実装
function value = clamp(in,min,max)
    if in < min
        value = min;
        return;
    elseif in > max
        value = max;
        return;
    end
    value = in;
end

