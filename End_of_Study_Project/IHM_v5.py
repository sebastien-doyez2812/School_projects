############################################################
###                        PFE                           ###
###                Sébastien Doyez MEA5                  ###
############################################################

from tkinter import * 
from tkinter.messagebox import *
import matplotlib.pyplot as plt
from matplotlib.widgets import SpanSelector
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import csv
import random
import serial
import serial.tools.list_ports   
import time

# Setting:
time_list = []
dataX_1 = []
dataY_1 = []
dataZ_1= []

color_sensor1 = 'c'
color_sensor2 = 'r'
color_sensor3 = 'g'
autoscale = 1 # the user set the limit => autoscale = 0; else autoscale = 1

# Autoscale 
autoscale1 = 1
autoscale2 = 1
autoscale3 = 1

refresh_time = 100 #ms
nb_points = 30
limit_fixed = [0, 0]
limit_acc = [0, 1]
temps_de_depart = time.time()
CSV_output_file = "data_output.csv"

# Creation of a window:
window = Tk()
window.title("Seismic study interface of the model")

# We will put the windows to the same resolution of the screen:
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
window.geometry(f"{screen_width}x{screen_height}")

###############################################################
###                     THE FUCNTIONS                       ###
###############################################################

def recup_port_usb() :
    ports = list(serial.tools.list_ports.comports())
    for p in ports:
        if 'USB' in p.description :
            # Now we select our USB where the teensy publish its data...
            mData = serial.Serial(p.device,9600)
    return mData

def update_lists():
    global temps_de_depart
    Data =recup_port_usb()

    line1 = Data.readline() 
    donnee=line1.strip().split()
    index_p = float(donnee[0])
    # If we have the msg "CAPTEUR OFFLINE", we stop
    line1 = Data.readline() 
    donnee=line1.strip().split()
    if len(donnee) !=0 and donnee != [b'CAPTEUR', b'OFFLINE']:
        if donnee[0] != index_p:
            dataX_1.append(float(donnee[2]))
            dataY_1.append(float(donnee[3]))
            dataZ_1.append(float(donnee[4]))

            index_p = donnee[0]
        if time_list == []:
            time_list.append(0)
        else:
            time_list.append(time.time() - temps_de_depart)
    if donnee == [b'CAPTEUR', b'OFFLINE']:
        print("ERROR: Please check the accelerometer...")
        return 1
    Data.close()

def About_us():
    """
        This function shows informations about the creator of the interface and how to contact him
    """
    showinfo("About us", "This interface was created by Sébastien Doyez, a MEA5, in 2023... \nIf you need further information, you can contact him at the following address: \nsebastien.doyez@etu.umontpellier.fr")

def Help_IHM():
    """
        This function shows a new window to help the user
    """ 
    #Creation of a window:
    help_window = Toplevel()
    help_window.title("Help")

    help_label = Label(help_window, text="This interface has been created with the aim of simplifying the use of the layout as well as the management of output data.\n\n The first page show a graph with all the data and at the left, you will see the graphs of all the sensors")
    help_label.pack()

def append_data():
    """
    FONCTION A SUPPRIMER PAR LA SUITE:
    C EST UNE FONCTION QUI REMPLIR DE MANIERE ALEATOIRE LES LISTES
    """   
    global time_list, dataX_1, dataY_1, dataZ_1
    if len(time_list) == 0:
        time_list.append(0.0)
        dataX_1.append(random.random())
        dataY_1.append(random.random())
        dataZ_1.append(random.random())
    else:
        time_list.append(len(time_list))
        dataX_1.append(random.random())
        dataY_1.append(random.random())
        dataZ_1.append(random.random())

