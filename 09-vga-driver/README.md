# VAG Driver
In this section we will do something which is a little bit more rewarding. We will
implement a _VGA display driver_ so that we can easily print to the screen.


## Add `vga_print`
Having to print each character separately is very tedious. Hence, we add another function
to the driver which allows us to print a whole message.

## Implement `vga_new_line`.
TODO

# Conclusion
We have implemented a very basic vga driver. It is so simple that it is almost not worthy
of being called a driver. But, that doesn't matter! We are able to easily print messages
to the screen which will help us tremendously from now on.

We will eventually visit the vga driver again and improve it. As a primer, you may have
noticed that the _cursor_ is located somewhere in the scree and blinking. In a future
session, we might explore how to use the cursor.

