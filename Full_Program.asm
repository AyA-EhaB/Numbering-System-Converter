.data
base1: .asciiz "Enter the current system: "
num: .asciiz "Enter the number: "
base2: .asciiz "Enter the new system: "
errorMeg: .asciiz "Invalid number for the given base.\n"
buffer: .space 32  # Allocate space for the string (32bytes)                  
newline: .asciiz "\n"       
bases: .asciiz "0123456789ABCDEF"  
result: .space 32                   
input: .space 16                    
prompt: .asciiz "Enter a decimal number: "                     
number: .space 100             # number (string of chars)
base: .word 0                  # Store base 
arrayDigits: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' 

.text
main:
        # Print base1 prompt
    li $v0, 4                # Syscall code for print_string
    la $a0, base1            # Load the address of base1
    syscall 

    # Get the integer input for base1
    li $v0, 5                # Syscall code for reading an integer
    syscall 
    move $t0, $v0            # Store the base1 in $t0

    # Print num prompt
    li $v0, 4                # Syscall code for print_string
    la $a0, num              # Load the address of num prompt
    syscall 

    # Get the string input (number)
    li $v0, 8                # Syscall code for reading a string
    la $a0, buffer           # Load the address of the buffer
    li $a1, 32               # Set the maximum length of the input
    syscall 

    # Validate number for current base
    la $a0, buffer           # Pass buffer (input) to the validation function
    move $a1, $t0            # Pass current base to the validation function
    jal valid                # Jump to validation function
    beqz $v0, invalid        # If validation fails, jump to invalid label

    # Print base2 prompt for the desired base
    li $v0, 4                # Syscall code for print_string
    la $a0, base2            # Load the address of base2 prompt
    syscall 

    # Get the integer input for base2
    li $v0, 5                # Syscall code for reading a base integer
    syscall 
    move $t2, $v0            # Store the desired base in $t2

    # Call OtherToDecimal to convert the number from base1 to decimal
    la $a0, buffer           # Pass the input string (number) to OtherToDecimal
    move $a1, $t0            # Pass the base1
    jal OtherToDecimal       # Convert the number to decimal (result in $t1)

    # Print the result message (Decimal Result)
    li $v0, 4
    la $a0, resMesg
    syscall

    # Print the decimal number
    li $v0, 1               # Syscall code to print integer
    move $a0, $t1           # Pass the decimal value in $t1
    syscall

    # Convert decimal value to the new base (base2)
    move $t0, $t1           # Copy the decimal value into $t0
    move $t1, $t2           # Move base2 value into $t1
    jal DecimalToAnyBase    # Convert decimal to new base

    # Exit program
    li $v0, 10
    syscall
invalid:
    # Print invalid number message
    li $v0, 4
    la $a0, errorMeg
    syscall 
    j exit                    # Exit immediately after showing the error message 

exit:
    li $v0, 10               # Syscall code for exit
    syscall 

valid:
    # $a0 = buffer (input string), $a1 = base1
    la $t3, buffer           # Load the address of the input string
    move $t4, $a1            # Copy the base1 to $t4
    li $v0, 1                # Assume valid, set return value to 1

    loop:
        lb $t5, 0($t3)       # Load the current character from the string
        beqz $t5, validateEnd  # If $t5 is zero (null terminator), end the loop
        blt $t5, 58, valid_digit  # If the character is '0' to '9' (ASCII 48-57), jump to valid_digit
        bgt $t5, 64, check_alpha  # If the character is 'A' to 'F' (ASCII 65-70), jump to check_alpha

    valid_digit:
        sub $t5, $t5, 48      # Convert ASCII value of '0' to '9' (48-57) to its integer value (0-9)
        bge $t5, $t4, invalidate  # If the digit >= the base, invalidate
        j next_char            # If valid, jump to the next character

    check_alpha:
        sub $t5, $t5, 55      # Convert ASCII value of 'A' to 'F' (65-70) to its integer value (10-15)
        bge $t5, $t4, invalidate  # If the value >= the base, invalidate
        j next_char            # If valid, jump to next character

    next_char:
        addi $t3, $t3, 1      # Move to the next character in the input string
        j loop                 # Repeat the loop to check the next character

    invalidate:
        li $v0, 0             # Set return value to 0 (invalid)

    validateEnd:
        jr $ra                 # Return to caller

# loop for input string 
loopNum:
    lb $t1, 0($t0)        # ptr = current char
    beqz $t1, endLoop     # end if number null
    j nextChar           

nextChar:
    addi $t0, $t0, 1      # ptr = next char
    j loopNum            

endLoop:
    j mainTest            
    
