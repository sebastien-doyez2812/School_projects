This is my Last semestral project in Polytech Montpellier:

The goal of this project is to permite to the Géoscience Montpellierte team to study micro earthquakes, simulated by a model. 
This folder contains: _ the python programs for the HMI ("IHM_PFE.py'),
                      _ a launcher to cimplify the use of CoolTerm and the HMI ("launcher.py"
                      _ the teensy program, to have access to the data from the sensors.


The sensors used are IIS3DWB, the datasheet is available here : https://www.st.com/en/mems-and-sensors/iis3dwb.html
The micro controler used is the teensy 4.0.

To used this project, run the launcher.py (it will open CoolTerm and put data.txt into the file used, and then launch the HMI).
