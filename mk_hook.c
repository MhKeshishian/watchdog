/*
* C to assembler menu hook
*
*/
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "common.h"
#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"


// Function prototypes
int add_test(int x, int y);
void mes_InitIWDG(uint32_t reload);
void mes_IWDGStart(void);
void mes_IWDGRefresh(void);
void _mk_watchdog_start(uint32_t reload_value, uint32_t blink_rate);


//Constants  
#define DEFAULT_BLINK_RATE  500
#define DEFAULT_RESET_TIME  500

//Defining LEDs
#define LED6_PIN        GPIO_PIN_15
#define LED8_PIN        GPIO_PIN_14
#define LED10_PIN       GPIO_PIN_13
#define LED9_PIN        GPIO_PIN_12
#define LED7_PIN        GPIO_PIN_11
#define LED5_PIN        GPIO_PIN_10
#define LED3_PIN        GPIO_PIN_9
#define LED4_PIN        GPIO_PIN_8
#define GPIO_PIN_8      ((uint16_t)0x0100) /* Pin 8 selected */
#define GPIO_PIN_9      ((uint16_t)0x0200) /* Pin 9 selected */
#define GPIO_PIN_10     ((uint16_t)0x0400) /* Pin 10 selected */
#define GPIO_PIN_11     ((uint16_t)0x0800) /* Pin 11 selected */
#define GPIO_PIN_12     ((uint16_t)0x1000) /* Pin 12 selected */
#define GPIO_PIN_13     ((uint16_t)0x2000) /* Pin 13 selected */
#define GPIO_PIN_14     ((uint16_t)0x4000) /* Pin 14 selected */
#define GPIO_PIN_15     ((uint16_t)0x8000) /* Pin 15 selected */






void AddTest(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Addition Test\n\n"
"This command tests new addition function\n"
);
return;
}
printf("add_test returned: %d\n", add_test(99, 87) );
}
ADD_CMD("add", AddTest,"Test the new add function")
