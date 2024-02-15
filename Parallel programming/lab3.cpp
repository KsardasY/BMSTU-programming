#include <iostream>
#include <omp.h>
#include <vector>
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

void iterate(Matrix a, Matrix x, Matrix b, Matrix& yn, Matrix& ayn, Matrix& xn1, Matrix& axn1, bool& success, int n, int rank, int num_tasks, int lines) {
    Matrix y = getVectorDifference(Matrix::getProduct(a, x), b, rank * lines, (rank + 1) * lines - 1);

    for (int i = rank * lines, k = 0; i < (rank + 1) * lines; i++, k++) {
        yn.set(i, 0, y.get(k, 0));
    }

#pragma omp barrier

    Matrix ay = Matrix::getProduct(a, yn);

    for (int i = rank * lines, k = 0; i < (rank + 1) * lines; i++, k++) {
        ayn.set(i, 0, ay.get(k, 0));
    }

#pragma omp barrier

    if (rank == 0) {
        double tn = getDotProduct(yn, ayn) / getDotProduct(ayn, ayn);
        xn1 = getVectorDifference(x, Matrix::getProductByScalar(tn, yn), 0, n - 1);
    }

#pragma omp barrier

    Matrix ax1 = Matrix::getProduct(a, xn1);

    for (int i = rank * lines, k = 0; i < (rank + 1) * lines; i++, k++) {
        axn1.set(i, 0, ax1.get(k, 0));
    }

#pragma omp barrier

    if (rank == 0) {
        success = check(axn1, b);
    }

#pragma omp barrier

    if (!success) {
        iterate(a, xn1, b, yn, ayn, xn1, axn1, success, n, rank, num_tasks, lines);
    }
}

int main(int argc, char** argv) {
    int n = 16 * 1000;
    int numtasks = 16;
    omp_set_num_threads(numtasks);
    int lines = n / numtasks;

    Matrix b(n, 1);

    for (int i = 0; i < n; i++) {
        b.set(i, 0, n + 1);
    }

    Matrix x(n, 1);

    for (int i = 0; i < n; i++) {
        x.set(i, 0, 0);
    }

    Matrix yn(n, 1);

    for (int i = 0; i < n; i++) {
        yn.set(i, 0, 0);
    }

    Matrix ayn(n, 1);

    for (int i = 0; i < n; i++) {
        ayn.set(i, 0, 0);
    }

    Matrix xn1(n, 1);

    for (int i = 0; i < n; i++) {
        xn1.set(i, 0, 0);
    }

    Matrix axn1(n, 1);

    for (int i = 0; i < n; i++) {
        axn1.set(i, 0, 0);
    }

    bool success = true;

    auto start = chrono::system_clock::now();

#pragma omp parallel
    {
        int rank = omp_get_thread_num();
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
        iterate(a, x, b, yn, ayn, xn1, axn1, success, n, rank, numtasks, lines);
    }

    auto end = chrono::system_clock::now();

    chrono::duration<double> elapsed_seconds = end - start;
    int time = static_cast<int>(elapsed_seconds.count() * 1000); // milliseconds
    cout << "Time: " << time << "ms" << endl;

    return 0;
}