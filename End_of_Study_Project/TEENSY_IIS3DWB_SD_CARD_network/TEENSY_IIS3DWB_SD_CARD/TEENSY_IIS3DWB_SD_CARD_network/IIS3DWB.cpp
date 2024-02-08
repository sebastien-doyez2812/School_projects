
#include "IIS3DWB.h"
#include <SPI.h>

#define IIS3DWB_SPI_MODE SPI_MODE0
#define IIS3DWB_SPI_CLOCK 10000000

IIS3DWB::IIS3DWB(uint8_t cspin)
  : _cs(cspin)
{ }


uint8_t IIS3DWB::getChipID()
{
  uint8_t temp = readByte(IIS3DWB_WHO_AM_I);
  return temp;
}


void IIS3DWB::sleep()
{
  uint8_t temp = readByte(IIS3DWB_CTRL1_XL);
  writeByte(IIS3DWB_CTRL1_XL, temp & ~(0xA0));
}


void IIS3DWB::wake()
{
  uint8_t temp = readByte(IIS3DWB_CTRL1_XL);
  writeByte(IIS3DWB_CTRL1_XL, temp | 0xA0 );
}


float IIS3DWB::getAres(uint8_t Ascale) {
  
  if ((Ascale != AFS_2G) && (Ascale != AFS_4G)  && (Ascale != AFS_8G) && (Ascale != AFS_16G)) {_aRes = 2.0f / 32768.0f; return _aRes;}
  else {
  switch (Ascale)
  {
    case AFS_2G:
      _aRes = 2.0f / 32768.0f;
      return _aRes;
      break;
    case AFS_4G:
      _aRes = 4.0f / 32768.0f;
      return _aRes;
      break;
    case AFS_8G:
      _aRes = 8.0f / 32768.0f;
      return _aRes;
      break;
    case AFS_16G:
      _aRes = 16.0f / 32768.0f;
      return _aRes;
      break;
  }
  }
}


void IIS3DWB::reset()
{
  writeByte(IIS3DWB_CTRL1_XL, 0x00);
  uint8_t temp = readByte(IIS3DWB_CTRL3_C);
  writeByte(IIS3DWB_CTRL3_C, temp | 0x01);
  delay(1);
}


uint8_t IIS3DWB::DRstatus()
{
  uint8_t temp = readByte(IIS3DWB_STATUS_REG);
  return temp;
}


uint8_t IIS3DWB::ACTstatus()
{
  uint8_t temp = readByte(IIS3DWB_ALL_INT_SRC);
  return temp;
}

 
void IIS3DWB::init(uint8_t Ascale)
{
  writeByte(IIS3DWB_INT1_CTRL, 0x01);
  writeByte(IIS3DWB_COUNTER_BDR_REG1, 0x80);  
  writeByte(IIS3DWB_CTRL3_C, 0x40 | 0x04);
  writeByte(IIS3DWB_CTRL4_C, 0x08 | 0x04);
  writeByte(IIS3DWB_CTRL1_XL, 0xA0 | Ascale << 2);
  writeByte(IIS3DWB_CTRL8_XL, 0xEC);
  writeByte(IIS3DWB_WAKE_UP_DUR, 0x08);
  writeByte(IIS3DWB_WAKE_UP_THS, 0x02);
  writeByte(IIS3DWB_SLOPE_EN, 0x20);     
  writeByte(IIS3DWB_INTERRUPTS_EN, 0x80);
  writeByte(IIS3DWB_MD2_CFG, 0x80);
}


void IIS3DWB::initFIFO(uint16_t fifo_size, uint8_t fifo_mode)
{
  writeByte(IIS3DWB_FIFO_CTRL1, (fifo_size & 0x00FF));
  writeByte(IIS3DWB_FIFO_CTRL2, 0x80 | (fifo_size & 0x0100) >> 8);
  writeByte(IIS3DWB_FIFO_CTRL3, 0x0A);
  writeByte(IIS3DWB_FIFO_CTRL4, fifo_mode);
  writeByte(IIS3DWB_INT1_CTRL, 0x08);
}


void IIS3DWB::offsetBias(float * destination)
{
  int16_t temp[3] = {0, 0, 0};
  int32_t sum[3] = {0, 0, 0};

  for (uint8_t ii = 0; ii < 128; ii++)
  {
    readAccelData(temp);
    sum[0] += temp[0];
    sum[1] += temp[1];
    sum[2] += temp[2];
    delay(10);
  }

  destination[0] = sum[0] * _aRes / 128.0f;
  destination[1] = sum[1] * _aRes / 128.0f;
  destination[2] = sum[2] * _aRes / 128.0f;

  if (destination[0] > 0.75f)  {
    destination[0] -= 1.0f;
  }
  if (destination[0] < -0.75f) {
    destination[0] += 1.0f;
  }
  if (destination[1] > 0.75f)  {
    destination[1] -= 1.0f;
  }
  if (destination[1] < -0.75f) {
    destination[1] += 1.0f;
  }
  if (destination[2] > 0.75f)  {
    destination[2] -= 1.0f;
  }
  if (destination[2] < -0.75f) {
    destination[2] += 1.0f;
  }
}


void IIS3DWB::readAccelData(int16_t * destination)
{
  uint8_t rawData[6];
  readBytes(IIS3DWB_OUTX_L_XL, 6, &rawData[0]);
  destination[0] = (int16_t)(((int16_t)rawData[1] << 8)  | rawData[0]) ;
  destination[1] = (int16_t)(((int16_t)rawData[3] << 8)  | rawData[2]) ;
  destination[2] = (int16_t)(((int16_t)rawData[5] << 8)  | rawData[4]) ;
}


int16_t IIS3DWB::readTempData()
{
  uint8_t rawData[2];
  readBytes(IIS3DWB_OUT_TEMP_L, 2, &rawData[0]);
  int16_t temp = (int16_t)((int16_t)rawData[1] << 8)  | rawData[0] ;
  return temp;
}


uint8_t IIS3DWB::readByte(uint8_t reg) 
{
  SPI.beginTransaction(SPISettings(IIS3DWB_SPI_CLOCK, MSBFIRST, IIS3DWB_SPI_MODE));
  digitalWrite(_cs, LOW); 
  SPI.transfer((reg & 0x7F) | 0x80);
  uint8_t temp = SPI.transfer(0);
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
  return temp;
}


void IIS3DWB::readBytes(uint8_t reg, uint8_t count, uint8_t * dest) 
{
  SPI.beginTransaction(SPISettings(IIS3DWB_SPI_CLOCK, MSBFIRST, IIS3DWB_SPI_MODE));
  digitalWrite(_cs, LOW);
  SPI.transfer((reg & 0x7F) | 0x80);
  SPI.transfer(dest, count);
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
}


void IIS3DWB::writeByte(uint8_t reg, uint8_t value) 
{
  SPI.beginTransaction(SPISettings(IIS3DWB_SPI_CLOCK, MSBFIRST, IIS3DWB_SPI_MODE));
  digitalWrite(_cs, LOW); 
  SPI.transfer(reg & 0x7F);
  SPI.transfer(value);
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
}

