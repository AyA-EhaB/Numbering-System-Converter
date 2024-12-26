#include <stdio.h>

int power(int base , int power){
    int cnt = 0;
    int res = 1;
    while (cnt < power)
    {
        res = res * base;
        cnt++;
    }

    return res;
}

int OtherToDecimal(int number, int base) {
    int decimal = 0; 
    int pow = 0;   

    while (number > 0) {
        int digit = number % 10; 

        decimal += digit * power(base, pow);

        number /= 10; 
        pow++;      
    }

    return decimal;
}


int main() {
    printf("Shahd Elnassag ^_^ \n");
    int number, base;

    printf("Enter the number: ");
    scanf("%d", &number);

    printf("Enter the base of the number: ");
    scanf("%d", &base);

    int result = OtherToDecimal(number, base);
    printf("The number in decimal : %d\n", result);

    return 0;
}
