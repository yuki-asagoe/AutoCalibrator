% using rotating calipers method
function [point1index,point2index] = searchfarestpair(points)
    arguments
        points (:,2) double
    end
    % 回転キャリパー法でやろうと思ってたんですけど思いのほか実装が面倒なのと
    % 結局たかだか一桁程度の点数にしか使わないことになったので
    % 時間計算量が悪化するけど2次線形走査でやります
    % 暇だったら直す

    % Not implemented
end