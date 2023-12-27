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
    IIS3DWB.reset(); 

    // Calculate the LSB: 
    aRes_2 = IIS3DWB.getAres(Ascale); 
    
    Serial.print("aRes = ");  Serial.print(aRes_2 * 1000000.0); Serial.print(" µg");
    Serial.println("");
    delay(1000);
   
    // Initialisation of the sensor:
    IIS3DWB.init(Ascale); 

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


  Serial.println("");
  Serial.println("START LOOP");
  myFile = SD.open("test.txt");
  myFile.close();
  myFile = SD.open("test.txt");
}

void loop()
{ 
  // Initialisation of the temp and accelNom:
  int32_t temp[8]     = {0, 0, 0, 0, 0, 0, 0, 0};
  int32_t accelNom[8] = {0, 0, 0, 0, 0, 0, 0, 0};
  
  // Read the data from the IIS3DWB:
  LectureAccelData(temp);
  
  long int b = temp[6];
  long int c = temp[7];

  accelNom[0] = temp[0];
  accelNom[1] = temp[1];
  accelNom[2] = temp[2];
  accelNom[3] = temp[3];
  accelNom[4] = temp[4];
  accelNom[5] = temp[5];


  // Calculate how much time we needed for this data since the begining of the experience:
  time_sent  = int(b - temps_dep);
  time_sent2 = int(c - temps_dep);
  
  // Write the data into the SD card memory first:
  myFile.print(time_sent);
  myFile.print(" ");
  myFile.print((accelNom[0]) * aRes * 1000.0);
  myFile.print(" ");
  myFile.print((accelNom[1]) * aRes * 1000.0);
  myFile.print(" ");
  myFile.print((accelNom[2]) * aRes * 1000.0);
  myFile.println(" ");
  myFile.print(id);


  myFile.print(time_sent2);
  myFile.print(" ");
  myFile.print((accelNom[3]) * aRes * 1000.0);
  myFile.print(" ");
  myFile.print((accelNom[4]) * aRes * 1000.0);
  myFile.print(" ");
  myFile.print((accelNom[5]) * aRes * 1000.0);
  myFile.println(" ");
  myFile.print(id2);
  

  ////////////////////////////
  //        Tests           //
  //////////////////////////// 

  // Error code: 
  // 0 => All data are 0.
  // 1 => Too much delay.
  // 2 => It's always the same data.

  // Sensor n°1:

  if ((temp[0] == 0) && (temp[1] == 0) && (temp[2] == 0))
  // first test : if all the data == 0 => error
  // OR if all data is the exactly the same and the data memory is empty (flag_mem = 1)
  {
    Serial.print("ERROR SENSOR 1 OFFLINE 0 \t"); // All data at 0!
    
    Reset_IIS3DWB(1);
  }
  else if (flag_mem1 == 1 && ((time_sent - memory_data1[2][0]) > (1e6/frequency)+ eps)) 
  // Second test: how much delay we have between the previous and the actual data:
  // If it is more than 1/ frequency + epsilon, there is an error.
  { 
    Serial.print("ERROR SENSOR 1 OFFLINE 1 \t"); // Too much time!
    //Serial.print(time_sent - memory_data1[2][0]);
    
    // Reset the memory too... 
    flag_mem1 = 0;
    Serial.print("\t");
    
    // Reset the sensor:
    Reset_IIS3DWB(1);
    memory_data1[2][0] = micros();
  }
  else if (accelNom[0] * aRes * 1000.0 == memory_data1[2][1] &&
    memory_data1[2][1] == memory_data1[1][1]                  &&
    memory_data1[1][1] == memory_data1[0][1]                  &&
    accelNom[1] * aRes * 1000.0 == memory_data1[2][2]        &&
    memory_data1[2][2] == memory_data1[1][2]                  &&
    memory_data1[1][2] == memory_data1[0][2]                  &&
    accelNom[2] * aRes * 1000.0 == memory_data1[2][3]        &&
    memory_data1[2][3] == memory_data1[1][3]                  &&
    memory_data1[1][3] == memory_data1[0][3])
    // The lastest data are the same => the sensor seems to be blocked!
  {
    Serial.print("ERROR SENSOR 1 OFFLINE 2\t"); // 4 times the same data
    // Reset the sensor:
    Reset_IIS3DWB(1);
    memory_data1[2][0] = micros();
  }
  else
  {
    id = id + 1;
    // It seems OK: There are no error.
    Serial.print(" ");
    Serial.print(time_sent);
    Serial.print(" ");
    Serial.print((accelNom[0]) * aRes * 1000.0);
    Serial.print(" ");
    Serial.print((accelNom[1]) * aRes * 1000.0);
    Serial.print(" ");
    Serial.print((accelNom[2]) * aRes * 1000.0);
    Serial.print(" ");
    Serial.print(id);

    // Memory:
    // Keep access to the previous data: 
    for (int i = 0; i <2; i ++){
      for (int j = 0; j < 5; j ++)
      {
        memory_data1[i][j]= memory_data1[i+1][j];
      }
    }
    memory_data1[2][0] = time_sent;
    memory_data1[2][1] = (accelNom[0]) * aRes * 1000.0;
    memory_data1[2][2] = (accelNom[1]) * aRes * 1000.0;
    memory_data1[2][3] = (accelNom[2]) * aRes * 1000.0;
    memory_data1[2][4] = id;
    flag_mem1 = 1;
  }

  // Sensor n°2

  if ((temp[3] == 0) && (temp[4] == 0) && (temp[5] == 0))
  {
    Serial.println("\t ERROR SENSOR 2 OFFLINE 0 "); // All data at 0!
    
    Reset_IIS3DWB(2);
  }
  else if (flag_mem2 == 1 && ((time_sent - memory_data2[2][0]) > (1e6/frequency)+ eps)) 
  // Second test: how much delay we have between the previous and the actual data:
  // If it is more than 1/ frequency + epsilon, there is an error.
  { 
    Serial.print("ERROR SENSOR 2 OFFLINE 1 \t"); // Too much time!
    Serial.print(time_sent - memory_data2[2][0]);
    Serial.println("\t");
    
    // Reset the sensor:
    Reset_IIS3DWB(2);
    
    memory_data2[2][0] = micros();
  }

  else if (accelNom[3] * aRes * 1000.0 == memory_data2[2][1] &&
  memory_data2[2][1] == memory_data2[1][1]                  &&
  memory_data2[1][1] == memory_data2[0][1]                  &&
  accelNom[4] * aRes * 1000.0 == memory_data2[2][2]        &&
  memory_data2[2][2] == memory_data2[1][2]                  &&
  memory_data2[1][2] == memory_data2[0][2]                  &&
  accelNom[5] * aRes * 1000.0 == memory_data2[2][3]        &&
  memory_data2[2][3] == memory_data2[1][3]                  &&
  memory_data2[1][3] == memory_data2[0][3])
  // The lastest data are the same => the sensor seems to be blocked!
  {
    Serial.println("ERROR SENSOR 2 OFFLINE 2"); // 4 times the same data
    
    // Reset the sensor:
    Reset_IIS3DWB(2);
    
    memory_data2[2][0] = micros();
  }
  else {
    id2 = id2 + 1;
    // It seems OK: There are no error.

    
    Serial.print(" ");
    Serial.print(time_sent2);
    Serial.print(" ");
    Serial.print((accelNom[3]) * aRes * 1000.0);
    Serial.print(" ");
    Serial.print((accelNom[4]) * aRes * 1000.0);
    Serial.print(" ");
    Serial.print((accelNom[5]) * aRes * 1000.0);
    Serial.print(" ");
    Serial.print(id2);
    Serial.println(" ");
    

    // Memory:
    // Keep access to the previous data: 
    for (int i = 0; i <2; i ++){
      for (int j = 0; j < 5; j ++)
      {
        memory_data2[i][j]= memory_data2[i+1][j];
      }
    }
    memory_data2[2][0] = time_sent;
    memory_data2[2][1] = (accelNom[3]) * aRes * 1000.0;
    memory_data2[2][2] = (accelNom[4]) * aRes * 1000.0;
    memory_data2[2][3] = (accelNom[5]) * aRes * 1000.0;
    memory_data2[2][4] = id;
    flag_mem2 = 1;
  }

  // We need a frequency around 10 kHz:
  //delayMicroseconds(int(1e6/(3*frequency)));
}


