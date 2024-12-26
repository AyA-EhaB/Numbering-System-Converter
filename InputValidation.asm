# Salma Gamal 20221073
# Aya Ehab    20221209


.data
base1: .asciiz "Enter the current system: "
num: .asciiz "Enter the number: "
base2:.asciiz "Enter the new system: "
errorMeg: .asciiz "Invalid number for the given base.\n"
buffer: .space 32  # Allocate space for the string (32bytes)

.text
main:

# Print base1
li $v0,4 # Syscall code for print_string
la $a0,base1 # Load the address
syscall 
# Get the intger input
li $v0,5
syscall 
move $t0,$v0 #now  t0=base1

# Print num
li $v0,4 # Syscall code for print_string
la $a0,num # Load the address
syscall 
# Get the string input
li $v0, 8 # Syscall code for reading a string
la $a0, buffer # Load the address of the buffer
li $a1, 32 # Set the maximum length of the input
syscall 

#💡 Validate number for current base
la $a0,buffer # Pass arguments (buffer)to the valid function
move $a1,$t0 #Passes the current base to the valid unction.
jal valid #Call function
beqz $v0,invalid

# Print for desired base
li $v0,4 # Syscall code for print_string
la $a0,base2 # Load the address
syscall 
# Get the intger input
li $v0,5
syscall 
move $t2, $v0   # $t2 = desired base

 # Continue ...
j exit

invalid:
li $v0,4
la $a0,errorMeg
syscall 
j exit # Exit immediately after showing the error message 


exit:
   li $v0,10
   syscall 
   
valid:
 # $a0 = buffer (string), $a1 = base1
la $t3, buffer    # Pointer to the input string
move $t4, $a1     # Copy the base1 to $t4
li $v0, 1         # Assume valid, set return value to 1
  loop:
    lb $t5,0($t3) # Load the current character from the string
    beqz $t5, validateEnd #  If $t5 is zero ,null terminator,the loop ends
    blt $t5, 58, valid_digit  # If the character is '0' to '9' (ASCII 48-57), jump to valid_digit
    bgt $t5, 64, check_alpha  # If the character is 'A' to 'F' (ASCII 65-70), jump to check_alpha


valid_digit:
    sub $t5, $t5, 48          # Convert ASCII value of '0' to '9' (48-57) to its integer value (0-9)
    bge $t5, $t4, invalidate  # If the digit >= the base, invalidate 
    j next_char                # If valid, jump to next character


check_alpha:
    sub $t5, $t5, 55          # Convert ASCII value of 'A' to 'F' (65-70) to its integer value (10-15)
    bge $t5, $t4, invalidate  # If the value >= the base 
    j next_char                # If valid, jump to next character

  
next_char:
    addi $t3, $t3, 1          # Move to the next character in the input string
    j loop                    # Repeat the loop to check the next character
    
    
    
invalidate:
    li $v0, 0                 # Set return value to 0 (invalid)

validateEnd:
    jr $ra                    # Return to caller