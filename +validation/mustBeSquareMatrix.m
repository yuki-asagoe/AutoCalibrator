function mustBeSquareMatrix(value)
    valuesize=size(value);
    if size(valuesize) ~= 2
        error("Given tensor is not 2d matrix");
    elseif valuesize(1) ~= valuesize(2)
        error("Given tensor is not square matrix");
    end
end