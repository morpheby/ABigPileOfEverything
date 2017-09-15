#include <future>
#include <vector>

int main (int, char *[])
{
       std::vector<std::future<void>> v;
           v.reserve(100);
               for (int i = 0; i != 100; ++i)
                      {
                                 v.emplace_back(std::async(std::launch::async, [] () {
                                                      std::async(std::launch::async, [] { });
                                                              }));
                                     }

                   return 0;
}

