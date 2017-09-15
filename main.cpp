//#include <boost/regex.hpp>
#include <boost/thread.hpp>

//boost::regex a("");
#include <iostream>

struct functor {
    void operator() () {
        std::cout << "hi" << std::endl;
    }
};

int main () {
    functor x;
    boost::thread thrd(x);
    thrd.join();
	return 0;
}