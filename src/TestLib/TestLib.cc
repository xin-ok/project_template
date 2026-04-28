#include "sharedLib1/sharedLib1.h"
#include "staticLib1/staticLib1.h"

int main() {
  staticLib1();
  sharedLib1();
  return 0;
}