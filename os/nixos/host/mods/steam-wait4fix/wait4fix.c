#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <errno.h>
#include <pthread.h>

/*
 * Fix for Steam GPU topology race condition on NixOS
 *
 * Problem: Steam's ThreadGetProcessExitCode fails with ECHILD when checking
 * steamsysinfo results because the child process is reaped by another thread
 * before the spawning thread can check its exit status.
 *
 * Solution: Cache exit statuses from successful wait calls and return them
 * when a subsequent wait fails with ECHILD for the same PID.
 */

#define CACHE_SIZE 256
static struct {
    pid_t pid;
    int status;
    int valid;
} cache[CACHE_SIZE];
static pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
static pid_t (*real_wait4)(pid_t, int*, int, struct rusage*) = NULL;
static pid_t (*real_waitpid)(pid_t, int*, int) = NULL;

static void cache_result(pid_t r, int *st) {
    if (r > 0 && st) {
        pthread_mutex_lock(&mtx);
        int s = r % CACHE_SIZE;
        cache[s].pid = r;
        cache[s].status = *st;
        cache[s].valid = 1;
        pthread_mutex_unlock(&mtx);
    }
}

static pid_t check_cache(pid_t pid, int *st) {
    if (pid > 0) {
        pthread_mutex_lock(&mtx);
        int s = pid % CACHE_SIZE;
        if (cache[s].valid && cache[s].pid == pid) {
            if (st) *st = cache[s].status;
            pthread_mutex_unlock(&mtx);
            errno = 0;
            return pid;
        }
        pthread_mutex_unlock(&mtx);
    }
    return -1;
}

pid_t wait4(pid_t pid, int *st, int opt, struct rusage *ru) {
    if (!real_wait4) real_wait4 = dlsym(RTLD_NEXT, "wait4");

    pid_t r = real_wait4(pid, st, opt, ru);
    int saved_errno = errno;

    cache_result(r, st);

    if (r == -1 && saved_errno == ECHILD) {
        pid_t cached = check_cache(pid, st);
        if (cached > 0) return cached;
    }

    errno = saved_errno;
    return r;
}

pid_t waitpid(pid_t pid, int *st, int opt) {
    if (!real_waitpid) real_waitpid = dlsym(RTLD_NEXT, "waitpid");

    pid_t r = real_waitpid(pid, st, opt);
    int saved_errno = errno;

    cache_result(r, st);

    if (r == -1 && saved_errno == ECHILD) {
        pid_t cached = check_cache(pid, st);
        if (cached > 0) return cached;
    }

    errno = saved_errno;
    return r;
}
