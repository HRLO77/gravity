/* Generated by Cython 0.29.34 */

#ifndef __PYX_HAVE__code__constants_cy
#define __PYX_HAVE__code__constants_cy

#include "Python.h"

#ifndef __PYX_HAVE_API__code__constants_cy

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#ifndef DL_IMPORT
  #define DL_IMPORT(_T) _T
#endif

__PYX_EXTERN_C int X;
__PYX_EXTERN_C int Y;
__PYX_EXTERN_C int X_SUB;
__PYX_EXTERN_C int Y_SUB;
__PYX_EXTERN_C __pyx_ctuple_int__and_int ORIGIN;
__PYX_EXTERN_C float G;
__PYX_EXTERN_C float SOFTEN;
__PYX_EXTERN_C float RADIAN_DIV;
__PYX_EXTERN_C int SIZE;
__PYX_EXTERN_C float FACTOR;
__PYX_EXTERN_C int BODIES;
__PYX_EXTERN_C int DISSIPATE;
__PYX_EXTERN_C int OUTPUT;

#endif /* !__PYX_HAVE_API__code__constants_cy */

/* WARNING: the interface of the module init function changed in CPython 3.5. */
/* It now returns a PyModuleDef instance instead of a PyModule instance. */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initconstants_cy(void);
#else
PyMODINIT_FUNC PyInit_constants_cy(void);
#endif

#endif /* !__PYX_HAVE__code__constants_cy */
