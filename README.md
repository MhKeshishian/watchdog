# a05-watchdogs-MhKeshishian

The project leverages memory interaction to directly control LEDs, utilizes the watchdog feature for system monitoring, and incorporates a button as an interrupt.

The code structure includes major tasks, such as initializing and starting the watchdog, achieved through an assembly function called _xx_watchdog_start. The duration of the watchdog timer is configurable, allowing for experimentation with prescaler and reload values.

By utilizing direct memory access and the system tick timer, all eight LEDs are continuously blinked on and off simultaneously. The watchdog is appropriately refreshed as long as the user button remains unpressed.

Once the button is pressed, the watchdog is no longer refreshed, but the LED blinking continues. With a properly configured watchdog, the system will automatically reboot after the watchdog timer expires.

The project offers flexibility, as the user can execute the blinking light demo with a specified timeout duration and delay time in milliseconds, controlled through a command provided to the board.

This project emphasizes the use of interrupts for the user button, ensuring efficient and responsive functionality.
