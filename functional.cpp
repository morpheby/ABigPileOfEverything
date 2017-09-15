
class SomeClass {
public:
	int A(int x) {return 5;}
	int B(int x) {return 6;}
};


typedef int (SomeClass::&_SomeClassFuncPtr_t)(int arg);


int main() {
	SomeClass a;
	_SomeClassFuncPtr_t f = SomeClass::A;
	
	a.f(5);
	a.f(6);
	
	return 0;
}
