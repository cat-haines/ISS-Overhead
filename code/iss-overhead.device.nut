// constants for using SPI to emulate 1-wire
const BYTESPERPIXEL = 27;
const BYTESPERCOLOR = 9; // BYTESPERPIXEL / 3
const SPICLK = 7500; // SPI clock speed in kHz
const NUMPIXELS = 8;

bits <- [
    "\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0",
    "\xE0\x70\x38\x1C\x0E\x07\x03\x81\xF8",
    "\xE0\x70\x38\x1C\x0E\x07\x03\xF1\xC0",
    "\xE0\x70\x38\x1C\x0E\x07\x03\xF1\xF8",
    "\xE0\x70\x38\x1C\x0E\x07\xE3\x81\xC0",
    "\xE0\x70\x38\x1C\x0E\x07\xE3\x81\xF8",
    "\xE0\x70\x38\x1C\x0E\x07\xE3\xF1\xC0",
    "\xE0\x70\x38\x1C\x0E\x07\xE3\xF1\xF8",
    "\xE0\x70\x38\x1C\x0F\xC7\x03\x81\xC0",
    "\xE0\x70\x38\x1C\x0F\xC7\x03\x81\xF8",
    "\xE0\x70\x38\x1C\x0F\xC7\x03\xF1\xC0",
    "\xE0\x70\x38\x1C\x0F\xC7\x03\xF1\xF8",
    "\xE0\x70\x38\x1C\x0F\xC7\xE3\x81\xC0",
    "\xE0\x70\x38\x1C\x0F\xC7\xE3\x81\xF8",
    "\xE0\x70\x38\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xE0\x70\x38\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xE0\x70\x38\x1F\x8E\x07\x03\x81\xC0",
    "\xE0\x70\x38\x1F\x8E\x07\x03\x81\xF8",
    "\xE0\x70\x38\x1F\x8E\x07\x03\xF1\xC0",
    "\xE0\x70\x38\x1F\x8E\x07\x03\xF1\xF8",
    "\xE0\x70\x38\x1F\x8E\x07\xE3\x81\xC0",
    "\xE0\x70\x38\x1F\x8E\x07\xE3\x81\xF8",
    "\xE0\x70\x38\x1F\x8E\x07\xE3\xF1\xC0",
    "\xE0\x70\x38\x1F\x8E\x07\xE3\xF1\xF8",
    "\xE0\x70\x38\x1F\x8F\xC7\x03\x81\xC0",
    "\xE0\x70\x38\x1F\x8F\xC7\x03\x81\xF8",
    "\xE0\x70\x38\x1F\x8F\xC7\x03\xF1\xC0",
    "\xE0\x70\x38\x1F\x8F\xC7\x03\xF1\xF8",
    "\xE0\x70\x38\x1F\x8F\xC7\xE3\x81\xC0",
    "\xE0\x70\x38\x1F\x8F\xC7\xE3\x81\xF8",
    "\xE0\x70\x38\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xE0\x70\x38\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xE0\x70\x3F\x1C\x0E\x07\x03\x81\xC0",
    "\xE0\x70\x3F\x1C\x0E\x07\x03\x81\xF8",
    "\xE0\x70\x3F\x1C\x0E\x07\x03\xF1\xC0",
    "\xE0\x70\x3F\x1C\x0E\x07\x03\xF1\xF8",
    "\xE0\x70\x3F\x1C\x0E\x07\xE3\x81\xC0",
    "\xE0\x70\x3F\x1C\x0E\x07\xE3\x81\xF8",
    "\xE0\x70\x3F\x1C\x0E\x07\xE3\xF1\xC0",
    "\xE0\x70\x3F\x1C\x0E\x07\xE3\xF1\xF8",
    "\xE0\x70\x3F\x1C\x0F\xC7\x03\x81\xC0",
    "\xE0\x70\x3F\x1C\x0F\xC7\x03\x81\xF8",
    "\xE0\x70\x3F\x1C\x0F\xC7\x03\xF1\xC0",
    "\xE0\x70\x3F\x1C\x0F\xC7\x03\xF1\xF8",
    "\xE0\x70\x3F\x1C\x0F\xC7\xE3\x81\xC0",
    "\xE0\x70\x3F\x1C\x0F\xC7\xE3\x81\xF8",
    "\xE0\x70\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xE0\x70\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xE0\x70\x3F\x1F\x8E\x07\x03\x81\xC0",
    "\xE0\x70\x3F\x1F\x8E\x07\x03\x81\xF8",
    "\xE0\x70\x3F\x1F\x8E\x07\x03\xF1\xC0",
    "\xE0\x70\x3F\x1F\x8E\x07\x03\xF1\xF8",
    "\xE0\x70\x3F\x1F\x8E\x07\xE3\x81\xC0",
    "\xE0\x70\x3F\x1F\x8E\x07\xE3\x81\xF8",
    "\xE0\x70\x3F\x1F\x8E\x07\xE3\xF1\xC0",
    "\xE0\x70\x3F\x1F\x8E\x07\xE3\xF1\xF8",
    "\xE0\x70\x3F\x1F\x8F\xC7\x03\x81\xC0",
    "\xE0\x70\x3F\x1F\x8F\xC7\x03\x81\xF8",
    "\xE0\x70\x3F\x1F\x8F\xC7\x03\xF1\xC0",
    "\xE0\x70\x3F\x1F\x8F\xC7\x03\xF1\xF8",
    "\xE0\x70\x3F\x1F\x8F\xC7\xE3\x81\xC0",
    "\xE0\x70\x3F\x1F\x8F\xC7\xE3\x81\xF8",
    "\xE0\x70\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xE0\x70\x3F\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xE0\x7E\x38\x1C\x0E\x07\x03\x81\xC0",
    "\xE0\x7E\x38\x1C\x0E\x07\x03\x81\xF8",
    "\xE0\x7E\x38\x1C\x0E\x07\x03\xF1\xC0",
    "\xE0\x7E\x38\x1C\x0E\x07\x03\xF1\xF8",
    "\xE0\x7E\x38\x1C\x0E\x07\xE3\x81\xC0",
    "\xE0\x7E\x38\x1C\x0E\x07\xE3\x81\xF8",
    "\xE0\x7E\x38\x1C\x0E\x07\xE3\xF1\xC0",
    "\xE0\x7E\x38\x1C\x0E\x07\xE3\xF1\xF8",
    "\xE0\x7E\x38\x1C\x0F\xC7\x03\x81\xC0",
    "\xE0\x7E\x38\x1C\x0F\xC7\x03\x81\xF8",
    "\xE0\x7E\x38\x1C\x0F\xC7\x03\xF1\xC0",
    "\xE0\x7E\x38\x1C\x0F\xC7\x03\xF1\xF8",
    "\xE0\x7E\x38\x1C\x0F\xC7\xE3\x81\xC0",
    "\xE0\x7E\x38\x1C\x0F\xC7\xE3\x81\xF8",
    "\xE0\x7E\x38\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xE0\x7E\x38\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xE0\x7E\x38\x1F\x8E\x07\x03\x81\xC0",
    "\xE0\x7E\x38\x1F\x8E\x07\x03\x81\xF8",
    "\xE0\x7E\x38\x1F\x8E\x07\x03\xF1\xC0",
    "\xE0\x7E\x38\x1F\x8E\x07\x03\xF1\xF8",
    "\xE0\x7E\x38\x1F\x8E\x07\xE3\x81\xC0",
    "\xE0\x7E\x38\x1F\x8E\x07\xE3\x81\xF8",
    "\xE0\x7E\x38\x1F\x8E\x07\xE3\xF1\xC0",
    "\xE0\x7E\x38\x1F\x8E\x07\xE3\xF1\xF8",
    "\xE0\x7E\x38\x1F\x8F\xC7\x03\x81\xC0",
    "\xE0\x7E\x38\x1F\x8F\xC7\x03\x81\xF8",
    "\xE0\x7E\x38\x1F\x8F\xC7\x03\xF1\xC0",
    "\xE0\x7E\x38\x1F\x8F\xC7\x03\xF1\xF8",
    "\xE0\x7E\x38\x1F\x8F\xC7\xE3\x81\xC0",
    "\xE0\x7E\x38\x1F\x8F\xC7\xE3\x81\xF8",
    "\xE0\x7E\x38\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xE0\x7E\x38\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xE0\x7E\x3F\x1C\x0E\x07\x03\x81\xC0",
    "\xE0\x7E\x3F\x1C\x0E\x07\x03\x81\xF8",
    "\xE0\x7E\x3F\x1C\x0E\x07\x03\xF1\xC0",
    "\xE0\x7E\x3F\x1C\x0E\x07\x03\xF1\xF8",
    "\xE0\x7E\x3F\x1C\x0E\x07\xE3\x81\xC0",
    "\xE0\x7E\x3F\x1C\x0E\x07\xE3\x81\xF8",
    "\xE0\x7E\x3F\x1C\x0E\x07\xE3\xF1\xC0",
    "\xE0\x7E\x3F\x1C\x0E\x07\xE3\xF1\xF8",
    "\xE0\x7E\x3F\x1C\x0F\xC7\x03\x81\xC0",
    "\xE0\x7E\x3F\x1C\x0F\xC7\x03\x81\xF8",
    "\xE0\x7E\x3F\x1C\x0F\xC7\x03\xF1\xC0",
    "\xE0\x7E\x3F\x1C\x0F\xC7\x03\xF1\xF8",
    "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\x81\xC0",
    "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\x81\xF8",
    "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xE0\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xE0\x7E\x3F\x1F\x8E\x07\x03\x81\xC0",
    "\xE0\x7E\x3F\x1F\x8E\x07\x03\x81\xF8",
    "\xE0\x7E\x3F\x1F\x8E\x07\x03\xF1\xC0",
    "\xE0\x7E\x3F\x1F\x8E\x07\x03\xF1\xF8",
    "\xE0\x7E\x3F\x1F\x8E\x07\xE3\x81\xC0",
    "\xE0\x7E\x3F\x1F\x8E\x07\xE3\x81\xF8",
    "\xE0\x7E\x3F\x1F\x8E\x07\xE3\xF1\xC0",
    "\xE0\x7E\x3F\x1F\x8E\x07\xE3\xF1\xF8",
    "\xE0\x7E\x3F\x1F\x8F\xC7\x03\x81\xC0",
    "\xE0\x7E\x3F\x1F\x8F\xC7\x03\x81\xF8",
    "\xE0\x7E\x3F\x1F\x8F\xC7\x03\xF1\xC0",
    "\xE0\x7E\x3F\x1F\x8F\xC7\x03\xF1\xF8",
    "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\x81\xC0",
    "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\x81\xF8",
    "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xE0\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xFC\x70\x38\x1C\x0E\x07\x03\x81\xC0",
    "\xFC\x70\x38\x1C\x0E\x07\x03\x81\xF8",
    "\xFC\x70\x38\x1C\x0E\x07\x03\xF1\xC0",
    "\xFC\x70\x38\x1C\x0E\x07\x03\xF1\xF8",
    "\xFC\x70\x38\x1C\x0E\x07\xE3\x81\xC0",
    "\xFC\x70\x38\x1C\x0E\x07\xE3\x81\xF8",
    "\xFC\x70\x38\x1C\x0E\x07\xE3\xF1\xC0",
    "\xFC\x70\x38\x1C\x0E\x07\xE3\xF1\xF8",
    "\xFC\x70\x38\x1C\x0F\xC7\x03\x81\xC0",
    "\xFC\x70\x38\x1C\x0F\xC7\x03\x81\xF8",
    "\xFC\x70\x38\x1C\x0F\xC7\x03\xF1\xC0",
    "\xFC\x70\x38\x1C\x0F\xC7\x03\xF1\xF8",
    "\xFC\x70\x38\x1C\x0F\xC7\xE3\x81\xC0",
    "\xFC\x70\x38\x1C\x0F\xC7\xE3\x81\xF8",
    "\xFC\x70\x38\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xFC\x70\x38\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xFC\x70\x38\x1F\x8E\x07\x03\x81\xC0",
    "\xFC\x70\x38\x1F\x8E\x07\x03\x81\xF8",
    "\xFC\x70\x38\x1F\x8E\x07\x03\xF1\xC0",
    "\xFC\x70\x38\x1F\x8E\x07\x03\xF1\xF8",
    "\xFC\x70\x38\x1F\x8E\x07\xE3\x81\xC0",
    "\xFC\x70\x38\x1F\x8E\x07\xE3\x81\xF8",
    "\xFC\x70\x38\x1F\x8E\x07\xE3\xF1\xC0",
    "\xFC\x70\x38\x1F\x8E\x07\xE3\xF1\xF8",
    "\xFC\x70\x38\x1F\x8F\xC7\x03\x81\xC0",
    "\xFC\x70\x38\x1F\x8F\xC7\x03\x81\xF8",
    "\xFC\x70\x38\x1F\x8F\xC7\x03\xF1\xC0",
    "\xFC\x70\x38\x1F\x8F\xC7\x03\xF1\xF8",
    "\xFC\x70\x38\x1F\x8F\xC7\xE3\x81\xC0",
    "\xFC\x70\x38\x1F\x8F\xC7\xE3\x81\xF8",
    "\xFC\x70\x38\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xFC\x70\x38\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xFC\x70\x3F\x1C\x0E\x07\x03\x81\xC0",
    "\xFC\x70\x3F\x1C\x0E\x07\x03\x81\xF8",
    "\xFC\x70\x3F\x1C\x0E\x07\x03\xF1\xC0",
    "\xFC\x70\x3F\x1C\x0E\x07\x03\xF1\xF8",
    "\xFC\x70\x3F\x1C\x0E\x07\xE3\x81\xC0",
    "\xFC\x70\x3F\x1C\x0E\x07\xE3\x81\xF8",
    "\xFC\x70\x3F\x1C\x0E\x07\xE3\xF1\xC0",
    "\xFC\x70\x3F\x1C\x0E\x07\xE3\xF1\xF8",
    "\xFC\x70\x3F\x1C\x0F\xC7\x03\x81\xC0",
    "\xFC\x70\x3F\x1C\x0F\xC7\x03\x81\xF8",
    "\xFC\x70\x3F\x1C\x0F\xC7\x03\xF1\xC0",
    "\xFC\x70\x3F\x1C\x0F\xC7\x03\xF1\xF8",
    "\xFC\x70\x3F\x1C\x0F\xC7\xE3\x81\xC0",
    "\xFC\x70\x3F\x1C\x0F\xC7\xE3\x81\xF8",
    "\xFC\x70\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xFC\x70\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xFC\x70\x3F\x1F\x8E\x07\x03\x81\xC0",
    "\xFC\x70\x3F\x1F\x8E\x07\x03\x81\xF8",
    "\xFC\x70\x3F\x1F\x8E\x07\x03\xF1\xC0",
    "\xFC\x70\x3F\x1F\x8E\x07\x03\xF1\xF8",
    "\xFC\x70\x3F\x1F\x8E\x07\xE3\x81\xC0",
    "\xFC\x70\x3F\x1F\x8E\x07\xE3\x81\xF8",
    "\xFC\x70\x3F\x1F\x8E\x07\xE3\xF1\xC0",
    "\xFC\x70\x3F\x1F\x8E\x07\xE3\xF1\xF8",
    "\xFC\x70\x3F\x1F\x8F\xC7\x03\x81\xC0",
    "\xFC\x70\x3F\x1F\x8F\xC7\x03\x81\xF8",
    "\xFC\x70\x3F\x1F\x8F\xC7\x03\xF1\xC0",
    "\xFC\x70\x3F\x1F\x8F\xC7\x03\xF1\xF8",
    "\xFC\x70\x3F\x1F\x8F\xC7\xE3\x81\xC0",
    "\xFC\x70\x3F\x1F\x8F\xC7\xE3\x81\xF8",
    "\xFC\x70\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xFC\x70\x3F\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xFC\x7E\x38\x1C\x0E\x07\x03\x81\xC0",
    "\xFC\x7E\x38\x1C\x0E\x07\x03\x81\xF8",
    "\xFC\x7E\x38\x1C\x0E\x07\x03\xF1\xC0",
    "\xFC\x7E\x38\x1C\x0E\x07\x03\xF1\xF8",
    "\xFC\x7E\x38\x1C\x0E\x07\xE3\x81\xC0",
    "\xFC\x7E\x38\x1C\x0E\x07\xE3\x81\xF8",
    "\xFC\x7E\x38\x1C\x0E\x07\xE3\xF1\xC0",
    "\xFC\x7E\x38\x1C\x0E\x07\xE3\xF1\xF8",
    "\xFC\x7E\x38\x1C\x0F\xC7\x03\x81\xC0",
    "\xFC\x7E\x38\x1C\x0F\xC7\x03\x81\xF8",
    "\xFC\x7E\x38\x1C\x0F\xC7\x03\xF1\xC0",
    "\xFC\x7E\x38\x1C\x0F\xC7\x03\xF1\xF8",
    "\xFC\x7E\x38\x1C\x0F\xC7\xE3\x81\xC0",
    "\xFC\x7E\x38\x1C\x0F\xC7\xE3\x81\xF8",
    "\xFC\x7E\x38\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xFC\x7E\x38\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xFC\x7E\x38\x1F\x8E\x07\x03\x81\xC0",
    "\xFC\x7E\x38\x1F\x8E\x07\x03\x81\xF8",
    "\xFC\x7E\x38\x1F\x8E\x07\x03\xF1\xC0",
    "\xFC\x7E\x38\x1F\x8E\x07\x03\xF1\xF8",
    "\xFC\x7E\x38\x1F\x8E\x07\xE3\x81\xC0",
    "\xFC\x7E\x38\x1F\x8E\x07\xE3\x81\xF8",
    "\xFC\x7E\x38\x1F\x8E\x07\xE3\xF1\xC0",
    "\xFC\x7E\x38\x1F\x8E\x07\xE3\xF1\xF8",
    "\xFC\x7E\x38\x1F\x8F\xC7\x03\x81\xC0",
    "\xFC\x7E\x38\x1F\x8F\xC7\x03\x81\xF8",
    "\xFC\x7E\x38\x1F\x8F\xC7\x03\xF1\xC0",
    "\xFC\x7E\x38\x1F\x8F\xC7\x03\xF1\xF8",
    "\xFC\x7E\x38\x1F\x8F\xC7\xE3\x81\xC0",
    "\xFC\x7E\x38\x1F\x8F\xC7\xE3\x81\xF8",
    "\xFC\x7E\x38\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xFC\x7E\x38\x1F\x8F\xC7\xE3\xF1\xF8",
    "\xFC\x7E\x3F\x1C\x0E\x07\x03\x81\xC0",
    "\xFC\x7E\x3F\x1C\x0E\x07\x03\x81\xF8",
    "\xFC\x7E\x3F\x1C\x0E\x07\x03\xF1\xC0",
    "\xFC\x7E\x3F\x1C\x0E\x07\x03\xF1\xF8",
    "\xFC\x7E\x3F\x1C\x0E\x07\xE3\x81\xC0",
    "\xFC\x7E\x3F\x1C\x0E\x07\xE3\x81\xF8",
    "\xFC\x7E\x3F\x1C\x0E\x07\xE3\xF1\xC0",
    "\xFC\x7E\x3F\x1C\x0E\x07\xE3\xF1\xF8",
    "\xFC\x7E\x3F\x1C\x0F\xC7\x03\x81\xC0",
    "\xFC\x7E\x3F\x1C\x0F\xC7\x03\x81\xF8",
    "\xFC\x7E\x3F\x1C\x0F\xC7\x03\xF1\xC0",
    "\xFC\x7E\x3F\x1C\x0F\xC7\x03\xF1\xF8",
    "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\x81\xC0",
    "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\x81\xF8",
    "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xC0",
    "\xFC\x7E\x3F\x1C\x0F\xC7\xE3\xF1\xF8",
    "\xFC\x7E\x3F\x1F\x8E\x07\x03\x81\xC0",
    "\xFC\x7E\x3F\x1F\x8E\x07\x03\x81\xF8",
    "\xFC\x7E\x3F\x1F\x8E\x07\x03\xF1\xC0",
    "\xFC\x7E\x3F\x1F\x8E\x07\x03\xF1\xF8",
    "\xFC\x7E\x3F\x1F\x8E\x07\xE3\x81\xC0",
    "\xFC\x7E\x3F\x1F\x8E\x07\xE3\x81\xF8",
    "\xFC\x7E\x3F\x1F\x8E\x07\xE3\xF1\xC0",
    "\xFC\x7E\x3F\x1F\x8E\x07\xE3\xF1\xF8",
    "\xFC\x7E\x3F\x1F\x8F\xC7\x03\x81\xC0",
    "\xFC\x7E\x3F\x1F\x8F\xC7\x03\x81\xF8",
    "\xFC\x7E\x3F\x1F\x8F\xC7\x03\xF1\xC0",
    "\xFC\x7E\x3F\x1F\x8F\xC7\x03\xF1\xF8",
    "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\x81\xC0",
    "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\x81\xF8",
    "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xC0",
    "\xFC\x7E\x3F\x1F\x8F\xC7\xE3\xF1\xF8"
];
const clearString = "\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0\xE0\x70\x38\x1C\x0E\x07\x03\x81\xC0";

