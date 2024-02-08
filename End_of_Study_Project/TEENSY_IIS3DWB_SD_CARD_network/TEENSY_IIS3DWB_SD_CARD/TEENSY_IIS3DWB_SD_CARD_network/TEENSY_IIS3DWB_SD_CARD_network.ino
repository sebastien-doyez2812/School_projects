#include <arm_const_structs.h>
#include "IIS3DWB.h"
#include "SPI.h"
#include <TimeLib.h>
#include <SD.h>

#define CSPIN           10
#define CS2_PIN         37

#define IIS3DWB_intPin1 8
#define IIS3DWB_intPin2 9

#define IIS3DWB_2_intPin1 8
#define IIS3DWB_2_intPin2 9

/////////////////////////////////////
//            VARIABLES            //
/////////////////////////////////////

const byte READ = 0b10000000; 

uint8_t c_1 = 0;
uint8_t c_2 = 0;

uint8_t eps = 100;
uint8_t _cs1 = 10, _mode1;
uint8_t _cs2 = 37, _mode2;

uint8_t reg, value;
uint8_t count;
uint8_t * dest;
uint8_t IIS3DWBstatus;
uint8_t Ascale = AFS_2G;

uint8_t flag_mem1 = 0;
uint8_t flag_mem2 = 0;

uint8_t again = 1;
uint8_t again2 = 1;

uint16_t frequency = 10000; // f = 10 kHz (Specification)
int16_t IIS3DWBData[4] = {0};

float memory_data1[3][5] = {
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0}
};

float memory_data2[3][5] = {
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0}
};


int32_t time_sent; 
int32_t time_sent2;

uint64_t id = 0;
uint64_t id2 = 0;

uint64_t temps_dep;

const int LED = 13;
const int chipSelect = BUILTIN_SDCARD;

float aRes = 1;
float aRes_2 = 1;
float aRes_3 = 1;

float   accelBias[3] = {0.0f, 0.0f, 0.0f};
float ax, ay, az, accelTemp;

volatile bool IIS3DWB_DataReady = false, IIS3DWB_Wakeup = false;

File myFile;

IIS3DWB IIS3DWB(CSPIN);

// Second sensor: 
IIS3DWB_2 IIS3DWB_2 (CS2_PIN);

void Lecture(uint8_t reg, uint8_t count, uint8_t * dest, uint8_t _cs);
void LectureAccelData(int16_t * destination);
void LectureBytes(uint8_t reg, uint8_t count, uint8_t * dest, uint8_t _cs);
void EcritureByte(uint8_t reg, uint8_t value, uint8_t _cs);

/////////////////////////////////////
//            FUNCTIONS            //
/////////////////////////////////////

