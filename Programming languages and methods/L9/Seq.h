#ifndef SEQUENCE_SEQ_H
#define SEQUENCE_SEQ_H


#include <vector>
using namespace std;


template<typename T>
class Seq {
public:
    Seq() = default;
    ~Seq() = default;

    T  operator[](int i) { return arr[i]; }

    void add(T elem) { arr.emplace(arr.begin() + position(elem), elem); }

    void del(int i) { arr.erase(arr.begin() + i); }

    int size() { return arr.size(); }

    Seq<T> operator+(Seq seq) {
        Seq<T> res;
        for (int i = 0; i < arr.size(); i++) { res.add(arr[i]); }
        for (int i = 0; i < seq.size(); i++) { res.add(seq[i]); }
        return res;
    }

    int find(T elem) {
        int l = -1, r = arr.size(), m;
        while (l < r - 1) {
            m = (l + r) / 2;
            if (arr[m] > elem) r = m;
            else l = m;
        }
        if (l != -1 && l != arr.size() && arr[l] == elem) return l;
        return -1;
    }

    Seq<T> operator*(Seq seq) {
        Seq<T> res;
        for (int i = 0; i < arr.size(); i++) {
            if (seq.find(arr[i]) != -1) res.add(arr[i]);
        }
        return res;
    }

    Seq<T> operator-(Seq seq) {
        Seq<T> res;
        for (int i = 0; i < arr.size(); i++) {
            if (seq.find(arr[i]) == -1) res.add(arr[i]);
        }
        return res;
    }
private:
    vector<T> arr;
    int position(T elem) {
        int l = -1, r = arr.size(), m;
        while (l < r - 1) {
            m = (l + r) / 2;
            if (arr[m] > elem) r = m;
            else l = m;
        }
        return l + 1;
    }
};


#endif