class NeoPixels {
    spi = null;
    frameSize = null;
    frame = null;

    // _spi - A configured spi (MSB_FIRST, 7.5MHz)
    // _frameSize - Number of Pixels per frame
    constructor(_spi, _frameSize) {
        this.spi = _spi;
        this.frameSize = _frameSize;
        this.frame = blob(frameSize*27 + 1);
        
        clearFrame();
        writeFrame();
    }

    // sets a pixel in the frame buffer
    // but does not write it to the pixel strip
    // color is an array of the form [r, g, b]
    function writePixel(p, color) {
        frame.seek(p*BYTESPERPIXEL);
        // red and green are swapped for some reason, so swizzle them back 
        frame.writestring(bits[color[1]]);
        frame.writestring(bits[color[0]]);
        frame.writestring(bits[color[2]]);    
    }
    
    // Clears the frame buffer
    // but does not write it to the pixel strip
    function clearFrame() {
        frame.seek(0);
        for (local p = 0; p < frameSize; p++) frame.writestring(clearString);
        frame.writen(0x00,'c');
    }
    
    function fillFrame(color) {
        // Get the color string
        local colorString = blob(BYTESPERPIXEL);

        colorString.writestring(bits[color[1].tointeger()]);
        colorString.writestring(bits[color[0].tointeger()]);
        colorString.writestring(bits[color[2].tointeger()]);

        frame.seek(0);
        for (local p = 0; p < frameSize; p++) frame.writestring(colorString.tostring());
        frame.writen(0x00,'c');
    }
    