def clear_sensor():
    global time_list, dataX_1, dataY_1, dataZ_1
    global axis1, axis2, axis3

    axis1.clear()
    axis1.set_xlabel('Time (ms)')
    axis1.set_ylabel('ACCELERATION (mg)')
    axis1.set_title('Graph of accelerometric data on the X axis')

    axis2.clear()
    axis2.set_xlabel('Time (ms)')
    axis2.set_ylabel('ACCELERATION (mg)')
    axis2.set_title('Graph of accelerometric data on the Y assis')

    axis3.clear()
    axis3.set_xlabel('Time (ms)')
    axis3.set_ylabel('ACCELERATION (mg)')
    axis3.set_title('Graph of accelerometric data on the Z axis')

    time_list = []
    dataX_1 = []
    dataY_1 = []
    dataZ_1 = []

"""
    if we plot every points, every time we have a new data, it will be slow
    So,  we will use nb_points points to plots
"""

def update_graphs():
    global canvas1, canvas2, canvas3
    global axis1, axis2, axis3, axis_selected
    global fig1, fig2, fig3
    global time_list, dataX_1, dataY_1, dataZ_1
    X_backup = time_list[:]
    """
        Ajout de données randoms ( A SUPPRIMER ET DECOMMENTER UPDATE_LIST)
    """  
    update_lists()
    if autoscale == 1 :
        # if there are a new element in the lists:
        if len(X_backup) < len(time_list):
            index = len(time_list)-1
            if index < nb_points:
                dep = 0
            else:
                dep = index - nb_points
            limit = [time_list[dep],time_list[index]]
            # Reset the limits of the graphs
            axis1.set_xlim(limit)
            axis2.set_xlim(limit)
            axis3.set_xlim(limit)
            
            # Reset the limits of the acceleration:
            axis1.set_ylim([min(dataX_1[dep:index])-1, max(dataX_1[dep:index])+1])
            axis2.set_ylim([min(dataY_1[dep:index])-1, max(dataY_1[dep:index])+1])
            axis3.set_ylim([min(dataZ_1[dep:index])-1, max(dataZ_1[dep:index])+1])

            # Reset the graphs:     
            axis1.plot(time_list[dep: index], dataX_1[dep: index], color = color_sensor1)
            axis2.plot(time_list[dep: index], dataY_1[dep: index], color = color_sensor2)
            axis3.plot(time_list[dep: index], dataZ_1[dep: index], color = color_sensor3)
            
            canvas1.draw()
            canvas2.draw()
            canvas3.draw()
    else: 
        if axis_selected == axis1:
            axis_no_sel1 = axis2
            axis_no_sel2 = axis3
            data1 = dataX_1
            color1 = color_sensor1 
            data2 = dataY_1
            color2 = color_sensor2
            data3 = dataZ_1
            color3 = color_sensor3
        else : 
            if axis_selected == axis2:
                axis_no_sel1 = axis1
                axis_no_sel2 = axis3
                data1 = dataY_1
                color1 = color_sensor2 
                data2 = dataX_1
                color2 = color_sensor1
                data3 = dataZ_1
                color3 = color_sensor3
            else:
                axis_no_sel1 = axis2
                axis_no_sel2 = axis1
                data1 = dataZ_1 
                color1 = color_sensor3
                data2 = dataY_1
                color2 = color_sensor2
                data3 = dataX_1
                color3 = color_sensor1
        axis_selected.set_xlim(limit_fixed)
        axis_selected.plot(time_list, data1, color = color1)

        canvas1.draw()
        if len(X_backup) < len(time_list):
            index = len(time_list)-1
            if index < nb_points:
                dep = 0
            else:
                dep = index - nb_points
            limit = [time_list[dep],time_list[index]]
            # Reset the limits of the graphs
            axis_no_sel1.set_xlim(limit)
            axis_no_sel2.set_xlim(limit)
             
            axis_no_sel1.plot(time_list[dep: index], data2[dep: index], color = color2)
            axis_no_sel2.plot(time_list[dep: index], data3[dep: index], color = color3)
            
            canvas1.draw()
            canvas2.draw()
            canvas3.draw()
  
    window.after(refresh_time,update_graphs)


