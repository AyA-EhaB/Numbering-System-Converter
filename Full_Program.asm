.data
base1:      .asciiz "Enter the current system: "
num:        .asciiz "Enter the number: "
base2:      .asciiz "Enter the new system: "
errorMsg:   .asciiz "Invalid number for the given base.\n"
buffer:     .space 32      # Buffer for user input
bases:      .asciiz "0123456789ABCDEF" # Characters for digits in base 2 to base 16
result:     .space 32      # Space for the result
.text
.globl main

main:
    # Get current base (base1)
    li $v0, 4
    la $a0, base1
    syscall
    
    li $v0, 5
    syscall
    move $t0, $v0    # Store base1 in $t0

    # Get number to be converted
    li $v0, 4
    la $a0, num
    syscall
    
    li $v0, 8
    la $a0, buffer
    li $a1, 32
    syscall

    # Validate the number for the current base
    la $a0, buffer   # Pass buffer to validation function
    move $a1, $t0    # Pass base1 to validation function
    jal valid
    beqz $v0, invalid

    # Get new base (base2)
    li $v0, 4
    la $a0, base2
    syscall

    li $v0, 5
    syscall
    move $t2, $v0    # Store base2 in $t2

    # Convert the number to decimal (OtherToDecimal function)
    la $a0, buffer
    move $a1, $t0    # Pass the current base
    jal OtherToDecimal

    # Convert the decimal number to the new base (DecimalToOther function)
    move $t0, $v0    # Move decimal result to $t0
    move $t1, $t2    # Move new base to $t1
    jal DecimalToOther

    # Exit program
    j exit

invalid:
    li $v0, 4
    la $a0, errorMsg
    syscall
    j exit

exit:
    li $v0, 10
    syscall

# Function: OtherToDecimal
# Converts a number from a given base to decimal
OtherToDecimal:
    li $t0, 0       # Result in decimal
    li $t3, 0       # Power (position)
    li $t4, 0       # Current digit
    li $t5, 10      # Divisor for extracting digits

DecimalLoop:
    beq $t2, $zero, DecimalEndLoop  # Exit when the number is fully processed
    div $t2, $t5                   # Divide number by base
    mfhi $t4                        # Last digit (remainder)

    # Calculate base^power using power function
    move $a0, $t1
    move $a1, $t3
    jal power                       # Call power function

    # Multiply digit by base^power
    mul $t6, $t4, $v0               # $t6 = digit * base^power
    add $t0, $t0, $t6               # Add to result

    div $t2, $t5                    # Remove last digit
    addi $t3, $t3, 1                # Increment power
    j DecimalLoop                   # Repeat loop

DecimalEndLoop:
    move $v0, $t0                   # Return result in $v0
    jr $ra

# Function: power
# Calculates base^exponent iteratively
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

# Function: DecimalToOther
# Converts a decimal number to the desired base
DecimalToOther:
    li $t3, 0       # Index for result
    li $t4, 0       # Remainder
    li $t5, 16      # Maximum base (hexadecimal)

ConvertLoop:
    beqz $t0, ConvertEnd    # Exit if number is 0
    div $t0, $t1            # Divide by base
    mfhi $t4                # Remainder (digit)
    mflo $t0                # Quotient
    lb $t6, bases($t4)      # Get the digit from 'bases' string
    sb $t6, result($t3)     # Store character in result
    addi $t3, $t3, 1        # Increment index
    j ConvertLoop

ConvertEnd:
    li $t7, 0               # Reverse the result to print correctly
ReverseLoop:
    beq $t3, $t7, PrintResult  # If all characters have been processed
    subi $t3, $t3, 1          # Decrement index
    lb $a0, result($t3)       # Load character from result
    li $v0, 11               # Syscall to print character
    syscall
    j ReverseLoop

PrintResult:
    jr $ra

# Function: valid
# Validates if the number matches the given base
valid:
    # $a0 = buffer (string), $a1 = base
    la $t3, buffer    # Pointer to input string
    move $t4, $a1     # Copy base to $t4
    li $v0, 1         # Assume valid, set return value to 1

checkLoop:
    lb $t5, 0($t3)     # Load current character
    beqz $t5, validateEnd  # If null terminator, end loop
    blt $t5, 58, valid_digit   # Check if '0'-'9'
    bgt $t5, 64, check_alpha   # Check if 'A'-'F'

valid_digit:
    sub $t5, $t5, 48       # Convert '0'-'9' to 0-9
    bge $t5, $t4, invalidate # If digit >= base, invalidate
    j next_char

check_alpha:
    sub $t5, $t5, 55       # Convert 'A'-'F' to 10-15
    bge $t5, $t4, invalidate # If value >= base, invalidate
    j next_char

next_char:
    addi $t3, $t3, 1       # Move to next character
    j checkLoop

invalidate:
    li $v0, 0             # Return invalid (0)
validateEnd:
    jr $ra