    // writes the frame buffer to the pixel strip
    // ie - this function changes the pixel strip
    function writeFrame() {
        spi.write(frame);
    }
}

class NeoPixelFader {
    green = 0;
    red = 0;
    blue = 0;
    
    _pixels = null;
    lock = null;
    
    constructor(pixels) {
        this._pixels = pixels;
    }

    function set(r,g,b) {
        if (r > 255) r = 255;
        if (r < 0) r = 0;
        if (g > 255) g = 255;
        if (g < 0) g = 0;
        if (b > 255) b = 255;
        if (b < 0) b = 0;

        red = r;
        green = g;
        blue = b;
        
        _pixels.fillFrame([r.tointeger(),g.tointeger(),b.tointeger()]);
        _pixels.writeFrame();
    }
    
    function fadeTo(color, t, callback = null, fps = 30) {
        // check if we're already in a fade
        if (lock) return false;
        
        // set lock
        lock = true;
        
        // do some math to get parameters for fade()
        fps *= 1.0; // (convert fps to float)
        
        local wakeupTime = 1 / fps;
        local totalFrames = fps * t;
        
        local dR = (color[0] - red) / totalFrames;
        local dG = (color[1] - green) / totalFrames;
        local dB = (color[2] - blue) / totalFrames;

        fade(color, [dR, dG, dB], wakeupTime, totalFrames, 0, callback);
        return true;
    }
    
