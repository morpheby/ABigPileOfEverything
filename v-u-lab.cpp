/*
 * v-u-lab.cpp
 * 
 * Created by Илья Михальцов on 2013-06-03.
 * Copyright 2013 Илья Михальцов. All rights reserved.
 */


#include <iostream>

typedef unsigned long long _Int;

_Int pow_fast(_Int n, int p) {
    _Int res = 1;
    while(p) {
        if(p&1) {
            res *= n;
            p^=1;
        } else {
            n *= n;
            p >>= 1;
        }
    }
    return res;
}

_Int fact(_Int n) {
    if(n)
        return fact(n-1)*n;
    else
        return 1;
}

_Int func_c(_Int n, _Int m) {
    return fact(n)/fact(m)/fact(n-m);
}

_Int func_u_star(_Int n, _Int k) {
    _Int res = 0;
    for(int i = 0, s = 1; i < k; ++i, s*=-1)
        res += s * func_c(k, i) * pow_fast(k-i, n);
    return res;
}

_Int func_v_star(_Int n, _Int k) {
    return func_u_star(n,k)/fact(k);
}

_Int func_v(_Int n, _Int k) {
    _Int res = 0;
    for(int i = 1; i <= k; ++i)
    {
        res += func_v_star(n, i);
    }
    return res;
}

int main (int argc, char const *argv[])
{
    _Int n, k;
    std::cin >> n >> k;
    std::cout << func_v(n, k) << std::endl;
    getchar();
    
    return 0;
}
