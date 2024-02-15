#include <iostream>
#include <vector>
#include "mpi.h"
#include <string>
#include <sstream>
#include <cmath>
#include <chrono>

using namespace std;

class Matrix {
private:
    vector<vector<double>> data;
    int n, m;
public:
    Matrix(int n, int m) {
        this->n = n;
        this->m = m;
        for (int i = 0; i < n; i++) {
            data.push_back(vector<double>(m));
        }
    }
    double get(int x, int y) {
        return data.at(x).at(y);
    }
    void set(int x, int y, double value) {
        data.at(x).at(y) = value;
    }

    int getN() {
        return n;
    }

    int getM() {
        return m;
    }
    
    static Matrix getProduct(Matrix m1, Matrix m2) {
        Matrix matrix(m1.getN(), m2.getM());
        for (int i = 0; i < m1.getN(); i++) {
            for (int j = 0; j < m2.getM(); j++) {
                double sum = 0;
                for (int k = 0; k < m1.getM(); k++) {
                    sum += m1.get(i, k) * m2.get(k, j);
                }
                matrix.set(i, j, sum);
            }
        }

        return matrix;
    }

    static Matrix getProductByScalar(double scalar, Matrix m) {

        for (int i = 0; i < m.getN(); i++) {
            for (int j = 0; j < m.getM(); j++) {
                m.set(i, j, scalar * m.get(i, j));
            }
        }

        return m;
    }

    string toString() {
        stringstream ss;

        for (int i = 0; i < n; i++) {

            for (int j = 0; j < m; j++) {
                ss << get(i, j) << " ";
            }

            ss << endl;
        }

        return ss.str();
    }

};

double getDotProduct(Matrix v1, Matrix v2) {
    double sum = 0;
    
    for (int i = 0; i < v1.getN(); i++) {
        sum += v1.get(i, 0) * v2.get(i, 0);
    }

    return sum;
}

double getVectorMagnitude(Matrix v) {
    double sum = 0;

    for (int i = 0; i < v.getN(); i++) {
        sum += pow(v.get(i, 0), 2);
    }

    return sqrt(sum);
}

Matrix getVectorDifference(Matrix v1, Matrix v2, int start2, int end2) {
    Matrix difference(end2 - start2 + 1, 1);

    for (int i = 0; i < end2 - start2 + 1; i++) {
        difference.set(i, 0, v1.get(i, 0) - v2.get(start2 + i, 0));
    }

    return difference;
}

bool check(Matrix ax, Matrix b) {
    double epsilon = 0.00001;

    if (getVectorMagnitude(getVectorDifference(ax, b, 0, b.getN() - 1)) / getVectorMagnitude(b) < epsilon) {
        return true;
    }

    return false;
}

