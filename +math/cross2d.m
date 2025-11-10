function crossproduct = cross2d(A,B)
    arguments
        A (1,2) {mustBeNumeric}
        B (1,2) {mustBeNumeric}
    end
    crossproduct = A(1)*B(2) - A(2)*B(1)
end