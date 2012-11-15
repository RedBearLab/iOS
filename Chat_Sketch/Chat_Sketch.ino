
#include <Arduino.h>
#include <SPI.h>
#include "ble.h"

void setup()
{
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();
  
  ble_begin();
  
  Serial.begin(57600);
}

unsigned char buf[16] = {0};
unsigned char len = 0;

void loop()
{
  while ( ble_available() )
    Serial.write(ble_read());

  while ( Serial.available() )
  {
    unsigned char c = Serial.read();
    if (c != 0xD)
    {
      if (len < 16)
        buf[len++] = c;
    }
    else
    {
      for (int i = 0; i < len; i++)
        ble_write(buf[i]);
      len = 0;
    }
  }
  
  ble_do_events();
}

