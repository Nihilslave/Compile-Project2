#include "../run2.h"
void grad_case7(float (&B)[16][32],float (&A)[32][16]) {
  for (int i = 0; i < 16; ++i){
    for (int j = 0; j < 32; ++j){
      A[j][i] += B[i][j];
    }
  }
}
