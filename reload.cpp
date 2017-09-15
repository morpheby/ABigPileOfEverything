#include <sys/ioctl.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/disk.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <errno.h>

#ifndef BLKRRPART
#define BLKRRPART  _IO('d',95) /* re-read partition table */
// #define BLKRRPART  _IO(0x12,95) /* re-read partition table */
#endif

int my_error(const char *str, ...) {
    va_list args;
    
    va_start(args, str);
    vfprintf(stderr, str, args);
    va_end(args);
    exit(1);
    return 1;
}


int main (int argc, char const *argv[])
{
	int fd;
	int ret;
	struct stat statbuf;
    
    if(argc != 2)
        return my_error("Wrong arguments\n");

	fd = open(argv[1], O_RDWR);
	if (fd == 0)
		return my_error("Could not open %s\n", argv[1]);

	ret = fstat(fd, &statbuf);
	if (ret != 0 || !S_ISBLK(statbuf.st_mode))
		return my_error("%s is not a block device\n", argv[1]);

	printf("ioctl() read of partition table\n");
	ret = ioctl(fd, DKIOCEJECT);
	if (ret != 0)
		return my_error("Error while ioctl(): %s (%d)\n", strerror(errno), errno);

	if (fsync(fd) || close(fd))
		return my_error("Error closing file\n");
    
    return 0;
}