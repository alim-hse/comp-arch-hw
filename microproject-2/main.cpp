#include <iostream>
#include <thread>
#include "semaphore.h"
#include "windows.h"
#include "process.h"

using namespace std;

int checkInput(string message);
void takeRoom(int i);


int n, m;
thread *ths;	     // array of threads.
HANDLE sem, fullHotelSem;

int main() {
    cout << "Welcome to Araski-plaza\n" << endl;
    n = checkInput("Enter n(number of visitors [30; 100]): ");				  // check if entered values are correct.
    m = 30;
    cout << "\nWe have " << n << " visitors and " << m << " rooms\n" << endl;
    Sleep(1000);


    fullHotelSem = CreateSemaphore(NULL, 1, m, NULL);
    sem = CreateSemaphore(NULL, 1, 1, NULL);
    ths = new thread[n];

    // Start threads.
    for (int i = 0; i < n; ++i)
        ths[i] = thread(takeRoom, i + 1);

    // Waiting for finishing
    for (int i = 0; i < n; ++i)
        ths[i].join();

    cout << "\nAll visitors will try to take a room for 3 times!" << endl;
    delete[] ths; // delete memory which allocated for dynamic array.
}

/// <summary>
/// Check if entered data is correct and write a message for user
/// </summary>
/// <param name="message">message for user</param>
/// <returns>value entered by user</returns>
int checkInput(string message) {
    while (true) {
        cout << message;
        int num;
        cin >> num;
        if (cin.fail()) {
            cin.clear();
            cin.ignore(32767, '\n');
            cout << "You should enter a number [30;100]" << endl;
        }
        else if (num < 30 || num > 100) {
            cin.clear();
            cin.ignore(32767, '\n');
            cout << "You should enter a number [30;100]" << endl;
        }
        else
            return num;
    }
}

/// <summary>
/// Method which every visitor use for taking room
/// </summary>
/// <param name="i">number of visitors</param>
void takeRoom(int i) {
    for (int j = 0; j < 3; ++j) {

        WaitForSingleObject(sem, INFINITE);
        if (m == 0){
            cout << "hotel is full, visitor "<< i<<" can't take room\n";
            ReleaseSemaphore(sem, 1, NULL);
            WaitForSingleObject(fullHotelSem, INFINITE);
            
            ReleaseSemaphore(fullHotelSem, 1, NULL);
            //m++;
        }// Only m visitors can take room.
        else{
        m--;
        cout << "Visitor " << i << " takes a room. Remain: " << m << " rooms" << endl; // report

        ReleaseSemaphore(sem, 1, NULL);         // Realease semaphor for next visitor.
        WaitForSingleObject(sem, INFINITE);
        Sleep(1000);
        m++;
        cout << "Visitor " << i << " left a room" << endl;
        ReleaseSemaphore(fullHotelSem, 1, NULL);
        ReleaseSemaphore(sem,1,NULL);}
        //WaitForSingleObject(sem, INFINITE);

    }
}