def zoom(): 
    """
        The goal of this function is to open a new window where the user set the limit of X he wants 
        and it will show in the same window the 4 plots
    """
    global autoscale
    global limit_fixed

    # Here, the user will be able to select the X-axis he want
    # Creation of the window:
    zoom_window = Toplevel()
    zoom_window.title("Zoom update")
    zoom_window.geometry("350x170")

    # creation of a space where the user will set the limit of the X axis:
    x_min_label = Label(zoom_window, text="Time min = ")
    x_min_label.pack()
    
    x_min_entry = Entry(zoom_window)
    x_min_entry.pack()
    x_min_entry.insert(0, limit_fixed[0])

    x_max_label = Label(zoom_window, text="Time max = ")
    x_max_label.pack()

    x_max_entry = Entry(zoom_window)
    x_max_entry.pack()
    x_max_entry.insert(0, limit_fixed[1])

    # Button for the selection of the axis:
    sensor_options = ['X data', 'Y data', 'Z data']
    selected_sensor = StringVar() 
    selected_sensor.set(sensor_options[0])
    sensor_menu = OptionMenu(zoom_window, selected_sensor, *sensor_options)
    sensor_menu.pack()

    def plot_w_selected_limits():
        global autoscale, limit_fixed, axis_selected
        autoscale = 0
        limit_fixed[0] = float(x_min_entry.get())
        limit_fixed[1] = float(x_max_entry.get())
        # Which axis will we block on the time scale:
        data = selected_sensor.get()
        if data == 'X data':
            axis_selected = axis1
        elif data == 'Y data':
            axis_selected = axis2
        else:
            axis_selected = axis3
        zoom_window.destroy()
        
        """
        autoscale = 0
        # Which axis will we block on the time scale:
        data = selected_sensor.get()
        if data == 'X data':
            axis_chosen = axis1
        elif data == 'Y data':
            axis_chosen = axis2
        else:
            axis_chosen = axis3

        # Update the data:
        zoom_window.update()
        axis_chosen.set_xlim(float(x_min_entry.get()),float(x_max_entry.get()))
        zoom_window.destroy()
        """

    update_zoom = Button(zoom_window, text="Update_zoom", command= plot_w_selected_limits)
    update_zoom.pack()

def autoscale_fct():
    global autoscale 
    global axis1, axis2, axis3

    autoscale = 1
    # Reset:
    axis1.set_ylim(limit_acc)
    axis2.set_ylim(limit_acc)
    axis3.set_ylim(limit_acc) 

def Scan_selector():
    global Select_window

    # Creation of the window:
    Select_window = Toplevel()
    Select_window.geometry("350x80")
    Select_window.title("Choose the sensor:")
    
    # Combo Box:
    sensor_options = ['X data', 'Y data', 'Z data']
    selected_sensor = StringVar() 
    selected_sensor.set(sensor_options[0])
    sensor_menu = OptionMenu(Select_window, selected_sensor, *sensor_options)
    sensor_menu.pack()
    

    def Sensor_selector():
        global time_list, dataX_1, dataY_1, dataZ_1, Y_chosen
        global Select_window
        global ax_select
        
        # What is the value of the Spinbox
        data = selected_sensor.get()
            
        if data == 'X data':
            Y_chosen = dataX_1
            title_focus = "Graph on the X axis"
        elif data == 'Y data':
            Y_chosen = dataY_1
            title_focus = "Graph on the Y axis"
        else:
            Y_chosen = dataZ_1
            title_focus = "Graph on the Z axis"
        Select_window.destroy()

        # Fonction de mise à jour du graphique lors de la sélection
        def onselect(xmin, xmax):
            ax_select.set_xlim(xmin, xmax)
            fig_select.canvas.draw()

        fig_select, ax_select = plt.subplots()
        ax_select.plot(time_list, Y_chosen)
        ax_select.set_xlim(min(time_list), max(time_list))
        ax_select.set_ylim(min(Y_chosen), max(Y_chosen))
        
        # Création d'un sélecteur de plage (SpanSelector)
        span = SpanSelector(ax_select, onselect, 'horizontal', useblit=True)#, rectprops=dict(alpha=0.5, facecolor='red'))       
            
        fig_select.show()
    update_button = Button(Select_window, text="Update Graph", command=Sensor_selector)
    update_button.pack()


