#include <iostream>
#include <fstream>
#include <string>
#include <sys/types.h>
#include <dirent.h>
#include <vector>
#include <algorithm>

using namespace std;


string get_ext (const string& st) {
    size_t pos = st.rfind('.');
    if (pos <= 0) return "";
    return st.substr(pos+1, string::npos);
}


int main(int argc, char **argv) {
    string PATH = argv[1];
    DIR *mydir = opendir(argv[1]);
    if(!mydir) {
        perror("opendir");
        return -1;
    }
    struct dirent *entry;
    entry = readdir(mydir);
    vector<pair<string, int>> list;
    while(entry) {
        string expansion = get_ext(entry->d_name);
        if (expansion == "dot") {
            int k = 0;
            ifstream f(PATH + entry->d_name);
            string line;
            if(f.is_open())
            {
                while (getline(f, line))
                {
                    int start = 0;
                    int end = 0;
                    while (line.find('-', end) != string::npos)
                    {
                        start = line.find('-', end) + 1;
                        end = line.find(' ', start);
                        k++;
                    }
                }
                f.close();
            }
            pair <string , int> p;
            p = make_pair(entry->d_name, k);
            list.push_back(p);
        }
        entry = readdir(mydir);
    }
    closedir(mydir);
    sort(list.begin(), list.end(), [](auto a, auto b) { return a.first < b.first; });
    for (auto x : list) { cout << x.first << " " << x.second << endl; }
    ofstream result("../m.txt");
    for(auto filename: list) result << filename.first << " " << filename.second << endl;
    return 0;
}
