% 入力を [0~2pi]の範囲に正規化
function normalizedphase=normalizePhase(phasearray)
    normalizedphase=phasearray-2*pi*floor(phasearray/(2*pi));
end