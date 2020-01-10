//========================================================================
// ubmark.h
//========================================================================
// This header contains assembly functions that handle test passes and
// failures, in addition to turning statistics tracking on and off by
// writing the cp0 status register with the mtc0 instruction.

//------------------------------------------------------------------------
// Support for stats
//------------------------------------------------------------------------

#define test_fail(temp) \
  asm( "li %0, 2;"              \
       "csrw 21, %0;"    \
       "nop;nop;nop;nop;nop;"   \
       :                        \
       : "r"(temp)              \
  );                            \

/*
inline void test_fail( int temp )
{
  asm( "li %0, 2;"
       "csrrw zero, 21, %0;"
       "nop;nop;nop;nop;nop;"
       :
       : "r"(temp)
  );
}
*/

#define test_pass(temp)         \
  asm( "li %0, 1;"              \
       "csrw 21, %0;"    \
       "nop;nop;nop;nop;nop;"   \
       :                        \
       : "r"(temp)              \
  );                            \

/*
inline void test_pass( int temp )
{
  asm( "li %0, 1;"
       "csrrw zero, 21, %0;"
       "nop;nop;nop;nop;nop;"
       :
       : "r"(temp)
  );
}
*/

#define test_stats_on(temp)     \
  asm( "li %0, 1;"              \
       "csrw 10, %0;"    \
       "nop;nop;nop;nop;nop;"   \
       :                        \
       : "r"(temp)              \
  );                            \

/*
inline void test_stats_on( int temp )
{
  asm( "li %0, 1;"
       "csrrw zero, 10, %0;"
       "nop;nop;nop;nop;nop;"
       :
       : "r"(temp)
  );
}
*/

#define test_stats_off(temp)    \
  asm( "li %0, 0;"              \
       "csrw 10, %0;"    \
       "nop;nop;nop;nop;nop;"   \
       :                        \
       : "r"(temp)              \
  );                            \

/*
inline void test_stats_off( int temp )
{
  asm( "li %0, 0;"
       "csrrw zero, 10, %0;"
       "nop;nop;nop;nop;nop;"
       :
       : "r"(temp)
  );
}
*/

//------------------------------------------------------------------------
// Typedefs
//------------------------------------------------------------------------

typedef unsigned char byte;
typedef unsigned int  uint;