void iterate(Matrix a, Matrix x, Matrix b, int n, int rank, int num_tasks, int lines) {
    Matrix y = getVectorDifference(Matrix::getProduct(a, x), b, rank*lines, (rank + 1) * lines - 1);
    MPI_Barrier(MPI_COMM_WORLD);
    
    double* arr = new double[lines];
    double* arr2 = new double[lines];
    double* arr3 = new double[n];
    double* arr4 = new double[lines];
    double* arr5 = new double[lines];
    double* arr6 = new double[lines];
    double* arr7 = new double[n];
    double* arr8 = new double[n];
    double* arr9 = new double[n];
    if (rank != 0) {
        arr = new double[lines];
        for (int i = 0; i < lines; i++) {
            arr[i] = y.get(i, 0);
        }
        MPI_Send(arr, lines, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD);
    }
    MPI_Barrier(MPI_COMM_WORLD);
    
    Matrix Y(n, 1);
    if (rank == 0) {
        for (int j = 0; j < lines; j++) {
            Y.set(j, 0, y.get(j, 0));
        }
        
        if (num_tasks > 1) {
            for (int i = 1; i < num_tasks; i++) {
                MPI_Status stat;
                MPI_Recv(arr2, lines, MPI_DOUBLE, i, 1, MPI_COMM_WORLD, &stat);
                for (int j = 0; j < lines; j++) {
                    Y.set(i * lines + j, 0, arr2[j]);
                }
            }
        }
        
        for (int i = 0; i < n; i++) {
            arr3[i] = Y.get(i, 0);
        }
        for (int i = 1; i < num_tasks; i++) {
            MPI_Send(arr3, n, MPI_DOUBLE, i, 1, MPI_COMM_WORLD);
        }
    }
    
    MPI_Barrier(MPI_COMM_WORLD);

    if (rank != 0) {
        MPI_Status stat;
        MPI_Recv(arr3, n, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD, &stat);
        for (int i = 0; i < n; i++) {
            Y.set(i, 0, arr3[i]);
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);

    Matrix ay = Matrix::getProduct(a, Y);

    if (rank != 0) {
        for (int i = 0; i < lines; i++) {
            arr4[i] = ay.get(i, 0);
        }
        MPI_Send(arr4, lines, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD);
    }

    MPI_Barrier(MPI_COMM_WORLD);

    Matrix AY(n, 1);
    if (rank == 0) {
        for (int j = 0; j < lines; j++) {
            AY.set(j, 0, ay.get(j, 0));
        }

        if (num_tasks > 1) {
            for (int i = 1; i < num_tasks; i++) {
                MPI_Status stat;
                MPI_Recv(arr5, lines, MPI_DOUBLE, i, 1, MPI_COMM_WORLD, &stat);
                for (int j = 0; j < lines; j++) {
                    AY.set(i * lines + j, 0, arr5[j]);
                }
            }
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);

    Matrix x1(n, 1);

    if (rank == 0) {
        double t = getDotProduct(Y, AY) / getDotProduct(AY, AY);
        x1 = getVectorDifference(x, Matrix::getProductByScalar(t, Y), 0, n - 1);
    }
    
    MPI_Barrier(MPI_COMM_WORLD);

    if (rank == 0) {
        for (int i = 0; i < n; i++) {
            arr8[i] = x1.get(i, 0);
        }
        if (num_tasks > 1) {
            for (int i = 1; i < num_tasks; i++) {
                MPI_Send(arr8, n, MPI_DOUBLE, i, 1, MPI_COMM_WORLD);
            }
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);

    Matrix X1 = x1;
    if (rank != 0) {
        MPI_Status stat;
        MPI_Recv(arr9, n, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD, &stat);
        for (int i = 0; i < n; i++) {
            X1.set(i, 0, arr9[i]);
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);

    Matrix ax1 = Matrix::getProduct(a, X1);

    if (rank != 0) {
        for (int i = 0; i < lines; i++) {
            arr6[i] = ax1.get(i, 0);
        }
        MPI_Send(arr6, lines, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD);
    }

    MPI_Barrier(MPI_COMM_WORLD);

    Matrix AX(n, 1);
    if (rank == 0) {
        for (int j = 0; j < lines; j++) {
            AX.set(j, 0, ax1.get(j, 0));
        }

        if (num_tasks > 1) {
            for (int i = 1; i < num_tasks; i++) {
                MPI_Status stat;
                MPI_Recv(arr7, lines, MPI_DOUBLE, i, 1, MPI_COMM_WORLD, &stat);
                for (int j = 0; j < lines; j++) {
                    AX.set(i * lines + j, 0, arr7[j]);
                }
            }
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);

    int success = 0;

    if (rank == 0) {
        if (check(AX, b)) {
            success = 1;
            if (num_tasks > 1) {
                for (int i = 1; i < num_tasks; i++) {
                    MPI_Send(&success, 1, MPI_INT, i, 1, MPI_COMM_WORLD);
                }
            }
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);

    if (rank != 0) {
        MPI_Status stat;
        MPI_Recv(&success, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &stat);
    }

    MPI_Barrier(MPI_COMM_WORLD);

    if (success == 0) {
        iterate(a, X1, b, n, rank, num_tasks, lines);
    }
}


int main(int* argc, char** argv)
{
    int numtasks = 0, rank = 0;

    int n = 16 * 1000;

    MPI_Init(argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &numtasks);

    int lines = n / numtasks;

    Matrix a(lines, n);
    for (int i = 0; i < lines; i++) {
        for (int j = 0; j < n; j++) {
            if (i + rank * lines == j) {
                a.set(i, j, 2);
            }
            else {
                a.set(i, j, 1);
            }
        }
    }

    Matrix b(n, 1);

    for (int i = 0; i < n; i++) {
        b.set(i, 0, n + 1);
    }

    Matrix x(n, 1);

    for (int i = 0; i < n; i++) {
        x.set(i, 0, 0);
    }

    auto start = chrono::system_clock::now();

    iterate(a, x, b, n, rank, numtasks, lines);

    auto end = chrono::system_clock::now();

    MPI_Barrier(MPI_COMM_WORLD);

    chrono::duration<double> elapsed_seconds = end - start;
    int time = static_cast<int>(elapsed_seconds.count() * 1000); // milliseconds

    if (rank == 0) {
        cout << "Time: " << time << "ms" << endl;
    }

    MPI_Finalize();
    
}