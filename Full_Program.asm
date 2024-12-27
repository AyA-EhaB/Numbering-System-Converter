.data
base1:      .asciiz "Enter the current system: "
num:        .asciiz "Enter the number: "
base2:      .asciiz "Enter the new system: "
errorMeg:   .asciiz "Invalid number for the given base.\n"
decimal_msg:.asciiz "Decimal conversion: "
buffer:     .space 32  
bases:      .asciiz "0123456789ABCDEF"  # Characters for digits in base 2 to base 16
result: .space 128       # Increase buffer size if necessary (e.g., 128 bytes)
overflow_msg: .asciiz "Error: Overflow occurred.\n"

.text
main:
    # Print base1 prompt
    li $v0, 4              
    la $a0, base1         
    syscall 

    # Get the current base (base1) as an integer
    li $v0, 5             
    syscall 
    move $t0, $v0           # $t0 = base1

    # Print num prompt
    li $v0, 4              
    la $a0, num             
    syscall 

    # Get the number input as a string
    li $v0, 8              
    la $a0, buffer         
    li $a1, 32             
    syscall 

    # Validate the number for the current base
    la $a0, buffer         
    move $a1, $t0          
    jal valid               # Validate number input

    beqz $v0, invalid       # If invalid, jump to the invalid case

    # Print base2 prompt
    li $v0, 4              
    la $a0, base2          
    syscall 

    # Get the desired base (base2) as an integer
    li $v0, 5              
    syscall 
    move $t2, $v0           # $t2 = desired base

    # Convert the number from base1 to decimal
    la $a0, buffer         
    move $a1, $t0          
    jal OtherToDecimal      # Convert to decimal
    move $t3, $v0           # Store decimal result in $t3

    # Print the decimal result
    li $v0, 4              
    la $a0, decimal_msg     
    syscall
    li $v0, 1              
    move $a0, $t3          
    syscall

    # Convert the decimal result to the desired base (base2)
    move $a0, $t3          
    move $a1, $t2          
    jal DecimalToAnyBase    # Convert to new base

    # Print the result
    la $t4, result          
print_result:
    lb $t5, 0($t4)          
    beqz $t5, exit          
    li $v0, 11              
    move $a0, $t5          
    syscall
    addi $t4, $t4, 1        
    j print_result         

invalid:
    # Print error message if input is invalid
    li $v0, 4              
    la $a0, errorMeg        
    syscall

exit:
    li $v0, 10              
    syscall


# Function: valid
valid:
    la $t3, buffer
    move $t4, $a1           # Set base1
    li $v0, 1               # Assume valid

loop_valid:
    lb $t5, 0($t3)          
    beqz $t5, validateEnd   
    blt $t5, 58, valid_digit
    bgt $t5, 64, check_alpha
    j invalidate

valid_digit:
    sub $t5, $t5, 48        
    bge $t5, $t4, invalidate
    j next_valid

check_alpha:
    sub $t5, $t5, 55        
    bge $t5, $t4, invalidate

next_valid:
    addi $t3, $t3, 1        
    j loop_valid

invalidate:
    li $v0, 0               
    j validateEnd

validateEnd:
    jr $ra                   # Return from the function

# Function: OtherToDecimal
OtherToDecimal:
    li $t0, 0           # $t0 = result (decimal)
    li $t3, 0           # $t3 = power (position)
    li $t4, 0           # $t4 = current digit
    li $t5, 10          # $t5 = divisor for extracting digits

DecimalLoop:
    lb $t4, 0($a0)      # Load the next digit from the number string
    beqz $t4, DecimalEndLoop  # End when no more digits

    div $t4, $t5        # Divide by 10 to get last digit
    mfhi $t4            # Get the last digit (remainder)
    mflo $a0            # Update to the next digit

    move $a0, $t1       # Base
    move $a1, $t3       # Power (position)
    jal power           # Calculate base^power

    mul $t6, $t4, $v0   # Multiply digit by base^power
    add $t0, $t0, $t6   # Add to result

    addi $t3, $t3, 1    # Increment power (position)
    j DecimalLoop       # Repeat for next digit

DecimalEndLoop:
    move $v0, $t0       # Return decimal result
    jr $ra              # Return from function

# Function: power
power:
    li $t0, 1           # $t0 = result (base^exponent)
    li $t3, 0           # $t3 = counter

PowerLoop:
    bge $t3, $a1, PowerEnd
    mul $t0, $t0, $t1   # Multiply result by base
    bnez $t0, noPowerOverflow
    j powerOverflow

noPowerOverflow:
    addi $t3, $t3, 1    # Increment counter
    j PowerLoop

PowerEnd:
    move $v0, $t0       # Return result (base^exponent)
    jr $ra               # Return from function

powerOverflow:
    li $v0, 4              
    la $a0, overflow_msg  # Print overflow message
    syscall
    j exit

# Handle multiplication overflow (both power and main logic)
overflow:
    li $v0, 4              
    la $a0, overflow_msg  # Print overflow message
    syscall
    j exit

exitp:
    li $v0, 10               
    syscall


# Function: DecimalToAnyBase
# Converts a decimal number to another base
DecimalToAnyBase:
    move $t0, $a0       # Load decimal number
    move $t1, $a1       # Load target base
    li $t3, 0           # Index for result
    li $t4, 0           # Temporary for remainder

    # Handle zero case immediately
    beqz $t0, print_zero

while:
    beq $t0, $zero, print_result    # If number is zero, go to print
    div $t0, $t1                 # Divide by base
    mfhi $t4                     # Remainder (next digit)
    mflo $t0                     # Update the quotient
    lb $t5, bases($t4)           # Get the character for the remainder
    sb $t5, result($t3)          # Store the character in result
    addi $t3, $t3, 1             # Increment result index

    li $t6, 32                  # Maximum length of result array
    bge $t3, $t6, print_result   # If index >= 32, print the result

    j while

print_zero:
    li $v0, 11
    li $a0, '0'               # Print 0 for zero input
    syscall
    jr $ra                     # Return from function
