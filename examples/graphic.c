void app() {
  for (int step = 0; step < 1000; ++step) {
    for (int y = 0; y < 1080; ++y)
      for (int x = 0; x < 1920; ++x)
        mozartVMPutPixel(x, y, 0xFF000000 + x * y * step);
    mozartVMFlush();
  }
}