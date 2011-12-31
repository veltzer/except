#define _GNU_SOURCE
#include <dlfcn.h>  // for dlopen(3), dlclose(3), dlerror(3), dlsym(3)
#include <stdbool.h> // for type bool

#include <pthread.h> // for pthread_create(3), pthread_join(3)
#include <stdio.h> // for vsnprintf(3), snprintf(3), fputs(3), printf(3), fprintf(3)
#include <stdarg.h> // for va_start(3), va_end(3), va_list
#include <stdlib.h> // for malloc(3), free(3), exit(3)
#include <unistd.h> // for usleep(3)
#include <syslog.h> // for syslog(3)
#include <sys/mman.h> // for mlock(2)
#include <sys/ioctl.h> // for ioctl(2)

#define __stringify_1(x) # x
#define __stringify(x) __stringify_1(x)
#define register_name(name) p_ ## name=(typeof(p_ ## name))dlsym(RTLD_NEXT, __stringify(name));\
	if(p_ ## name==NULL) {\
		fprintf(stderr,"error in dlsym on symbol [%s], [%s]\n",__stringify(name),dlerror());\
		exit(1);\
	}

//static void* handle=NULL;
static const bool debug=false;
//static const bool debug=true;

// the functions
static int (*p_ioctl)(int,unsigned long int,...);
static void* (*p_malloc)(size_t);

void except_debug(const char* msg) {
	if(debug) {
		printf("[%s]\n",msg);
	}
}

void except_init(void) __attribute__((constructor));
void except_init(void) {
	except_debug("in except_init");
	register_name(ioctl);
	register_name(malloc);
}

/*
 * Right now we don't need a destructor
 */
/*
void except_fini(void) __attribute__((destructor));
void except_fini(void) {
	except_debug("in except_fini");
}
*/

void except_error(const char* name) {
	fprintf(stderr,"an error for [%s]\n",name);
	exit(1);
}

int ioctl(int d,unsigned long int request,...) {
	except_debug("in ioctl");
	int ret=p_ioctl(d,request);
	if(ret==-1) {
		except_error("ioctl");
	}
	return ret;
}

void* malloc(size_t size) {
	except_debug("in malloc");
	void* ret=p_malloc(size);
	if(ret==NULL) {
		except_error("malloc");
	}
	return ret;
}
