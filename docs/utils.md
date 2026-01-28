# 便利な関数
## 輝点検出

```matlab
% image 画像データ 2次元の数値行列
% spotCount 検出する輝点数 結果の個数はこれ以下になる
% spots analysis.image.BrightSpot
spots = analysis.image.getbrightspots(image,spotCount);
```

## 点群対応推定

```matlab
% basePoints 基準になる点を含む点群
% estimatedPoints 対応付け対象の点群
% respondPoints estimatedPointsをbasePointsとの対応関係に基づいて並べ替えたもの
respondPoints = analysis.image.estimateRespondPointPairs(basePoints,estimatedPoints);
```

### Note
このプロジェクト中では頻繁に二次元上の座標のリストが受け渡しされてますが、基本全部含まれる点を $n$ 個として、サイズ`(n,2)`の行列の各行に各座標の、第一列がX座標、第二列がY座標を含むような形で受け渡ししています

~~今思えば`Point`型みたいなのあってもよかったな~~