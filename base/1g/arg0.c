
/****f SC_LIB/Arg0 ****

*AUTOR
   Ernad Husremovic ernad@sigma-com.net

*SINTAKSA
   Arg0()

*PRIMJER
   Arg0() -> C:/SIGMA/FIN.EXE
   ..
   #define EXEPATH   FilePath(Arg0())
   ? "Direktorij u kome se izvrsni fajl nalazi je ", EXEPATH
   
****/


#include <extend.h>
extern int __argc;
extern char **__argv;
CLIPPER Arg0()
{
    _retc(__argv[0]);
      return;
}

