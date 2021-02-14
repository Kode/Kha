package kha;

/*
	FastFloat uses 32 bit floats wherever that is possible.
	But JavaScript in particular only supports 64 bit floats.
	Therefore when using FastFloat you will have different
	precision on different targets and therefore it is
	strongly advised to only use it where that does not
	matter (typically graphics code,  avoid it in gameplay
	code at all costs).
 */
#if cpp
typedef FastFloat = cpp.Float32;
#elseif hl
typedef FastFloat = hl.F32;
#elseif java
typedef FastFloat = Single;
#else
typedef FastFloat = Float;
#end
