"""
    HMI's automatisation 
    author: Sebastien Doyez
"""

import subprocess
import time
import pyautogui
import pygetwindow as gw
import os
import win32gui
import ctypes

# Create variables with paths:
chemin_courant = r"C:/Users/doyez/OneDrive/Bureau/IHMmicroseismes"
coolterm_path = chemin_courant + "/CoolTermWin64Bit/CoolTerm.exe"
ihm_path = chemin_courant +"/IHM_PFE.py"
data_txt_path = chemin_courant +"/data.txt"

# Delete all the data from data.txt
with open(data_txt_path, 'w') as file:
    pass
file.close()

# Open CoolTerm
process1 = subprocess.Popen(coolterm_path)

# Waiting...
time.sleep(10)

# Open the data.txt file:
pyautogui.hotkey('ctrl', 'r')
time.sleep(1)
pyautogui.write('data.txt')
time.sleep(3)
pyautogui.press('enter')
time.sleep(0.1)
pyautogui.press("tab")
time.sleep(0.1)
pyautogui.press("enter")
time.sleep(0.1)

# Connect CoolTerm to serial 
pyautogui.hotkey('ctrl', 'k')
time.sleep(0.1)
print("Start the interface in ...")

# Waiting before opening the HMI
for i in range(5,0,-1):
    print(f"{i}...")
    time.sleep(1)

# Open the HMI:
commande = ['python', ihm_path]
process = subprocess.Popen(commande)
print("Interface start!")
process.wait()

# If the user exit the HMI => it kills CoolTerm
pyautogui.hotkey('ctrl','k')
time.sleep(0.1)
process1.kill()
