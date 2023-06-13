@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16                @ This directive selects the instruction set being generated.
                        @ The value 16 selects Thumb, with the value 32 selecting ARM.
.text                   @ Tell the assembler that the upcoming section is to be considered
                        @ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2                @ Code alignment - 2^n alignment (n=2)
                        @ This causes the assembler to use 4 byte alignment

.syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                        @ instructions. The default is divided (separate instruction sets)

.global add_test        @ Make the symbol name for the function visible to the linker
.global mk_led_demo_a2
.global string_test
.global mkGame

.type mkGame, %function

.code 16                @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func             @ Specifies that the following symbol is the name of a THUMB
                        @ encoded function. Necessary for interlinking between ARM and THUMB code.

.type add_test, %function @ Declares that the symbol is a function (not strictly required)

@ Function Declaration : int add_test(int x, int y, int delay, int counter)
@
@ Input: r0, r1, r2 (i.e. r0 holds x, r1 holds y, r2 holds delay, r3 holds counter)
@ Returns: r0
@
@ Here is the actual add_test function
add_test:
    add r0, r0, r1

bx lr @ Return (Branch eXchange) to the address in the link register (lr)
.size add_test, .-add_test @@ - symbol size (not strictly required, but makes the debugger happy)



.data
reload_value: .word 0                    @ Variable to hold the reload value
blink_rate: .word 0                      @ Variable to hold the blink rate
initial_blink_rate: .word 0              @ Initial value of the blink rate
initial_game_time: .word 3               @ Initial value of the game time
LEDaddress: .word 0x48001014             @ Address of the LED
cycle_to_toggle: .word 1                 @ Variable to control the toggle cycle
execute_mk_a5: .word 0                   @ Flag to control execution of _mk_a5_tick_handler
button_pressed: .word 0                  @ Variable to hold the button pressed state


@@ Function Header Block
.code 16                                @ This directive selects the instruction set being generated.
                                        @ The value 16 selects Thumb, with the value 32 selecting ARM.
.text

.global _mk_watchdog_start              @ Make the symbol name for the function visible to the linker

.type _mk_watchdog_start, %function     @ Declares that the symbol is a function 

@ function Declaration: mk_watch(uint32_t reload_value, uint32_t blink_rate);
@
@ Input: R0 (holds the value of reload), R1 (holds the value of blink rate)
@ Return: none
@
@ Description: Initializes the watchdog and starts it with the specified reload value and blink rate.
_mk_watchdog_start:
    push {r4-r7,lr}
    
    ldr r2, =reload_value
    str r0, [r2]                    @ store value of r0 in reload_value
    
    ldr r2, =blink_rate          
    str r1, [r2]                    @ store value of r1 in blink_rate

    ldr r2, =initial_blink_rate     @ keep initial value to use later
    str r1, [r2]

    ldr r2, =execute_mk_a5
    mov r3, #1                      @ set execute_mk_a5 to 1
    str r3, [r2]                    @ initialize execute_mk_a5 to 1


    @ initializing watchdog
    push {r0-r3, lr}
    bl mes_InitIWDG
    pop {r0-r3, lr}

    @ @ starting watchdog
    push {r0-r3, lr}
    bl mes_IWDGStart
    pop {r0-r3, lr}

    
    
    pop {r4-r7,lr}
    bx lr

.size _mk_watchdog_start, .-_mk_watchdog_start @@ - symbol size (not strictly required, but makes the debugger happy)





.type busy_delay, %function

@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0 (i.e. r0 holds number of cycles to delay)
@ Returns: r0
@
@ Here is the actual function. DO NOT MODIFY THIS FUNCTION.
busy_delay:
    push {r5}
    mov r5, r0
delay_1oop:
    subs r5, r5, #1
    bge delay_1oop
    mov r0, #0                  @ Return zero (success)
    pop {r5}
    bx lr                       @ Return (Branch eXchange) to the address in the link register (lr)



@ Assembly file ended by single .end directive on its own line
.end
Things past the end directive are not processed, as you can see here.