mainTest:
    la $a1, arrayDigits   # Load digits array into $a1
    li $s0, 0             # I counter register $s0 to 0
    lw $t0, base          # Load base into $t0
    la $a0, number        # Load of number into $a0
    li $a1, 100           # Max string length for number
    # Print the result message
    la $a0, resMesg
    li $v0, 4             
    syscall
    
    # Call other base to decimal
    jal OtherToDecimal

# Other To Decimal Function
OtherToDecimal: 
    la $t3, number        # Load number string into $t3
    li $t5, 0             # length counter $t5 to 0
    jal numLength         # Call numLength function to calculate the length of the number string

    addi $t5, $t5, -1     # Adjust length to index position
    add $t6, $t5, $zero   # Copy length into $t6 for further processing
    addi $t6, $t6, -1     # Decrease by 1 for 0-based indexing

    li $s3, 1             # Initialize multiplier to 1
    jal Power              # Call Power function to calculate powers of the base

    li $t6, 0             # Reset index for number string to 0
    li $t1, 0             # Initialize result to 0

    la $t3, number        # Load address of number string into $t3
funLoop:
    beq $t6, $t5, EndOtherToDecimal  # If index matches length, end the loop
    lb $t7, 0($t3)        # Load current digit character from number string into $t7

    # Search for the digit in the allowed digits array
    jal searchDigit

    # Multiply the found digit value by the base power and add to the result
    mul $a3, $t8, $s3     # Multiply the digit's value by the current power of the base
    add $t1, $t1, $a3     # Add the result to the final decimal result
    addi $t6, $t6, 1      # Move to the next character
    div $s3, $t0          # Divide base power by the base
    mflo $s3              # Move quotient (next power) into $s3
    addi $t3, $t3, 1      # Move to the next character in the number string
    j funLoop             # Repeat the loop for the next character

EndOtherToDecimal:
    # Print the final result 
    li $v0, 1             
    move $a0, $t1         
    syscall

    # Print a newline
    li $v0, 4
    la $a0, newline       
    syscall

    # Exit the program
    li $v0, 10           
    syscall

# Get the length of the string
numLength:
    lb $t4, 0($t3)        # Load current character from number string
    beqz $t4, EndLength   # End if null terminator is reached
    addi $t5, $t5, 1      # Increment the length counter
    addi $t3, $t3, 1      # Move to next character in the string
    j numLength           # Continue the loop

EndLength:
    jr $ra                # Return from function

# Power function to calculate base^index
Power: 
    beqz $t6, EndPower    # End if index is 0
    mul $s3, $s3, $t0     # Multiply current base power by base
    addi $t6, $t6, -1     # Decrease index
    j Power               # Repeat multiplication

EndPower: 
    jr $ra                

# Search for the digit in digits array
searchDigit:
    la $s4, arrayDigits   # Load address of allowed digits array
    li $t8, 0             # ounter 
    li $t9, 16            # digits arraySize = 16

searchLoop:
    beq $t8, $t9, endSearch   # End if all characters are checked
    lb $a3, 0($s4)            # Load current digit into $a3
    beq $a3, $t7, endSearch  # If found, end search

    addi $s4, $s4, 1      # Move to the next digit 
    addi $t8, $t8, 1      # counter++
    j searchLoop          # Continue searching

endSearch:
    jr $ra               


# Converts a decimal string
StringToInt:
    addi  $t0,$zero, 0  #decimal =0;
    addi   $t1,$zero,0       

stringToDecimalloop:
    lb $t2, input($t1)     
    beq $t2,0, done              
    subi $t2, $t2, 48            #char  to decimal
    blt $t2, 0, done             # if less than zero end 
    bgt $t2, 9, done             # if greater than 9 end 
    mul $t0, $t0, 10             # decimal* 10
    add $t0, $t0, $t2            
    addi $t1, $t1, 1             # index++
    j stringToDecimalloop

done:
    jr $ra              # Return to caller

DecimalToAnyBase:
    li $t3, 0           # index of result
    li $t4, 0           # index of Bases

while:
    beq $t0, $zero, print    # while num > 0
    div $t0, $t1
    mfhi $t4                 # Get remainder
    mflo $t0                 # Update num
    lb $t5, bases($t4)       # Get the char from bases
    sb $t5, result($t3)      
    addi $t3, $t3, 1       
    j while

print:
    addi $t6, $zero, 0     
    
loopd:
    beq $t3, $t6, Exist      # If index== 0, end
    subi $t3, $t3, 1         # index--
    li $v0, 11               # Print character
    lb $a0, result($t3)
    syscall
    j loopd

Exist:
    jr $ra                   # Function end
