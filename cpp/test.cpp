#include <iostream>
#include <cstdint>
using namespace std;

int main(){
    int src[] = {1, 2, 3, 4, 5, 6, 7, 8};
    int dst[8];
    std::memcpy(&dst, &src, 8 * sizeof(int));
    cout << dst[8] << endl;
    return 0;
}


