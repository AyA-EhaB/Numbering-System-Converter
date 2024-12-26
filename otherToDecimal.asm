.data
name: .asciiz "Shahd Elnassag ^_^\n"
numMesg: .asciiz "Enter the number: "
baseMesg: .asciiz "Enter the base of the number: "
resMesg: .asciiz "Number in decimal = "
newline: .asciiz "\n"

.text
.globl main

main:
    # Print my name
    la $a0, name
    li $v0, 4
    syscall

    # Print message to enter the number
    la $a0, numMesg
    li $v0, 4
    syscall

    # Get number from user
    li $v0, 5
    syscall
    move $t2, $v0 # $t2 --> number

    # Print message to enter the base
    la $a0, baseMesg
    li $v0, 4
    syscall

    # Get base from user
    li $v0, 5
    syscall
    move $t1, $v0 # $t1 --> base

    # Call function to convert number to decimal
    jal OtherToDecimal

    # Print newline
    la $a0, newline
    li $v0, 4
    syscall

    # Terminate the program
    li $v0, 10
    syscall

# Function: OtherToDecimal
# Converts a number from a given base to decimal
OtherToDecimal:
    li $t0, 0       # $t0 --> result in decimal
    li $t3, 0       # $t3 --> power (position)
    li $t4, 0       # $t4 --> current digit
    li $t5, 10      # $t5 --> divisor for extracting digits

DecimalLoop:
    beq $t2, $zero, DecimalEndLoop # Exit when the number is fully processed

    # Extract the last digit of the number
    div $t2, $t5
    mfhi $t4                  # $t4 = last digit (remainder)

    # Calculate base^power
    move $a0, $t1             # Base
    move $a1, $t3             # Power (position)
    jal power                 # Call power function

    # Multiply the digit by base^power
    mul $t6, $t4, $v0         # $t6 = digit * (base^power)

    # Add to the result
    add $t0, $t0, $t6         # $t0 += $t6

    # Update for next digit
    div $t2, $t5              # Remove the last digit from $t2
    addi $t3, $t3, 1          # Increment the power (position)
    j DecimalLoop             # Repeat the loop

DecimalEndLoop:
    # Print result message
    la $a0, resMesg
    li $v0, 4
    syscall

    # Print the result
    move $a0, $t0
    li $v0, 1
    syscall
    jr $ra

# Function: power
# Calculates base^exponent
power:
    li $t0, 1                 # $t0 --> result
    li $t3, 0                 # $t3 --> counter

PowerLoop:
    bge $t3, $a1, PowerEnd    # Exit loop if counter >= exponent
    mul $t0, $t0, $t1         # $t0 *= base
    addi $t3, $t3, 1          # Increment counter
    j PowerLoop               # Repeat the loop

PowerEnd:
    move $v0, $t0             # Return result in $v0
    jr $ra
