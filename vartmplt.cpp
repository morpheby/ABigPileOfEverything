#include <iostream>

template<typename... _Args>
void abc(_Args... args);

template<typename... _Args>
void abc(int a, _Args... args) {
   std::cout << a;
   abc(args...);
}

template<>
void abc() {
   return;
}

class Abc {
public:
   template<typename... _Args>
   Abc(int a, int b, _Args...);
   Abc();
};

template<typename... _Args>
Abc::Abc(int a, int b, _Args... args) : Abc(args...){
   std::cout << a << ":" << b << std::endl;
}


Abc::Abc() {
}

int main() {
   abc(1, 2, 3, 4, 5);
   std::cout << std::endl;
   Abc a(5, 6, 1, 2, 9, 8);
   return 0;
}
