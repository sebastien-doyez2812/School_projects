import matplotlib 
import matplotlib.pyplot as plt
myfile = "C:/Users/doyez/OneDrive/Bureau/IHMmicroseismes/test_data_manquante/test_10khz.txt"
tmps = []
X = []
Y = []
Z = []
temps = 0
cpt = 0

var = 0

with open(myfile) as file:
    data_txt = file.readlines()
    for i in range(len(data_txt)):
        list = data_txt[i].split()
        tmps.append(int(list[0]))
        
        if abs(float(list[1])) < 130:
            X.append(float(list[1]))
        else: 
            X.append(0.0)
        
        if abs(float(list[2])) < 130:
            Y.append(float(list[2]))
        else :
            Y.append(0.0)
        if abs(float(list[3])) < 130:
            Z.append(float(list[3]))
        else:
            Z.append(0.0)
        

for j in range(1, int(len(tmps)/40)):
    temps = temps + (tmps[j] - tmps[j - 1]) 
    cpt =  cpt + 1

print("frequence = ", int(1e6/(temps/cpt)), ' Hz.')

plt.figure(1)
plt.title("Affichage des données")

plt.subplot(3,1,1)
plt.plot(tmps, X)
plt.xlabel("Time(us)")
plt.ylabel("Accélération sur X")

plt.subplot(3,1,2)
plt.plot(tmps, Y)
plt.xlabel("Time(us)")
plt.ylabel("Accélération sur Y")

plt.subplot(3,1,3)
plt.plot(tmps, Z)
plt.xlabel("Time(us)")
plt.ylabel("Accélération sur Z")

plt.show()