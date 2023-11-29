#include <stdio.h>
#include <stdlib.h>

// Colocar aqui um define com o N = 512
#define N 512

void multmatrix(int matrixA[N][N], int matrixB[N][N], int matrixC[N][N]){
    for (int i = 0; i <N;i++){
        for (int j = 0; j <N;j++){
            for (int k = 0;k <N;k++){
                matrixC[i][j] += matrixA[i][k] * matrixB[k][j]; 
            }
        }
    }

}
int main(int argc, char* argv[]){
    int matrizA [N][N];
    int matrizB [N][N];
    int matrizR [N][N];

    for (int i = 0; i <N ;i++){
        for (int j = 0; j <N;j++){
            matrizA[i][j]=1;
        }
    }
    for (int i = 0; i <N ;i++){
        for (int j = 0; j <N;j++){
            matrizB[i][j]=1;
        }
    }
    matrizA[5][3]=23;matrizA[6][7]=73;matrizA[8][9]=83;matrizA[34][120]=93;matrizA[50][120]=123;
    matrizB[7][34]=96;matrizB[78][78]=85;matrizB[78][97]=93;matrizB[34][120]=153;matrizB[50][120]=189;

    for (int i = 0; i <N ;i++){
        for (int j = 0; j <N;j++){
            matrizR[i][j]=0;
        }
    }

    multmatrix(matrizA,matrizB,matrizR);
    return 0;
}