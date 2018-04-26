package kha;

#if cpp
typedef FastFloat = cpp.Float32;
#elseif hl
typedef FastFloat = hl.F32;
#elseif java
typedef FastFloat = Single;
#else
typedef FastFloat = Float;
#end