void Reset_IIS3DWB(uint8_t id)
{
  // id = 1 => Reset the first sensors,
  // id = 2 => Reset the second one,
  // ...

  // Variables:
  uint8_t PIN;

  // Reset the right sensor:
  switch (id)
  {
    case 1: 
      PIN = CSPIN;
    case 2 : 
      PIN = CS2_PIN;
    default: 
      PIN = CSPIN;
  }

  // Initialisation with the baudrate 2 000 000
  Serial.begin(2000000);

  // Reset the SPI:
  SPI.begin();

  // Put the CS Pin in output mode:
  pinMode(PIN, OUTPUT);

  // Reset the IIS3DWB:
  digitalWrite(PIN, HIGH); 
  pinMode(IIS3DWB_intPin1, INPUT);
  pinMode(IIS3DWB_intPin2, INPUT);
  SPI.beginTransaction(SPISettings(10000000, MSBFIRST, SPI_MODE0)); 
  
  if(c_1 == 0x7B)   
  {
    digitalWrite(LED_BUILTIN, HIGH);
    digitalWrite(PIN, LOW);
    IIS3DWB.reset();  // RESET DE L'ACCELEROMETRE
    aRes = IIS3DWB.getAres(Ascale); // CALUL DU LSB
    delay(20);
    IIS3DWB.init(Ascale);
    digitalWrite(PIN, HIGH);
  }
  EcritureByte(IIS3DWB_CTRL1_XL, 0xA0 | AFS_4G << 2, _cs1);
  EcritureByte(IIS3DWB_CTRL3_C, 0x40 | 0x04, _cs1);
  delay(20);
}


