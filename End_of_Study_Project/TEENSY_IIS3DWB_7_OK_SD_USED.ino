#include <arm_const_structs.h>
#include "IIS3DWB.h"
#include "SPI.h"
#include <TimeLib.h>
#include <SD.h>
#define CSPIN           10
#define IIS3DWB_intPin1 8
#define IIS3DWB_intPin2 9

/////////////////////////////////////
//            VARIABLES            //
/////////////////////////////////////

uint8_t c = 0;
uint8_t eps = 100;
uint8_t _cs = 10, _mode;
uint8_t reg, value;
uint8_t count;
uint8_t * dest;
uint8_t IIS3DWBstatus;
uint8_t Ascale = AFS_2G;
uint8_t flag_mem = 0;
uint8_t again = 1;

uint16_t frequency = 10000; // f = 10 kHz (Specification)
int16_t IIS3DWBData[4] = {0};

float memory_data[3][5] = {
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0}
};
int32_t time_sent; 

uint64_t id = 0;
uint64_t temps_dep;

const int LED = 13;
const int chipSelect = BUILTIN_SDCARD;

float aRes = 1;
float   accelBias[3] = {0.0f, 0.0f, 0.0f};
float ax, ay, az, accelTemp;

volatile bool IIS3DWB_DataReady = false, IIS3DWB_Wakeup = false;

File myFile;

IIS3DWB IIS3DWB(CSPIN);

void Lecture(uint8_t reg, uint8_t count, uint8_t * dest);
void LectureAccelData(int16_t * destination);
void LectureBytes(uint8_t reg, uint8_t count, uint8_t * dest);
void EcritureByte(uint8_t reg, uint8_t value);

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
  digitalWrite(CSPIN, HIGH); 
  pinMode(IIS3DWB_intPin1, INPUT);
  pinMode(IIS3DWB_intPin2, INPUT);
  SPI.beginTransaction(SPISettings(10000000, MSBFIRST, SPI_MODE0)); // SPIsettings: the first parameter is the maximum of the frequency the SPI can use...
  // the second parameter is: is the data shifted on the most significant bit or on the least? ==> here 1 = MSB
  // The SPI_Mode0 : 
  //  Mode	   |   ClockPolarity (CPOL)	|   Clock Phase (CPHA)  |  	Output Edge	      |          Data Capture
 // SPI_MODE0	 |          0	            |          0	          |       Falling	      |            Rising

  Serial.println("TEST ITERATIF DE L'IIS3DWB");
  while(again == 1)
  { 
  Serial.print("/");
  digitalWrite(CSPIN, LOW);
  delay(110);
  SPI.transfer((0x0F & 0x7F) | 0x80);   
  delay(110); 
  c = SPI.transfer(0);
  if(c == 0x7B) { again = 0; }
  digitalWrite(CSPIN, HIGH);
  delay(100);
  }

  digitalWrite(CSPIN, HIGH);
  SPI.endTransaction();    
  Serial.print("LECTURE DE L'IDENTIFIANT : ");  Serial.print(c); Serial.println(" "); delay(2000);
  Serial.print("IIS3DWB "); Serial.print("I AM "); Serial.print(c, HEX); Serial.print(" I should be "); Serial.println(0x7B, HEX);
  Serial.println(" ");

  if(c == 0x7B)   
  {
    Serial.println("IIS3DWB is online...");
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

    // Need the time of beginning of the experience:
    temps_dep = micros();
  }
  else  {  if(c != 0x6A) Serial.println(" IIS3DWB not functioning!");   while(1){};  }

  EcritureByte(IIS3DWB_CTRL1_XL, 0xA0 | AFS_4G << 2);
  EcritureByte(IIS3DWB_CTRL3_C, 0x40 | 0x04);
  Serial.println("");
  Serial.println("START LOOP");
  myFile = SD.open("test.txt");
  myFile.close();
  myFile = SD.open("test.txt");
}

