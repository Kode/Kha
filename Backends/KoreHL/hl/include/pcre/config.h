#define COMPILE_PCRE16
#undef SUPPORT_JIT
#define PCRE_STATIC
#define SUPPORT_UCP

#ifdef _MSC_VER
#	pragma warning(disable:4710) // inline disabled
#	pragma warning(disable:4711) // inline activated
#	pragma warning(disable:4242) // loss of data
#	pragma warning(disable:4244) // loss of data
#	pragma warning(disable:4701) // potentially uninitialized local var
#	pragma warning(disable:4703) // potentially uninitialized local ptr
#else
#	pragma GCC diagnostic ignored "-Wunused-function"
#endif

/* The value of PARENS_NEST_LIMIT specifies the maximum depth of nested
   parentheses (of any kind) in a pattern. This limits the amount of system
   stack that is used while compiling a pattern. */
#define PARENS_NEST_LIMIT 250

/* The value of LINK_SIZE determines the number of bytes used to store links
   as offsets within the compiled regex. The default is 2, which allows for
   compiled patterns up to 64K long. This covers the vast majority of cases.
   However, PCRE can also be compiled to use 3 or 4 bytes instead. This allows
   for longer patterns in extreme cases. */
#define LINK_SIZE 2

/* This limit is parameterized just in case anybody ever wants to change it.
   Care must be taken if it is increased, because it guards against integer
   overflow caused by enormously large patterns. */
#define MAX_NAME_COUNT 10000

/* This limit is parameterized just in case anybody ever wants to change it.
   Care must be taken if it is increased, because it guards against integer
   overflow caused by enormously large patterns. */
#define MAX_NAME_SIZE 32

/* The value of NEWLINE determines the default newline character sequence.
   PCRE client programs can override this by selecting other values at run
   time. In ASCII environments, the value can be 10 (LF), 13 (CR), or 3338
   (CRLF); in EBCDIC environments the value can be 21 or 37 (LF), 13 (CR), or
   3349 or 3365 (CRLF) because there are two alternative codepoints (0x15 and
   0x25) that are used as the NL line terminator that is equivalent to ASCII
   LF. In both ASCII and EBCDIC environments the value can also be -1 (ANY),
   or -2 (ANYCRLF). */
#define NEWLINE 10

/* The value of MATCH_LIMIT determines the default number of times the
   internal match() function can be called during a single execution of
   pcre_exec(). There is a runtime interface for setting a different limit.
   The limit exists in order to catch runaway regular expressions that take
   for ever to determine that they do not match. The default is set very large
   so that it does not accidentally catch legitimate cases. */
#define MATCH_LIMIT 10000000

/* The above limit applies to all calls of match(), whether or not they
   increase the recursion depth. In some environments it is desirable to limit
   the depth of recursive calls of match() more strictly, in order to restrict
   the maximum amount of stack (or heap, if NO_RECURSE is defined) that is
   used. The value of MATCH_LIMIT_RECURSION applies only to recursive calls of
   match(). To have any useful effect, it must be less than the value of
   MATCH_LIMIT. The default is to use the same value as MATCH_LIMIT. There is
   a runtime method for setting a different limit. */
#define MATCH_LIMIT_RECURSION MATCH_LIMIT
