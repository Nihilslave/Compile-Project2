#include "../run2.h"
void grad_case3(float (&B)[16][16],float (&C)[4][16],float (&A)[4][16]) {
  for (int i = 0; i < 4; ++i){
    for (int j = 0; j < 16; ++j){
      for (int k = 0; k < 16; ++k){
        A[i][k] += C[i][j] * B[k][j];
      }
    }
  }
}
