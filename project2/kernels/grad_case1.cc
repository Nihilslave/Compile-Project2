#include "../run2.h"
void grad_case1(float (&B)[4][16],float (&C)[4][16],float (&A)[4][16]) {
  for (int i = 0; i < 4; ++i){
    for (int j = 0; j < 16; ++j){
      A[i][j] += C[i][j] * B[i][j] + 0;
    }
  }
}
