package kha;

#if cpp
typedef FastFloat = cpp.Float32;
#elseif hl
typedef FastFloat = hl.F32;
#else
typedef FastFloat = Float;
#end