void loop()
{ 
  // Initialisation of the temp and accelNom:
  int16_t temp[3] = {0, 0, 0};
  int16_t accelNom[3] = {0, 0, 0};
  
  // Read the data from the IIS3DWB:
  LectureAccelData(temp);
  long int b = micros();

  accelNom[0] = temp[0];
  accelNom[1] = temp[1];
  accelNom[2] = temp[2];

  // Calculate how much time we needed for this data since the begining of the experience:
  time_sent = int(b-temps_dep);
  
  // Write the data into the SD card memory first:
  myFile.print(time_sent);
  myFile.print(" ");
  myFile.print((accelNom[0]) * aRes * 1000.0);
  myFile.print(" ");
  myFile.print((accelNom[1]) * aRes * 1000.0);
  myFile.print(" ");
  myFile.print((accelNom[2]) * aRes * 1000.0);
  myFile.println(" ");

  // We need a Id:  
  myFile.print(id);
  

  ////////////////////////////
  //        Tests           //
  //////////////////////////// 

  // Error code: 
  // 0 => All data are 0.
  // 1 => Too much delay.
  // 2 => It's always the same data.

  if ((temp[0] == 0) && (temp[1] == 0) && (temp[2] == 0))
  // first test : if all the data == 0 => error
  // OR if all data is the exactly the same and the data memory is empty (flag_mem = 1)
  {
    Serial.println("SENSOR OFFLINE 0"); // All data at 0!
    delay(100);
    Reset_IIS3DWB();
  }
  else if (flag_mem == 1 && ((time_sent - memory_data[2][0]) > (1e6/frequency)+ eps)) 
  // Second test: how much delay we have between the previous and the actual data:
  // If it is more than 1/ frequency + epsilon, there is an error.
  { 
    Serial.print("SENSOR OFFLINE 1 "); // Too much time!
    Serial.println(time_sent - memory_data[2][0]);
    // Reset the sensor:
    Reset_IIS3DWB();
    memory_data[2][0] = micros();
  }
  else if (accelNom[0] * aRes * 1000.0 == memory_data[2][1] &&
    memory_data[2][1] == memory_data[1][1]                  &&
    memory_data[1][1] == memory_data[0][1]                  &&
    accelNom[1] * aRes * 1000.0 == memory_data[2][2]        &&
    memory_data[2][2] == memory_data[1][2]                  &&
    memory_data[1][2] == memory_data[0][2]                  &&
    accelNom[2] * aRes * 1000.0 == memory_data[2][3]        &&
    memory_data[2][3] == memory_data[1][3]                  &&
    memory_data[1][3] == memory_data[0][3])
    // The lastest data are the same => the sensor seems to be blocked!
  {
    Serial.println("SENSOR OFFLINE 2"); // 4 times the same data
    // Reset the sensor:
    Reset_IIS3DWB();
    memory_data[2][0] = micros();
  }
  else
  {
    // The next data will have the id[n+1] = id[n] +1
    // This will allow us to know if there are or not data missed
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
    Serial.println(" ");
  
    // Keep access to the previous data: 
    for (int i = 0; i <2; i ++){
      for (int j = 0; j < 5; j ++)
      {
        memory_data[i][j]= memory_data[i+1][j];
      }
    }
    memory_data[2][0] = time_sent;
    memory_data[2][1] = (accelNom[0]) * aRes * 1000.0;
    memory_data[2][2] = (accelNom[1]) * aRes * 1000.0;
    memory_data[2][3] = (accelNom[2]) * aRes * 1000.0;
    memory_data[2][4] = id;
  }

  flag_mem = 1;

  // We need a frequency around 10 kHz:
  delayMicroseconds(int(1e6/(2*frequency)));
}

void Reset_IIS3DWB(void)
{
  // Initialisation with the baudrate 2 000 000
  Serial.begin(2000000);
  SPI.begin();
  pinMode(CSPIN, OUTPUT);
  digitalWrite(CSPIN, HIGH); 
  pinMode(IIS3DWB_intPin1, INPUT);
  pinMode(IIS3DWB_intPin2, INPUT);
  SPI.beginTransaction(SPISettings(10000000, MSBFIRST, SPI_MODE0)); 
  
  digitalWrite(CSPIN, HIGH);
  if(c == 0x7B)   
  {
    digitalWrite(LED_BUILTIN, HIGH);
    IIS3DWB.reset();  // RESET DE L'ACCELEROMETRE
    aRes = IIS3DWB.getAres(Ascale); // CALUL DU LSB
    delay(100);
    IIS3DWB.init(Ascale);
  }
  EcritureByte(IIS3DWB_CTRL1_XL, 0xA0 | AFS_4G << 2);
  EcritureByte(IIS3DWB_CTRL3_C, 0x40 | 0x04);
  delay(100);
}


void LectureAccelData(int16_t * destination)
{
  uint8_t rawData[6];  // x/y/z accel register data stored here
  LectureBytes(IIS3DWB_OUTX_L_XL, 6, &rawData[0]);  // Read the 6 raw accel data registers into data array
  destination[0] = (int16_t)(((int16_t)rawData[1] << 8)  | rawData[0]) ;  // Turn the MSB and LSB into a signed 16-bit value
  destination[1] = (int16_t)(((int16_t)rawData[3] << 8)  | rawData[2]) ;
  destination[2] = (int16_t)(((int16_t)rawData[5] << 8)  | rawData[4]) ;
}


void LectureBytes(uint8_t reg, uint8_t count, uint8_t * dest) 
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


void EcritureByte(uint8_t reg, uint8_t value) 
{
  SPI.beginTransaction(SPISettings(10000000, 1, SPI_MODE0));
  digitalWrite(_cs, LOW); 
  SPI.transfer(reg & 0x7F);
  SPI.transfer(value);
  digitalWrite(_cs, HIGH);
  SPI.endTransaction();
}


void Lecture(uint8_t reg, uint8_t count, uint8_t * dest) 
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