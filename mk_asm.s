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


@@ Function Header Block
.code 16                                @ This directive selects the instruction set being generated.
                                        @ The value 16 selects Thumb, with the value 32 selecting ARM.
.text

.global _mk_a5_button_handler              @ Make the symbol name for the function visible to the linker

.type _mk_a5_button_handler, %function     @ Declares that the symbol is a function 

@ function Declaration: void _mk_a5_button_handler(void);
@
@ Input: none
@ Return: none
@
@Description: Handles the button press event.
_mk_a5_button_handler:
    push {lr}
    
    ldr r0, =button_pressed             @ take the address of button_pressed
    mov r1, #1                          @ set r1 to be #1   
    str r1, [r0]                        @ store r1 into button_pressed
    
    pop {lr}
    bx lr

.size _mk_a5_button_handler, .-_mk_a5_button_handler @@ - symbol size (not strictly required, but makes the debugger happy)


@@ Function Header Block
.align 2                @ Code alignment - 2^n alignment (n=2)
                        @ This causes the assembler to use 4 byte alignment

.syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                        @ instructions. The default is divided (separate instruction sets)

.global _mk_a5_tick_handler        @ Make the symbol name for the function visible to the linker

.code 16                @ This directive selects the instruction set being generated.
                        @ The value 16 selects Thumb, with the value 32 selecting ARM.
.thumb_func             @ specifies that the following symbol is the name of a THUMB
                        @ encoded function. 

.type _mk_a5_tick_handler, %function    @ Declares that the symbol is a function 

@ function Declaration: 
@
@ Input: none
@ Return: none
@
@H Description: Blinks the LEDs and if an interrupt happens reset the board using watchdog
_mk_a5_tick_handler:
    push {r4-r7,lr}
    
    ldr r0, =execute_mk_a5
    ldr r1, [r0]
    cmp r1, #0                  @ Check if execute_mk_a5 is 0
    beq cycle_end               @ If it's 0, skip execution of _mk_a5_tick_handler
                                @ This flag prevents the function from running when
                                @ you want to run other functions
    ldr r0, =button_pressed           
    ldr r1, [r0]
    cmp r1, #1
    beq skip_refreshing_watchdog

    bl mes_IWDGRefresh              @ refresh watchdog timeout
    
skip_refreshing_watchdog:
      

    ldr r1, =initial_game_time
    ldr r0, [r1]
    subs r0, #1
    ble cycle_end
    
    ldr r1, =blink_rate         @ count down blink_rate (delay between blinks)
    ldr r0, [r1]
    subs r0, r0, #1
    str r0, [r1]                @ store the decrement count
    cmp r0, #0              
    bgt cycle_end               @ while >0 go to cycle_end
 
    ldr r2, =cycle_to_toggle    @ load cycle_to_toggle value
    ldr r3, [r2]
    cmp r3, #0                  @ check if cycle_to_toggle is positive
    it gt                       
    bgt toggle_on               @ jump to toggle_on if positive
    ble toggle_off              @ jump to toggle_off if negative or zero

toggle_on:
    ldr r1, =LEDaddress
    ldr r1, [r1]
    ldr r0, [r1]
    orr r0, r0, #0xFF00         @ turn on all LEDs
    strh r0, [r1]

    b update_toggle

toggle_off:
    ldr r1, =LEDaddress
    ldr r1, [r1]
    ldr r0, [r1]
    and r0, r0, #0x00FF         @ turn off all LEDs
    strh r0, [r1]

update_toggle:
    ldr r2, =cycle_to_toggle    @ load cycle_to_toggle value
    ldr r3, [r2]
    negs r3, r3                 @ negate the cycle_to_toggle value
    str r3, [r2]                @ store it back

    @ reset our blink_rate to its initial value
    ldr r1, =blink_rate              
    ldr r2, =initial_blink_rate
    ldr r2, [r2]
    str r2, [r1]
       
cycle_end:
    
    pop {r4-r7,lr}
    bx lr

.size _mk_a5_tick_handler, .-_mk_a5_tick_handler @@ - symbol size (not strictly required, but makes the debugger happy)



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