    function fade(targetColor, dColor, wakeupTime, totalFrames, currentFrame, callback) {
        if (!lock) return;
        
        this.set(red+dColor[0], green+dColor[1], blue+dColor[2]);
        currentFrame++;
        
        if (currentFrame >= totalFrames) {
            set(targetColor[0], targetColor[1], targetColor[2]);
            lock = false;
            if (callback) callback();
            return;
        }
        imp.wakeup(wakeupTime, function() { fade(targetColor, dColor, wakeupTime, totalFrames, currentFrame, callback) }.bindenv(this));
    }
}

function rnd(values, min = 0) {
    local r = ((math.rand() / 2147483647.0) * values) + min;
    return r;
}

spi <- hardware.spi257;
spi.configure(MSB_FIRST, SPICLK);
pixels <- NeoPixels(spi, NUMPIXELS);
fader <- NeoPixelFader(pixels);

overhead <- false;

function doOverhead() {
    if (overhead) {
        //if the iss is overhead, fade to another color
        fader.fadeTo([rnd(255), rnd(255), rnd(255)], 1.0, doOverhead);
    } else {
        // if it's no longer overhead, fade to off
        fader.fadeTo([0,0,0], 1.0);
        server.log("ISS is no longer overhead");
    }
}

agent.on("overhead", function(t) {
    // schedule 'notoverhead' event
    if (t != null) imp.wakeup(t, function() { overhead = false; });
    
    // set overhead flag, and start loop
    overhead = true;
    doOverhead();
    
    server.log("ISS is overhead!");
});

agent.on("notOverhead", function(t) {
    overhead = false;
});
