package kha;

/**
 * This class contains references to `String` values of compiler
 * defines specified by the khafile and khamake.
 */
@:build(kha.internal.CompilerDefinesBuilder.build())
class CompilerDefines {}
