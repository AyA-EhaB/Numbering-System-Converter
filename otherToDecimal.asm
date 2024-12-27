.data
# Input sentences to be printed
name: .asciiz "Shahd Elnassag ^_^\n"              
numMesg: .asciiz "Enter the number: "              
baseMesg: .asciiz "Enter the base of the number: "  
resMesg: .asciiz "Number in decimal = "            
newline: .asciiz "\n"                            

number: .space 100             # number (string of chars)
base: .word 0                  # Store base 

arrayDigits: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' 

.text
main:
    # Print my name
    la $a0, name
    li $v0, 4             
    syscall

    # Print message to enter the number
    la $a0, numMesg
    li $v0, 4         
    syscall
    
    # Get number 
    la $a0, number       
    li $a1, 100           # Max size of number string
    li $v0, 8           
    syscall

    # Print message to enter the base
    la $a0, baseMesg
    li $v0, 4             
    syscall
    
    # Get base 
    li $v0, 5            
    syscall
    sw $v0, base          

    # Load number in $t0
    la $t0, number
    j loopNum            

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