def min_max():
    global axis1, axis2, axis3
    # Creation of the window:
    axis_update_window =Toplevel()
    axis_update_window.geometry("400x150")
    axis_update_window.title("Update axis")

    # Creation of a space where the user will set the max, min and the x,y,z axis
    min_acc_label = Label(axis_update_window, text= "Minimal acceleration:")
    min_acc_entry = Entry(axis_update_window)
    min_acc_entry.insert(0, 0)
    min_acc_label.pack()
    min_acc_entry.pack()

    max_acc_label = Label(axis_update_window, text= "Maximal acceleration:")
    max_acc_entry = Entry(axis_update_window)
    max_acc_entry.insert(1, 1)
    max_acc_label.pack()
    max_acc_entry.pack()

    sensor_options = ['X data', 'Y data', 'Z data']
    selected_sensor = StringVar() 
    selected_sensor.set(sensor_options[0])
    sensor_menu = OptionMenu(axis_update_window, selected_sensor, *sensor_options)
    sensor_menu.pack()

    def min_max_funct():
        # What is the value of the Spinbox
        data = selected_sensor.get()
            
        if data == 'X data':
            axis_chosen = axis1
        elif data == 'Y data':
            axis_chosen = axis2
        else:
            axis_chosen = axis3

        # Actualisation of the min & max_acc_entry:
        axis_update_window.update()

        axis_chosen.set_ylim(float(min_acc_entry.get()),float(max_acc_entry.get()))
        
        # Destroy the windows:
        axis_update_window.destroy()
        

    update_format_acc_button = Button(axis_update_window, text="Update the max & min of the acceleration", command=min_max_funct)
    update_format_acc_button.pack()


def test_integrite():
    test_window = Toplevel()

def frequency():
    frequency_window = Toplevel()

def write_CSV():
    global CSV_output_file, dataX_1, dataY_1, dataZ_1, time_list
    with open(CSV_output_file, mode='w') as fichier_csv:
        for x, y, z, t in zip(dataX_1, dataY_1, dataZ_1, time_list):
            line = f"{x}\t{y}\t{z}\t{t}\n"
            fichier_csv.write(line)

       
    
###############################################################
###                     END FUCNTIONS                       ###
###############################################################


#########################################################
###                       CANVAS                      ###
#########################################################

# First plot of the data:
update_lists()
if update_lists() != 1:
    limit = [min(time_list), max(time_list)]
else:
    raise Exception("ERROR ACCELEROMETER")

# Creation of a main window: 
main_frame = Frame(window)
main_frame.pack(fill = BOTH, expand = True)

# Creation of 3 smaller spaces at the right
right_frame1 = Frame(main_frame, bg="lightblue",   width= int(screen_width), height= int(screen_height*0.3))
right_frame2 = Frame(main_frame, bg="lightgreen",  width= int(screen_width), height= int(screen_height*0.3))
right_frame3 = Frame(main_frame, bg="lightyellow", width= int(screen_width), height= int(screen_height*0.3))

# Put the 3 spaces one below the other
right_frame1.grid(row=0, column=0, sticky="nsew")
right_frame2.grid(row=1, column=0, sticky="nsew")
right_frame3.grid(row=2, column=0, sticky="nsew")

# Settings for the resizing of the window
main_frame.grid_columnconfigure(0, weight = 1)
main_frame.grid_rowconfigure(0, weight = 1)
main_frame.grid_rowconfigure(1, weight = 1)
main_frame.grid_rowconfigure(2, weight = 1)

