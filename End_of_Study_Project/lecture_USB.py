############################################################
###                        PFE                           ###
###                Sébastien Doyez MEA5                  ###
############################################################

"""
    The goal of this code is to open a USB port and to bind it
    We will use it to bind the data from the teensy and the accelerometers
"""

import serial
import serial.tools.list_ports   
import time

# Initialisation of the data list
data_list = []
dataX_1 = []
dataY_1 = []
dataZ_1= []
time_list = []
time_ult = time.time()
# Function of recuperation of data from the USB port 
def recup_port_usb() :
    ports = list(serial.tools.list_ports.comports())
    for p in ports:
        if 'USB' in p.description :
            # Now we select our USB where the teensy publish its data...
            mData = serial.Serial(p.device,9600)
    print(mData.is_open) 
    print(mData.name) 
    return mData

Data =recup_port_usb()

line1 = Data.readline() 
print (line1)
donnee=line1.strip().split()
index_p = float(donnee[0])
# If we have the msg "CAPTEUR OFFLINE", we stop
while donnee != "CAPTEUR OFFLINE":
    line1 = Data.readline() 
    donnee=line1.strip().split()
    if len(donnee) !=0  :
        if donnee[0] != index_p:
            #print("X Acceleration : {}".format(float(donnee[2])))
            dataX_1.append(float(donnee[2]))
            #print("Y Acceleration: {}".format(float(donnee[3])))
            dataY_1.append(float(donnee[3]))
            #print("Z Acceleration: {}".format(float(donnee[4])))
            dataZ_1.append(float(donnee[4]))
            temps = time.time()
            print("temps d'attente = ", temps - time_ult)
            time_ult = temps
            #print("___________________________\n")
            index_p = donnee[0]

if donnee == 'CAPTEUR OFFLINE':
    print("ERROR: Please check the accelerometer...")

Data.close()