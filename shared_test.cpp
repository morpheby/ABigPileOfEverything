#include <mutex>
#include <memory>

int a;
decltype(a) b;

int main() {
   std::shared_ptr<int> a;
}
