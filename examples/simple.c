void app() {
    while (1) {
        for (int y = 0; y < 1000; ++y)
            for (int x = 0; x < 1000; ++x)
                mozartVMPutPixel(x, y, 0x000000FF + x + y);
        mozartVMFlush();
    }
}