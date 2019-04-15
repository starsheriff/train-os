int* VIDEO_ADDRESS = (int*) 0xb8000;

void c_start() {
    int ok = 0x0e4b0e4f;
    *VIDEO_ADDRESS = ok;


    // loop forever
    while (1) {
    }

    return;
}
