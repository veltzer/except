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

//static void* handle=NULL;
static int (*p_ioctl)(int,unsigned long int,...);
static const bool debug=false;

void except_debug(const char* msg) {
	if(debug) {
		printf("[%s]\n",msg);
	}
}

void except_init(void) __attribute__((constructor));
void except_init(void) {
	except_debug("in except_init");
	/*
	handle=dlopen(NULL, RTLD_LAZY);
        if(handle==NULL) {
		fprintf(stderr,"error in dlopen [%s]\n",dlerror());
		exit(1);
	}
	*/
	p_ioctl=(typeof(p_ioctl))dlsym(RTLD_NEXT, "ioctl");
	if(p_ioctl==NULL) {
		fprintf(stderr,"error in dlsym on symbol [%s], [%s]\n","ioctl",dlerror());
		exit(1);
	}
	/*
	if(dlclose(handle)) {
		fprintf(stderr,"error in dlclose [%s]\n",dlerror());
		exit(1);
	}
	*/
}

void except_fini(void) __attribute__((destructor));
void except_fini(void) {
	except_debug("in except_fini");
}

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
