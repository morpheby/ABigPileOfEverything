
#include <iostream>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <cstdlib>

#define MAX_CONNECTIONS 100

int main(int argc, const char **argv) {
   if(argc != 2) {
      std::cout << "Usage:" << std::endl
         << argv[0] << " port" << std::endl;
      return 1;
   }
   
   std::cout << "Listening on " << argv[1] << std::endl;

   int s = socket(PF_INET, SOCK_STREAM, 0);

   if(s < 0) {
      std::cout << "Error opening socket" << std::endl;
      return 2;
   }

   sockaddr_in addr;
   memset(&addr, 0, sizeof(addr));
   int port = std::atoi(argv[1]);
   addr.sin_family = AF_INET;
   addr.sin_addr.s_addr = INADDR_ANY;
   addr.sin_port = htons(port);
   if(bind(s, (sockaddr*) &addr, sizeof(addr)) < 0) {
      std::cout << "Error binding" << std::endl;
      return 3;
   }
   
   listen(s, MAX_CONNECTIONS);

   int client;

   do {
      sockaddr_in clientAddr;
      socklen_t clientAddrLen = sizeof(clientAddr);
      client = accept(s, (sockaddr*) &clientAddr, &clientAddrLen);
      if(fork() == 0) {
         std::cout << "Accepted connection" << std::endl;
         char buffer[256];
         int ret;
         do {
            ret = recv(client, buffer, 256, 0);
            if(ret == -1) {
               std::cout << "Connection error" << std::endl;
               return 4;
            }
            send(client, buffer, ret, 0);
         } while(ret);
      }
   } while(true);

   return 0;
}

