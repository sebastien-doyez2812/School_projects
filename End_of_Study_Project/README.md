# 🌎 End of Study Project: Creation of a Micro-Seism Study Bench 🌎
(French below)

## Overview 👀:
**EN:**
In this file, you will find my work on my PIFE.  
The folder `TEENSY_IIS3DWB_SD_CARD_network` contains the Teensy 4.1's code for managing 2 sensors, which writes to an SD card and uses the serial port.  
You'll have to use the `launcher` and `Coolterm` software in order to use the HMI I programmed.  
The `IHM_sensor_network` code contains the Python code for the interface.

## Before Using This System 🔧: 
1. Check the `launcher.py`:  
   Check the location of Coolterm; the simplest method is to place it in the same folder as the code.

To use this system:
1. Compile the code on the Teensy 4.1 via the Arduino IDE.
2. Launch the `launcher.py`: it will open Coolterm, configure it, and then launch the HMI.

---

## Vue d'ensemble 👀:
**FR:**
Dans ce dossier, vous retrouvez mes travaux sur mon PIFE.  
Le dossier `TEENSY_IIS3DWB_SD_CARD_network` contient le code Teensy 4.1 pour la gestion de 2 capteurs, avec écriture sur une carte SD et utilisation du port série.  
Vous devrez utiliser le `launcher` et le logiciel `Coolterm` afin de vous servir de l'IHM que j'ai programmée.  
Le code `IHM_sensor_network` contient le code Python de l'interface.

## Avant de vous servir de ce système 🔧: 
1. Vérifiez le `launcher.py`:  
   Vérifiez l'emplacement de Coolterm ; le plus simple est de le disposer dans le même dossier que le code.

Pour vous servir de ce système:
1. Compilez le code sur la Teensy 4.1 via l'IDE Arduino.
2. Lancez le `launcher.py`: il ouvrira Coolterm, le configurera, puis lancera l'IHM.
