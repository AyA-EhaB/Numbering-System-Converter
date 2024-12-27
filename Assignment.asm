.data
bases:  .asciiz "0123456789ABCDEF"  
result: .space 32                  
input:  .space 16                   
prompt: .asciiz "Enter a decimal number: "
.text

main:
    # input to function
    li $v0, 4
    la $a0, prompt
    syscall
 
    li $v0, 8
    la $a0, input
    li $a1, 16  
    syscall
    jal StringToInt

    addi $t1, $zero, 2  


    jal DecimalToAnyBase

    li $v0, 10        
    syscall


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
    
loop:
    beq $t3, $t6, Exist      # If index== 0, end
    subi $t3, $t3, 1         # index--
    li $v0, 11               # Print character
    lb $a0, result($t3)
    syscall
    j loop

Exist:
    jr $ra                   # Function end

