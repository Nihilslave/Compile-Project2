#include "../run2.h"
void grad_case9(float (&B)[4][6],float (&A)[4]) {
  for (int i = 0; i < 4; ++i){
    for (int j = 0; j < 6; ++j){
      A[i] += B[i][j];
    }
  }
}
