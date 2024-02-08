PFE 2023 - 2024
DOYEZ Sébastien

(French below)
EN:
In this file, you will find my work on my PIFE.
The folder TEENSY_IIS3DWB_SD_CARD_network contains the teensy 4.1's code of 2 sensor management, which write into SD code and and use also the serial port.
You'll have to use the laucher and Coolterm software in order to use the HMI I programmed. 
The IHM_sensor_network code contains the python code of the interface.

Before using this system: 
1) Check the launcer.py: 
	Check the location of Coolterm, the simplest is to place it in the same folder as the code.

To use this system:
1) Compile the code on the Teensy 4.1 via the arduino IDE
2) Launch the launcher.py: it will open Coolterm and configure it, then it will launch the HMI.
_________________________________________________________________________________________________________________________________________

FR:
Dans ce dossier, vous retrouvez mes travaux sur mon PIFE.
Le dossier TEENSY_IIS3DWB_SD_CARD_network contient le code teensy 4.1 de la gestion de 2 capteurs, avec écriture sur code SD et sur port série.
Vous devrez utiliser le laucher et le logiciel Coolterm afin de vous servir de l'IHM que j'ai programmer. 
Le code IHM_sensor_network contient le code python de l'interface.

Avant de vous servir de ce système: 
1) Vérifier le launcer.py: 
	vérifier l'emplacement de Coolterm, le plus simple est de le disposer dans le même dossier que le code.

Pour vous servir de ce système:
1) Compilez le code sur la Teensy 4.1 via l'IDE arduino
2) Lancez le launcher.py: celui va ouvrir Coolterm et va le configurer, puis il lancera l'IHM.