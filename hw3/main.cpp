#include <iostream>

// A optimized school method based C++ program to check
// if a number is prime
#include <bits/stdc++.h>

using namespace std;
//list for prime nums
vector<int> primes;
// first massive a
vector<int> a;
// second massive b
vector<int> b;
// nums of threads
int threads;

void *isPrime(void *count) {
    // the index to check
    int ind = (int64_t) count;
    // massive for temp prime nums
    vector<int> ab;
    ab.push_back(a[ind] + b[ind]);
    ab.push_back(a[ind] - b[ind]);
    // for checking nums
    bool isPrime = true;
    for (int j = 0; j < ab.size(); ++j) {
        int n = ab[j];
        for (int i = 2; i <= (sqrt(abs(n))); i++) {
            if (n % i == 0 || n == 0) {
                isPrime = false;
                ab.clear();
                break;
            }
        }
        if (isPrime) {
            ab.clear();
            primes.push_back(ind);
            return count;

        }
    }
}

int checkInput(string msg) {
    int num;
    cout << msg;
    cin >> num;
    if (!cin.good()) {
        cout << "Wrong data" << endl;
        exit(0);
    }
    return num;
}

int main() {
    //input
    threads = checkInput("enter number of threads no more than 100 and more than 0\n");
    if (threads <= 0 || threads > 100) {
        cout << "Wrong number of threads no more than 100 and more than 0\n" << endl;
        exit(0);
    }
    int len = checkInput("enter how many nums in massive a and b\n\tIt sholud be more than 1000\n");
    if (len < 1000) {
        cout << "Wrong number of A's and B's elems\n" << endl;
        exit(0);
    }
    //making random work
    srand(time(NULL));
    for (int i = 0; i < len; ++i) {
        a.push_back(rand() % 100);
        b.push_back(rand() % 100);
    }

    // cyclic threads
    vector <pthread_t> threadss(threads);
    for (int k = 0; k < len; ++k) {
        if (k % threads == 0 && len != 0) {
            for (std::vector<pthread_t>::iterator it = threadss.begin();
                 it != threadss.end(); ++it) {
                pthread_join((pthread_t) * it, NULL);
            }
        }
        pthread_create(&threadss[k % threads], NULL, isPrime, (void *) k);

    }

    cout << "primes\n";
    for (int j = 0; j < primes.size(); ++j) {
        cout << primes[j] << " ";
    }
    //outputting file a
    ofstream fout;
    fout.open("a.txt");
    for (int l = 0; l < a.size(); ++l) {
        fout << a[l] << " ";
    }
    //outputting file b
    fout.close();
    fout.open("b.txt");
    for (int l = 0; l < a.size(); ++l) {
        fout << b[l] << " ";
    }
    fout.close();
    return 0;
}