void setup() 
{
  Serial.println("START SETUP");
  delay(2000);

  // Initialisation with the baudrate 2 000 000
  Serial.begin(2000000);
  while (!Serial) {;}

  // Initialisation of the SD card:
  Serial.println("INITIALISATION CARTE SD");  
  if (!SD.begin(chipSelect)) {
    Serial.println("INITIALISATION DEFAILLANTE");
    return;
  }
  Serial.println("INITIALISATION OK");
  delay(1000);

  // Initialisation of the SPI
  SPI.begin();
  pinMode(CSPIN, OUTPUT);
  pinMode(CS2_PIN, OUTPUT);

  digitalWrite(CSPIN, HIGH); 
  digitalWrite(CS2_PIN, HIGH);

  pinMode(IIS3DWB_intPin1, INPUT);
  pinMode(IIS3DWB_intPin2, INPUT);
  pinMode(IIS3DWB_2_intPin1, INPUT);
  pinMode(IIS3DWB_2_intPin2, INPUT);

  SPI.beginTransaction(SPISettings(10000000, MSBFIRST, SPI_MODE0)); // SPIsettings: the first parameter is the maximum of the frequency the SPI can use...
  // the second parameter is: is the data shifted on the most significant bit or on the least? ==> here 1 = MSB
  // The SPI_Mode0 : 
  //  Mode	   |   ClockPolarity (CPOL)	|   Clock Phase (CPHA)  |  	Output Edge	      |          Data Capture
 // SPI_MODE0	 |          0	            |          0	          |       Falling	      |            Rising


  // Test for the first sensor:
  Serial.println("Test Sensor 1:");
  while(again == 1)
  { 
    Serial.print("/");
    digitalWrite(CSPIN, LOW);

    delay(110);
    SPI.transfer((0x0F & 0x7F) | 0x80);   
    delay(110); 
    c_1 = SPI.transfer(0);
    if(c_1 == 0x7B) { again = 0; }
    digitalWrite(CSPIN, HIGH);

    delay(100);
  }
  digitalWrite(CSPIN, HIGH);
  SPI.endTransaction();    
  Serial.print("LECTURE DE L'IDENTIFIANT : ");  Serial.print(c_1); Serial.println(" "); delay(2000);
  Serial.print("IIS3DWB "); Serial.print("I AM "); Serial.print(c_1, HEX); Serial.print(" I should be "); Serial.println(0x7B, HEX);
  Serial.println(" ");

  if(c_1 == 0x7B)   
  {
    Serial.println("IIS3DWB n°1 is online...");
    digitalWrite(LED_BUILTIN, HIGH);

    // Sensor reset:
    IIS3DWB.reset(); 

    // Calculate the LSB: 
    aRes = IIS3DWB.getAres(Ascale); 
    
    Serial.print("aRes = ");  Serial.print(aRes * 1000000.0); Serial.print(" µg");
    Serial.println("");
    delay(1000);
   
    // Initialisation of the sensor:
    IIS3DWB.init(Ascale); 
  }
  else  {  if(c_1 != 0x6A) Serial.println(" IIS3DWB n°1 not functioning!");   while(1){};  }

  // Test of the sensor n°2:
  Serial.println("___________________________________________");
  Serial.println( "Test Sensor 2:");

  while(again2 == 1)
  { 
  Serial.print("/");
  digitalWrite(CS2_PIN, LOW);

  delay(110);
  SPI.transfer((0x0F & 0x7F) | 0x80);   
  delay(110); 
  c_2 = SPI.transfer(0);
  if(c_2 == 0x7B) { again2 = 0; }      
  digitalWrite(CS2_PIN, HIGH);

  delay(100);
  }
  digitalWrite(CS2_PIN, HIGH);
  SPI.endTransaction();    
  Serial.print("LECTURE DE L'IDENTIFIANT 2 : ");  Serial.print(c_2); Serial.println(" "); delay(2000);
  Serial.print("IIS3DWB "); Serial.print("I AM "); Serial.print(c_2, HEX); Serial.print(" I should be "); Serial.println(0x7B, HEX);
  Serial.println(" ");

  if(c_2 == 0x7B)   
  {
    Serial.println("IIS3DWB n°2 is online...");
    digitalWrite(LED_BUILTIN, HIGH);

    // Sensor reset:
    IIS3DWB_2.reset(); 

    // Calculate the LSB: 
    aRes_2 = IIS3DWB_2.getAres(Ascale); 
    
    Serial.print("aRes = ");  Serial.print(aRes_2 * 1000000.0); Serial.print(" µg");
    Serial.println("");
    delay(1000);
   
    // Initialisation of the sensor:
    IIS3DWB_2.init(Ascale); 

    // Need the time of beginning of the experience:
    temps_dep = micros();
  }
  else  {  if(c_2 != 0x6A) Serial.println(" IIS3DWB n°2 not functioning!");   while(1){};  }

  Serial.println(" All the sensors are ready...");
  Serial.println("");

  EcritureByte(IIS3DWB_CTRL1_XL, 0xA0 | AFS_4G << 2, _cs1);
  EcritureByte(IIS3DWB_CTRL3_C, 0x40 | 0x04, _cs1);

  EcritureByte(IIS3DWB_CTRL1_XL, 0xA0 | AFS_4G << 2, _cs2);
  EcritureByte(IIS3DWB_CTRL3_C, 0x40 | 0x04, _cs2);

  if(SD.exists("test.txt")) {
    Serial.println(F("Fichier test.txt OK"));
  }
  delay(1000);
  Serial.println("");
  Serial.println("START LOOP");

  SD.begin(chipSelect);
  delay(20);
  
  while(Serial.available() == 0){
    //File myFile = SD.open("test.txt", FILE_WRITE);
    for (int id = 0 ; id < 1000; id ++) {
      // Initialisation of the temp and accelNom:
      int16_t temp[3] = {0, 0, 0};
      int16_t temp_2[3] = {0,0,0};

      int16_t accelNom[3] = {0, 0, 0};
      int16_t accelNom_2[3] = {0, 0, 0};

      // Read the data from the IIS3DWB:
      LectureAccelData(temp, CSPIN);
      time_sent = micros() - temps_dep;

      LectureAccelData(temp_2, CS2_PIN);
      time_sent2 = micros() - temps_dep;

      long int b = micros();
      
      accelNom[0] = temp[0];
      accelNom[1] = temp[1];
      accelNom[2] = temp[2];

      accelNom_2[0] = temp_2[0];
      accelNom_2[1] = temp_2[1];
      accelNom_2[2] = temp_2[2];

      // Write the data into the SD card memory first:
      myFile.print(time_sent);
      myFile.print(" ");
      myFile.print((accelNom[0]) * aRes * 1000.0);
      myFile.print(" ");
      myFile.print((accelNom[1]) * aRes * 1000.0);
      myFile.print(" ");
      myFile.print((accelNom[2]) * aRes * 1000.0);
      myFile.print(" ");
      myFile.print(id);
      myFile.print(" ");
      myFile.print(time_sent2);
      myFile.print(" ");
      myFile.print((accelNom_2[0]) * aRes_2 * 1000.0);
      myFile.print(" ");
      myFile.print((accelNom_2[1]) * aRes_2 * 1000.0);
      myFile.print(" ");
      myFile.print((accelNom_2[2]) * aRes_2 * 1000.0);
      myFile.print(" ");
      myFile.println(id2);  
      // We need a Id:  
      
      Serial.print(time_sent);
      Serial.print(" ");
      Serial.print((accelNom[0]) * aRes * 1000.0);
      Serial.print(" ");
      Serial.print((accelNom[1]) * aRes * 1000.0);
      Serial.print(" ");
      Serial.print((accelNom[2]) * aRes * 1000.0);
      Serial.print(" ");
      Serial.print(id);
      Serial.print(" ");
      Serial.print(time_sent2);
      Serial.print(" ");
      Serial.print((accelNom_2[0]) * aRes_2 * 1000.0);
      Serial.print(" ");
      Serial.print((accelNom_2[1]) * aRes_2 * 1000.0);
      Serial.print(" ");
      Serial.print((accelNom_2[2]) * aRes_2 * 1000.0);
      Serial.print(" ");
      Serial.println(id2);

      delayMicroseconds(45);
    id2 =  id2 + 1;
    }
  }
  myFile.close();
  Serial.print("DONE");

}

