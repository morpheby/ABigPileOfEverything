
#include <vector>
#include <set>
#include <stdio.h>
#include <fcntl.h>
#include <iostream>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

const static int numberOfLayers = 3;
const static float agressivity = 3./8;

typedef unsigned char element_t;

int countOnes(element_t byte) {
    int counter = 0;
    for (int i = 0; i < sizeof(element_t)*8; ++i)
        counter += (byte >> i) & 1;
    return counter;
}

template <class T>
int iterateSimilarityXOR(const T &elems, element_t mean) {
    int counter = 0;
    for (auto it = elems.begin(); it != elems.end(); ++it) {
        counter += countOnes((*it) ^ mean);
    }
    return counter;
}

int similarityXOR(const element_t *input, size_t inputLen, element_t *meanPtr) {
    element_t mean = 0;
    int maxDiff = INT_MAX;
    std::set<element_t> elems;
    
    for (int i = 0; i < inputLen; ++i) {
        elems.insert(input[i]);
    }
    
    for (auto it = elems.begin(); it != elems.end(); ++it) {
        int t = iterateSimilarityXOR(elems, *it);
        // std::cerr << t << std::endl;
        if (t < maxDiff) {
            maxDiff = t;
            mean = *it;
        }
    }
    if (meanPtr) {
        *meanPtr = mean;
    }

    // std::cerr << maxDiff << ' ' << (int) mean << std::endl;
    
    return maxDiff;
}

int induce(const element_t *input, element_t *output, size_t inputLen) {
    size_t blockSize = 0;

    size_t offset = 0;
    size_t outputOffset = 0;
        
    while(offset < inputLen) {
        element_t mean = input[offset + 0];
        
        {
            unsigned short t = 0;
            int coeff = sizeof(t)/sizeof(element_t);
            for (int k = 0; k < coeff; ++k) {
                t |= ((unsigned short)input[offset + 1 + k]) << (k * sizeof(element_t) * 8);
            }
            blockSize = t;
            offset += 1 + coeff;
        }
        for (int i = 0; i < blockSize; ++i) {
            output[outputOffset + i] = input[offset + i] ^ mean;
        }
        offset += blockSize;
        outputOffset += blockSize;
    }
    return outputOffset;
}

int reduce(const element_t *input, element_t *output, size_t inputLen) {
    const size_t blockSizeStart = 2048;
    
    size_t blockSize = blockSizeStart;

    size_t offset = 0;
    size_t outputOffset = 0;
    
    int efficiencyCounter = 0;
    
    while(offset < inputLen) {
        element_t mean = 0;
    
        size_t sz = blockSize < (inputLen - offset) ? blockSize : (inputLen - offset);
        
        // std::cerr << blockSize << ' ' << (unsigned int) sz << std::endl;
        // for (int i = 0; i < 20; ++i) {
        //     std::cerr << (int) input[offset+i] << ' ';
        // }
        // std::cerr << std::endl;
        
        int similarityScore = similarityXOR(input+offset, sz, &mean);
        if (sz * agressivity < similarityScore) {
            blockSize /= 2;
        } else {
            if (blockSize > 1 && offset > 0) {
                std::cerr << '\x0d';
                std::cerr << blockSize << ' ' << similarityScore << ' ' << (unsigned int) mean << "          " << std::endl;
                std::cerr << (offset * 100) / inputLen << "% " << ((offset - efficiencyCounter) * 100) / offset << "% " << 
                    ((outputOffset - efficiencyCounter) * 100) / offset << "%         ";
                efficiencyCounter += sz - 1;
            }
            
            output[outputOffset + 0] = mean;
            {
                unsigned short t = sz;
                int coeff = sizeof(t)/sizeof(element_t);
                for (int k = 0; k < coeff; ++k) {
                    output[outputOffset + 1 + k] = (element_t) t;
                    t >>= sizeof(element_t) * 8;
                }
                outputOffset += 1 + coeff;
            }
            for (int i = 0; i < sz; ++i) {
                output[outputOffset + i] = input[offset + i] ^ mean;
                // std::cerr << (int) output[outputOffset + i] << ' ';
            }
            offset += sz;
            outputOffset += sz;
            
            blockSize = blockSizeStart;
        }
    }
    std::cerr << '\x0d';
    std::cerr << (offset * 100) / inputLen << "% " << ((offset - efficiencyCounter) * 100) / offset << "% " << 
        ((outputOffset - efficiencyCounter) * 100) / offset << "%         ";
    std::cerr << std::endl;
    return outputOffset;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "Wrong syntax" << std::endl;
        return 1;
    }
    
    int fdIn = fcntl(STDIN_FILENO, F_DUPFD, 0);
    if (fdIn < 0) {
        perror("stdin");
        return 1;
    }
    
    bool decompress = false;
    
    int fdOut;
    if (argc == 3) {
        if (argv[1][1] == 'x') {
            decompress = true;
            fdOut = open(argv[2], O_RDWR | O_CREAT | O_TRUNC);
            if (fdOut < 0) {
                perror("out");
                return 1;
            }
        } else {
            std::cerr << "Wrong syntax" << std::endl;
            return 1;
        }
    } else {
        fdOut = open(argv[1], O_RDWR | O_CREAT | O_TRUNC);
        if (fdOut < 0) {
            perror("out");
            return 1;
        }
    }
    
    std::cerr << fdIn << ' ' << fdOut << std::endl;
    
    struct stat st;
    fstat(fdIn, &st);
    
    size_t fSize = st.st_size;
    size_t outSize = fSize * 4;
    
    void *memInput = mmap(0, fSize, PROT_READ, MAP_PRIVATE, fdIn, 0);
    if (memInput == MAP_FAILED) {
        perror("error");
        return 1;
    }

    if (ftruncate(fdOut, outSize) == -1) {
        perror("stdout truncate");
    }
    void *memOutput = mmap(0, outSize, PROT_READ | PROT_WRITE, MAP_SHARED, fdOut, 0);
    if (memOutput == MAP_FAILED) {
        perror("error 2");
        return 1;
    }
    
    std::cerr << std::endl;
    
    size_t newOutSize;
    if (decompress) {
        newOutSize = induce((element_t *)memInput, (element_t *)memOutput, fSize);
    } else {
        newOutSize = reduce((element_t *)memInput, (element_t *)memOutput, fSize);
    }
    
    munmap(memInput, fSize);
    munmap(memOutput, outSize);
    
    ftruncate(fdOut, newOutSize);
    close(fdIn);
    close(fdOut);
    
    return 0;
}

