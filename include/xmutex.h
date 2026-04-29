/**
 * @file
 *
 * @date Created  on Apr 22, 2026
 * @author Attila Kovacs
 *
 *  Portable mutex macros
 */

#ifndef XMUTEX_H_
#define XMUTEX_H_

#if defined(_USE_PTHREAD) || defined(__unix__) || defined(__unix) || defined(__APPLE__)
#  include <pthread.h>

#  define xmut_init(x)        pthread_mutex_init(x, (void *) 0)  ///< initialize mutex (not return)
#  define xmut_lock           pthread_mutex_lock           ///< lock mutex
#  define xmut_unlock         pthread_mutex_unlock         ///< unlock mutex
#  define xmut_destroy        pthread_mutex_destroy        ///< destroy mutex
#  define THREAD_SAFE         1                            ///< mutexes may be used

typedef pthread_mutex_t       lock_type;                   ///< the mutex type

#elif __STDC_VERSION__ >= 201112L
#  include <threads.h>

#  define xmut_init(x)        mtx_init(x, mtx_plain)       ///< initialize mutex (not return)
#  define xmut_lock           mtx_lock                     ///< lock mutex
#  define xmut_unlock         mtx_unlock                   ///< unlock mutex
#  define xmut_destroy        mtx_destroy                  ///< destroy mutex
#  define THREAD_SAFE         1                            ///< mutexes may be used

typedef mtx_t                 lock_type;                   ///< the mutex type

#elif defined(WIN32)
#include <windows.h>

#  define xmut_init(x)        InitializeSRWLock(x)         ///< initialize mutex (not return)
#  define xmut_lock           AcquireSRWLockExclusive      ///< lock mutex
#  define xmut_unlock         ReleaseSRWLockExclusive      ///< unlock mutex
#  define xmut_destroy(x)                                  ///< destroy mutex
#  define THREAD_SAFE         1                            ///< mutexes may be used

typedef SRWLOCK               lock_type;                   ///< the mutex type

#else
#  define xmut_init(x)                                     ///< dummy initialze mutex
#  define xmut_lock(x)                                     ///< dummy lock mutex
#  define xmut_unlock(x)                                   ///< dummy unlock mutex
#  define xmut_destroy(x)                                  ///< dummy destroy mutex
#  define THREAD_SAFE         0                            ///< mutexes may not be used
typedef int                   lock_type;                   ///< dummy mutex type

#endif



#endif /* XMUTEX_H_ */