void LectureAccelData(int32_t * destination)
{
  uint8_t rawData[6];
  uint8_t rawData2[6];   // x/y/z accel register data stored here

  uint32_t time1 = 0;
  uint32_t time2 = 0;
  LectureBytes(IIS3DWB_OUTX_L_XL, 6, &rawData[0],  CSPIN);  // Read the 6 raw accel data registers into data array
  time1 = micros();
  LectureBytes(IIS3DWB_OUTX_L_XL, 6, &rawData2[0], CS2_PIN);  // Read the 6 raw accel data registers into data array
  time2 = micros();
  destination[0] = (int16_t)(((int16_t)rawData[1] << 8)  | rawData[0]) ;  // Turn the MSB and LSB into a signed 16-bit value
  destination[1] = (int16_t)(((int16_t)rawData[3] << 8)  | rawData[2]) ;
  destination[2] = (int16_t)(((int16_t)rawData[5] << 8)  | rawData[4]) ;

  destination[3] = (int16_t)(((int16_t)rawData2[1] << 8)  | rawData2[0]) ;  // Turn the MSB and LSB into a signed 16-bit value
  destination[4] = (int16_t)(((int16_t)rawData2[3] << 8)  | rawData2[2]) ;
  destination[5] = (int16_t)(((int16_t)rawData2[5] << 8)  | rawData2[4]) ;

  destination[6] = time1;
  destination[7] = time2;
}


void LectureBytes(uint8_t reg, uint8_t count, uint8_t * dest, uint8_t _cs) 
{
  SPI.beginTransaction(SPISettings(10000000, 1, SPI_MODE0));
  digitalWrite(_cs, LOW);
  SPI.transfer((reg & 0x7F) | 0x80);
  delayMicroseconds(20);
  
  // MESURE
  SPI.transfer(dest, count);  
  
  //Serial.print(" "); Serial.print(now()); Serial.print(" ");
  delayMicroseconds(20);
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
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

void Lecture(uint8_t reg, uint8_t count, uint8_t * dest, uint8_t _cs) 
{
  // Start the SPI:
  SPI.beginTransaction(SPISettings(10000000, 1, SPI_MODE0));
  // Chip Select in Low
  digitalWrite(_cs, LOW);
  // reg & 0x7F | 0x80 = reg & 0x01111111 | 0x10000000
  SPI.transfer((reg & 0x7F) | 0x80); // 
  SPI.transfer(dest, count); // Data are transfered into the dest, count is the size of the data
  // Chip Select in High 
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
}