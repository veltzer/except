#include <sys/ioctl.h> // for ioctl(2)

int main(int argc,char** argv,char ** envp) {
	ioctl(6,9);
	return 0;
}