void loop()
{ 
}

void LectureAccelData(int16_t * destination, uint8_t cs_pin)
{
  destination[0] = getValue(1, cs_pin);
  destination[1] = getValue(2, cs_pin);
  destination[2] = getValue(3, cs_pin);
}


int getValue(int axis, uint8_t cs_)
{
  int Val = 0;
  int h, l;
  if (axis == 1)
  {
    l = readRegister(IIS3DWB_OUTX_L_XL, cs_);
    h = readRegister(IIS3DWB_OUTX_H_XL, cs_);
  }
  else if (axis == 2)
  {
    l = readRegister(IIS3DWB_OUTY_L_XL, cs_);
    h = readRegister(IIS3DWB_OUTY_H_XL, cs_);
  }
  else if (axis == 3)
  {
    l = readRegister(IIS3DWB_OUTZ_L_XL, cs_);
    h = readRegister(IIS3DWB_OUTZ_H_XL, cs_);
  }

  //To get the full value, two bytes must be combined for each axis. That is why we shift eight bits left and set empty bits with l
  Val = ((h << 8) | l);

  return Val;
}

byte readRegister(byte thisRegister, uint8_t CS_PIN)
{
  byte result = 0;
  thisRegister = thisRegister ; //>> 1;             //address bit 1-7, shift right by 1
  byte dataToSend = thisRegister | READ;        //combine register address and command into one byte
  digitalWrite(CS_PIN, LOW);
  //address = (0x80 | address);
  SPI.transfer(dataToSend);
  //delay(1);
  result = SPI.transfer(0x00);
  //delay(1);
  digitalWrite(CS_PIN, HIGH);
  return result;
}

void EcritureByte(uint8_t reg, uint8_t value, uint8_t _cs) 
{
  SPI.beginTransaction(SPISettings(10000000, 1, SPI_MODE0));
  digitalWrite(_cs, LOW); 
  SPI.transfer(reg & 0x7F);
  SPI.transfer(value);
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
}

