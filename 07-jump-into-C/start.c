char* VIDEO_ADDRESS = (char *) 0xb8000;

void c_start() {
    VIDEO_ADDRESS[0] = 0x4f;
    VIDEO_ADDRESS[1] = 0x0e;
    VIDEO_ADDRESS[2] = 0x4b;
    VIDEO_ADDRESS[3] = 0x0e;

    // loop forever
    while (1) {
    }
}
