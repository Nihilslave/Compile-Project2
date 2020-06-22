#include "../run2.h"
void grad_case5(float (&C)[32][32],float (&D)[4][32],float (&A)[16][32],float (&B)[16][32][4]) {
  for (int i = 0; i < 16; ++i){
    for (int j = 0; j < 32; ++j){
      for (int k = 0; k < 32; ++k){
        for (int l = 0; l < 4; ++l){
          B[i][k][l] += A[i][j] * C[k][j] * D[l][j];
        }
      }
    }
  }
}
