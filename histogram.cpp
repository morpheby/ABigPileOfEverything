/*
 * histogram.cpp
 * Creates histogram of byte distribution in file
 * 
 * Created by Илья Михальцов on 2014-05-27.
 * Copyright 2014 Илья Михальцов. All rights reserved.
 */

// g++ -fopenmp -std=gnu++11 -O2 histogram.cpp -o histogram

#include <iostream>
#include <algorithm>
#include <vector>
#include <errno.h>
#include <iomanip>
#include <iterator>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <fcntl.h>
#include <functional>
#include <math.h>
#include <sys/stat.h>

typedef unsigned char readValue_t;
#define READ_BLOCK 2048*1024

int main (int argc, const char **argv) {
    int fd = 0;
    
    if (argc == 2) {
        fd = open(argv[1], O_RDONLY);
        if (fd == -1)
            return errno;
    } else if (argc == 1) {
        fd = STDIN_FILENO;
    } else {
        std::cerr << "Usage: " << argv[0] << " [filename]" << std::endl;
        return 1;
    }
    
    readValue_t buf[READ_BLOCK];
    
    std::vector<long long int> h (1 << (8 * sizeof(readValue_t)));
    
    
    int columns;
    int termWidth;
    {
        struct winsize w;
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
        termWidth = columns = w.ws_col;
        columns -= sizeof(readValue_t) * 2 + 3 + 11;
    }
    
    int readBytes = 0;
    long long int fileSize = 0;
    long long int accumulator = 0;
    
    struct stat fileStat;
    fstat(fd, &fileStat);
    fileSize = fileStat.st_size;
    
    std::cout << std::endl;
    do {
        std::cout << "\r" << (double) accumulator / fileSize * 100 << "%" << "   ";
        std::cout.flush();
        
        accumulator += readBytes = read(fd, buf, READ_BLOCK * sizeof(readValue_t));
        if (!readBytes)
            continue;
        
#pragma omp parallel for
        for (int i = 0; i < readBytes/sizeof(readValue_t); ++i) {
            readValue_t c = buf[i];
            
            auto &v = h.at(c);
#pragma omp atomic
            ++v;
        }
    } while(readBytes == READ_BLOCK * sizeof(readValue_t));
    
    std::cout << '\r';
    
    long long int max = *std::max_element(h.begin(), h.end());
    
    double coeff = (double)columns / max;
    for (int i = 0; i < h.size(); ++i) {
        int numAsterisks = coeff * h[i];
        std::cout << std::hex << std::setw(sizeof(readValue_t) * 2) << std::right << i << ": " << std::dec;
        std::fill_n(std::ostream_iterator<char>(std::cout, ""), numAsterisks, '*');
        std::fill_n(std::ostream_iterator<char>(std::cout, ""), columns - numAsterisks + 1, ' ');
        std::cout << '(' << std::fixed << std::setprecision(4) << std::setw(8) << std::right << (double)h[i]/fileSize * 100.0 << "%)";
        std::cout << std::endl;
    }
    
    return 0;
}

