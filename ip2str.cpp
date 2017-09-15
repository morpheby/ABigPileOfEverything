#include <string>
#include <iostream>

std::string ip2str(uint32_t ip) {
   uint8_t octet;
   std::string result;
   for(int i = 3; i >= 0; --i, result+='.')
      result += std::to_string((ip>>(i<<3))&0xFF);
   result[result.size()-1] = 0;
   return result;
}


int main(int argc, char **argv) {
   if(argc != 2)
      return 1;

   std::string input = argv[1];
   std::cout << ip2str(std::stoul(input)) << std::endl;
   return 0;
}

