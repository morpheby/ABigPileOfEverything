/*
 * is_pod.cpp
 * test
 * 
 * Created by Илья Михальцов on 2013-05-26.
 * Copyright 2013 Илья Михальцов. All rights reserved.
 */

#include <iostream>
#include <type_traits>
#include <vector>
#include <typeinfo>
#include <map>

struct A {
	int a, b;
	float c, d;
};

template<typename>
struct __void_type {
	typedef void type;
};

template<typename T, typename _Enable = void>
struct __container_type {};

template<typename T>
struct __container_type<T, typename __void_type<typename T::value_type>::type> {
	typedef typename T::value_type type;
};

template<typename _Tp, typename _Up>
typename __void_type<decltype(static_cast<std::pair<typename _Tp::iterator,bool> (_Tp::*)(const typename _Tp::const_reference)>(&_Tp::insert))>::type
__add_to_container(_Tp &container, _Up value) {
	std::cout << "emplace" << std::endl;
}
template<typename _Tp, typename _Up>
typename __void_type<decltype(static_cast<void (_Tp::*)(const typename _Tp::const_reference)>(&_Tp::push_back))>::type
__add_to_container(_Tp &container, _Up value) {
	std::cout << "push_back" << std::endl;
}

int main() {
	std::cout << std::boolalpha <<
		std::is_pod<A>::value << std::endl <<
		std::is_pod<bool>::value << std::endl;
	std::cout << typeid(__container_type<std::vector<int>>::type).name() << std::endl;
	std::vector<int> a;
	std::map<int,int> b;
	__add_to_container(a, 5);
	__add_to_container(b, 5);
	return 0;
}
