// Lab 3 template file
.data

.global login_name
login_name:
    .asciz "adannhau"

.global puid
puid:
    .asciz "0033498781"

.balign 4

.equ TEST_SORT,         0x1
.equ TEST_STRCONCAT,    0x2
.equ TEST_FIB,          0x4
.equ TEST_BSEARCH,      0x8
.equ TEST_ALL,          (TEST_BSEARCH)

// Replace the TEST_ALL with the tests you want to run
// OR expression also support like the TEST_ALL above
// i.e. replace the TEST_ALL below with TEST_SORT | TEST_STRCONCAT
//      will test on the sort and strconcat
.global test
test:
    .word TEST_ALL


// Align to 4bytes boundary as we have a string above
.balign 4

.text
.global asm_sort_int
asm_sort_int:
    /* void asm_sort_int(int32_t* arr, uint32_t n)
     * relies on `qsort` in C standard library to 
     * sort in ascending order
     **/

    /* Enter your code after this comment */
    addi sp, sp, -4     // increase size of heap by 4
    sw x1, 0(sp)        // store x1 value in first position on heap
    li x12, 4           // loads 4 in x12
    la x13, asm_cmp     // loads a label address into register x13
    jal ra, qsort;      // 
    lw x1, 0(sp)
    addi sp, sp, 4
    /* Enter your code above this comment */
    ret

.global asm_cmp
asm_cmp:
    // int asm_cmp(const void * a, const void * b)
    // Compare function to int32_t
    // used for qsort
    /* Enter your code after this comment */
    addi sp, sp, -4
    sw x1, 0(sp)
    lw x10, 0(x10)
    lw x11, 0(x11)
    sub x5, x10, x11       // store a - b into x5
    blt x5, x0, exit1
    jal x0, exit2
    exit1:
        li x10, -1 
        jal x0, done
    exit2:
        li x10, 1
    done:
        lw x1, 0(sp)
        addi sp, sp, 4
        jr ra
    /* Enter your code above this comment */
    ret

.global asm_strconcat
asm_strconcat:
    /* char* asm_strconcat(char * str1, char * str2)
     * First assign memory space with `malloc`, 
     * concatenating `str1` and `str2`, 
     * and return the resulted string.
     **/
    /* Enter your code after this comment */
    addi sp, sp, -32
    sw ra, 0(sp)
    sw x10, 4(sp)
    sw x11, 8(sp)

    
    jal x1, strlen
    sw x10, 12(sp)      // store n1 in 12(sp)
    lw x10, 8(sp)         // set x10 to be x11
    jal x1, strlen      // call strlen for str2
    sw x10, 16(sp)      // store n2 in 16(sp)

    lw x12, 12(sp)      // load n1 into x12
    addi x10, x12, 1    // x10 = n1 + 1
    lw x13, 16(sp)
    add x10, x13, x10   // x10 = n2 + n1 + 1 (size)
    sw x10, 20(sp)      // store size into 20(sp)
    jal x1, malloc      // x10 = malloc(n2+n1+1)   x10 = buf
    sw x10, 24(sp)      // store buf in 24(sp)

    // memcpy functions are void so no return change to x10
    lw x11, 4(sp)       // load str1 into x11
    lw x12, 12(sp)      // load n1 into x12
    jal x1, memcpy      // x10 = buf, x11 = str1, x12 = n1
    
    lw x10, 24(sp)      // x10 = buf
    lw x12, 12(sp)      // x12 = n1
    add x10, x10, x12   // x10 = buf + n1
    lw x11, 8(sp)       // x11 = str2
    lw x12, 16(sp)      // x12 = n2
    jal x1, memcpy

    lw x10, 24(sp)      // x10 = buf
    lw x11, 20(sp)      // x11 = size
    addi x11, x11, -1   // x11 = size -1
    add x10, x10, x11   // x10 = buf[size - 1]
    sb x0, 0(x10)
    lw x10, 24(sp)      // x10 = buf
    

    // restore values 
    lw ra, 0(sp)
    lw x11, 8(sp)
    addi sp, sp, 32
    /* Enter your code above this comment */
    ret

.global asm_fib
asm_fib:
    /* uint32_t asm_fib(uint32_t n)
     * accept an index term `n` and return 
     * the Fn fibonacci term (F0 = 0, F1 = 1)
     **/

    /* Enter your code after this comment */
    
    addi sp, sp, -12             
    sw ra, 0(sp)            // store return address
    sw x10, 4(sp)           // store x10 val

    li x5, 1
    li x6, 2
    bge x10, x6, moreThan2
        j resto
    moreThan2:
        sub x10, x10, x5    // x10 = x10 - 1
        jal x1, asm_fib     // cal for n-1
        sw x10, 8(sp)         // return from fib(n-1) gets stored in x11
        lw x10, 4(sp)       // restore x10 to original value
        sub x10, x10, x6    // x10 = x10 - 2
        jal x1, asm_fib     // call for n-2
        mv x12, x10
        lw x11, 8(sp)
        add x13, x11, x12
        mv x10, x13         // return fib(n-1) - fib(n-2)
    resto:
        lw ra, 0(sp)        // load return address
        addi sp, sp, 12
    /* Enter your code above this comment */
    ret

.global asm_bsearch
asm_bsearch:
    /* int32_t asm_bsearch(int *arr, int key, 
                    int32_t start,
                    int32_t end)
     * Return the index of the element in the array
     * if the element does not exist, return -1 instead
     * arr: integer array to be searched
     * key: the element we want to search on
     * start: start index of subarray, inclusive
     * end: end index of subarray, inclusiveloop through an entire string and only convert
     **/

    /* Enter your code after this comment */
    addi sp, sp, -24
    sw ra, 0(sp)
    sw x10, 4(sp)       // store the *arr
    sw x11, 8(sp)       // store the key
    sw x12, 12(sp)      // store the start
    sw x13, 16(sp)      // store the end
    
    ble x12, x13, skip
        li x10, -1
        jal x0, done3
    skip:
        add x14, x12, x13       // x14 = start + end
        srai x14, x14, 1        // shifting right by 1 is divide by 2
        sw x14, 20(sp)          // 20(sp) = mid
        slli x15, x14, 2
        add x10, x10, x15 
        lw x10, 0(x10)          // load value at arr[mid]
            bge x10, x11, midLess   
            addi x12, x14, 1    // x12 = mid + 1 
            lw x10, 4(sp)       // set x10 back to arr
            jal x1, asm_bsearch
            jal x0, done3
        midLess:
            beq x10, x11, baseCase
            addi x13, x14, -1   // x13 = mid - 1
            lw x10, 4(sp)
            jal x1, asm_bsearch
            jal x0, done3
        baseCase:
            mv x10, x14
    done3:
        lw ra, 0(sp)
        addi sp, sp, 24
    /* Enter your code above this comment */
    ret