# Creation of the axis, fig and canvas of the plots:
fig1, axis1 = plt.subplots(figsize=(6, 2))
canvas1 = FigureCanvasTkAgg(fig1, master=right_frame1)
fig2, axis2 = plt.subplots(figsize=(6, 2))
canvas2 = FigureCanvasTkAgg(fig2, master=right_frame2)
fig3, axis3 = plt.subplots(figsize=(6, 2))
canvas3 = FigureCanvasTkAgg(fig3, master=right_frame3)

# Creation of the figure for the right part: 
axis1.plot(time_list, dataX_1, color = color_sensor1)
axis1.set_xlim(limit)
axis1.set_xlabel('Time (ms)')
axis1.set_ylabel('ACCELERATION (mg)')
axis1.set_title('Graph of accelerometric data on the X axis')
axis1.legend()

# Creation of a Canva where we will put our fig: 
canvas1 = FigureCanvasTkAgg(fig1, master=right_frame1)
canvas1.get_tk_widget().pack(fill=BOTH, expand=True)

# Creation of the figure for the right part: 
axis2.plot(time_list, dataY_1, color = color_sensor2)
axis2.set_xlim(limit)
axis2.set_xlabel('Time (ms)')
axis2.set_ylabel('ACCELERATION (mg)')
axis2.set_title('Graph of accelerometric data on the Y axis')
axis2.legend()

# Creation of a Canva where we will put our fig: 
canvas2 = FigureCanvasTkAgg(fig2, master=right_frame2)
canvas2.get_tk_widget().pack(fill=BOTH, expand=True)

# Creation of the figure for the right part: 
axis3.plot(time_list, dataZ_1, color = color_sensor3)
axis3.set_xlim(limit)
axis3.set_xlabel('Time (ms)')
axis3.set_ylabel('ACCELERATION (mg)')
axis3.set_title('Graph of accelerometric data on the Z axis')
axis3.legend()

# Creation of a Canva where we will put our fig: 
canvas3 = FigureCanvasTkAgg(fig3, master=right_frame3)
canvas3.get_tk_widget().pack(fill=BOTH, expand=True)

#########################################################
###                   END CANVAS                      ###
#########################################################


#########################################################
###                      MENU                         ###
#########################################################

# Creation of the menu:
menubar = Menu(window)

# We need 3 menu: "File", "Edit", "Help"
File = Menu(menubar, tearoff=0)

# We need to add the command under the first menu:
File.add_command(label="Export the data to a CSV file", command= write_CSV)
File.add_command(label="Clear", command=clear_sensor)
File.add_separator()
File.add_command(label="Exit", command=window.quit)
menubar.add_cascade(label="File", menu=File)

Edit = Menu(menubar, tearoff=0)
Edit.add_command(label="Selector", command= Scan_selector)
Edit.add_command(label="Update time axis", command= zoom)
Edit.add_command(label="Update acceleration axis", command=min_max)
Edit.add_command(label="Autoscale", command = autoscale_fct)
menubar.add_cascade(label="Tools", menu=Edit)

Control = Menu(menubar,tearoff=0)
Control.add_command(label="Integrity test", command=test_integrite)
Control.add_command(label="Sampling frequency", command= frequency)
menubar.add_cascade(label="Control", menu=Control)

Help = Menu(menubar, tearoff=0)
Help.add_command(label="Help", command= Help_IHM)
Help.add_command(label="About us", command= About_us)
menubar.add_cascade(label="Help", menu=Help)

window.config(menu=menubar)

#########################################################
###                    END MENU                       ###
#########################################################

#########################################################
###                     BOUTONS                       ###
#########################################################

# Pour le choix du capteur:
id_spinbox = Spinbox(window, from_=1, to=3)
id_spinbox.pack()
update_button = Button(window, text="Update id sensor")#, command=Sensor_selector)
update_button.pack()

#########################################################
###                  END BOUTONS                      ###
#########################################################

# Update the plots:
window.after(refresh_time,update_graphs)

window.mainloop()