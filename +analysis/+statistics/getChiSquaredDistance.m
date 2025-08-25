% 類似度尺度のχ2乗距離を計算します (統計指標の方ではなく)
% 二つの分布(ヒストグラム間)の類似度としての距離を出します
% 日本語の文献がほぼないどころか英語で調べてもあまり見つかりませんでしたので
% 以下のリンクを置いておきますがあまり参照としてよいものではないかもしれません

% https://stats.stackexchange.com/questions/184101/comparing-two-histograms-using-chi-square-distance
% https://pdfs.semanticscholar.org/df72/6eb78f9068bbd96c7e09b97990df809b125d.pdf

function chiSquaredDistance=getChiSquaredDistance(dataA,dataB)
    arguments (Input)
        dataA {mustBeNumeric}
        dataB {mustBeNumeric}
    end
    assert(all(size(dataA) == size(dataB)));

    % 定義通りにやるならこういう式
    % chiSquaredDistance = sum(((dataA-dataB).^2)./(dataA+dataB),'all')
    % このままだと0除算しかねないのでそこだけ何とかする

    chiSquaredDistance = sum(((dataA - dataB).^2) ./ (dataA + dataB + 1e-6),'all');
end