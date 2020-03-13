//
//  main.c
//  winnosleep
//
//  Created by Ilya Mikhaltsou on 2020-03-12.
//  Copyright 2020 Ilya Mikhaltsou. All rights reserved.
//

// Compile with:
// x86_64-w64-mingw32-gcc -static main.c -o winnosleep.exe

#define WINVER 0x0602
#define _WIN32_WINNT 0x0602

#include <stdlib.h>
#include <stdio.h>
#include "Windows.h"

int main() {
  // if (SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_AWAYMODE_REQUIRED) == NULL) {
  //    SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED);
  // }
  
  REASON_CONTEXT context = {
    POWER_REQUEST_CONTEXT_VERSION,
    POWER_REQUEST_CONTEXT_SIMPLE_STRING,
    .Reason.SimpleReasonString = L"winnosleep is running"
  };
  
  HANDLE hRequest = PowerCreateRequest(&context);
  
  if(hRequest == NULL) {
    printf("Unable to create power request");
    return 1;
  }
  
  if(PowerSetRequest(hRequest, PowerRequestDisplayRequired) == 0) {
    printf("Error setting up power request");
    return 1;
  }
  
  while(1) getchar();
  
  if(PowerClearRequest(hRequest, PowerRequestDisplayRequired) == 0) {
    printf("Error clearing power request");
    return 1;
  }
  
  CloseHandle(hRequest);
  
  // SetThreadExecutionState(ES_CONTINUOUS);
  
  return 0;
}
