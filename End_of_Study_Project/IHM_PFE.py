"""
    title: End of study project
    author: Sebastien Doyez, MEA5 2023 - 2024
"""



from tkinter import * 
from tkinter.messagebox import *
import matplotlib.pyplot as plt
from matplotlib.widgets import SpanSelector
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt
from tkinter import filedialog
from tkinter import messagebox
import shutil
import os
import threading
import queue
from queue import Queue  
import time
import subprocess

refresh_time = 10
nb_points = 300
limit_fixed = [0, 0]
autoscale = 1
color_sensor1 = 'c'
color_sensor2 = 'r'
color_sensor3 = 'g'
min_fixed = 0
max_fixed= 1
nb_skip_line = 100
min_auto_plot = -80
max_auto_plot = 80
size_max_data = 4 * 1024 * 1024  # 4 MB

time_list = []
dataX_1 = []
dataY_1 = []
dataZ_1= []

# Creation of a window:
window = Tk()
window.title("Seismic study interface of the model")

# We will put the windows to the same resolution of the screen:
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()
window.geometry(f"{screen_width}x{screen_height}")

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
axis1.plot(time_list, dataX_1, color = color_sensor1)
axis1.set_xlabel('Time (ms)')
axis1.set_ylabel('ACCELERATION (mg)')
axis1.set_title('Graph of accelerometric data on the X axis')
axis1.legend()
line1, = axis1.plot([], [], color=color_sensor1)


# Creation of a Canva where we will put our fig: 
canvas1 = FigureCanvasTkAgg(fig1, master=right_frame1)
canvas1.get_tk_widget().pack(fill=BOTH, expand=True)

fig2, axis2 = plt.subplots(figsize=(6, 2))
canvas2 = FigureCanvasTkAgg(fig2, master=right_frame2)

axis2.plot(time_list, dataY_1, color = color_sensor2)
axis2.set_xlabel('Time (ms)')
axis2.set_ylabel('ACCELERATION (mg)')
axis2.set_title('Graph of accelerometric data on the Y axis')
axis2.legend()
line2, = axis2.plot([], [], color=color_sensor2)

# Creation of a Canva where we will put our fig: 
canvas2 = FigureCanvasTkAgg(fig2, master=right_frame2)
canvas2.get_tk_widget().pack(fill=BOTH, expand=True)

fig3, axis3 = plt.subplots(figsize=(6, 2))
canvas3 = FigureCanvasTkAgg(fig3, master=right_frame3)

axis3.plot(time_list, dataZ_1, color = color_sensor3)
axis3.set_xlabel('Time (ms)')
axis3.set_ylabel('ACCELERATION (mg)')
axis3.set_title('Graph of accelerometric data on the Z axis')
axis3.legend()
line3, = axis3.plot([], [], color=color_sensor3)

# Creation of a Canva where we will put our fig: 
canvas3 = FigureCanvasTkAgg(fig3, master=right_frame3)
canvas3.get_tk_widget().pack(fill=BOTH, expand=True)

#########################################################
###                     FUNCTIONS                     ###
#########################################################

# Creation of a queue, due to the threading:
data_queue = Queue()

# Creation of a function which read the data, and store the latest ones.

def read_data_worker():
    global time_list, dataX_1, dataY_1, dataZ_1
    time_list.clear()
    dataX_1.clear()
    dataY_1.clear()
    dataZ_1.clear()
    while True:

        # We need to open the data.txt file, in which there are all the data.
        with open("data.txt", 'r') as file:
            data_txt = file.readlines()
            last_line_read = len(data_txt) - nb_skip_line * nb_points

            # The goal is, for every data, we take 1 data and skip the 99 others
            # This is a way to have data on a bigger time scale. 
            i = last_line_read //nb_skip_line
            index = i*nb_skip_line
            while index < len(data_txt):
                ligne = data_txt[index]
                i = i + 1
                index = i* nb_skip_line
                donnee = ligne.split()

                # We need to test if the line selected is a real data line or a error code:
                if len(donnee) == 5 and donnee[0] != "SENSOR": 

                    # Here, the line constains the data
                    time_list.append(int(donnee[0]))
                    dataX_1.append(float(donnee[1]))
                    dataY_1.append(float(donnee[2]))
                    dataZ_1.append(float(donnee[3]))

                    # In order to keep the plot fluid, we don't store all the data,
                    # we only take the latest data and erase the oldest
                    while len(dataX_1) > nb_points:
                        time_list.pop(0)
                        dataX_1.pop(0)
                        dataY_1.pop(0)
                        dataZ_1.pop(0)

        # Put the data into the queue:
        data_queue.put((time_list.copy(), dataX_1.copy(), dataY_1.copy(), dataZ_1.copy()))

        # Add a sleep, to limite the CPU utilisation
        time.sleep(0.1)  

# Creation of a thread:
data_thread = threading.Thread(target=read_data_worker, daemon=True)
data_thread.start()


# The function updata_data will update the 3 axis plots:
def update_data():
    global time_list, dataX_1, dataY_1, dataZ_1
    try:
        while True:
            
            # We need to clear the lists, they will be update just after with the queue.
            time_list.clear()
            dataX_1.clear()
            dataY_1.clear()
            dataZ_1.clear()

            # Take the data from the queue:
            time_list, dataX_1, dataY_1, dataZ_1 = data_queue.get_nowait()

            # Check if the time_list is empty and if its size is the same as the dataX_1 's size.
            if len(time_list) == len (dataX_1) and time_list:

                # For plotting data, we need to clear all the previous plot and after draw the new graph
                axis1.clear()

                # This is due to the autoscale/ set acceleration axis  functionnalities
                if autoscale == 0 and axis_chosen == axis1:
                    axis1.set_ylim(min_fixed, max_fixed)
                else : 
                    axis1.set_ylim(min(dataX_1) + min_auto_plot, max(dataX_1) + max_auto_plot)
                
                # Now, we can plot the new graph:
                axis1.plot(time_list, dataX_1, color = color_sensor1)   
                canvas1.draw() 
                
            # Same...
            if len(time_list) == len(dataY_1) and time_list:
                axis2.clear()
                if autoscale == 0 and axis_chosen == axis2:
                    axis2.set_ylim(min_fixed, max_fixed)
                else : 
                    axis2.set_ylim(min(dataY_1)+ min_auto_plot, max(dataY_1) + max_auto_plot)
                axis2.plot(time_list, dataY_1, color = color_sensor2)   
                canvas2.draw()  
            
            if len(time_list) == len(dataZ_1) and time_list: 
                axis3.clear()              
                if autoscale == 0 and axis_chosen == axis3:
                    axis3.set_ylim(min_fixed, max_fixed)
                else : 
                    axis3.set_ylim(min(dataZ_1) + min_auto_plot, max(dataZ_1) + max_auto_plot)
                axis3.plot(time_list, dataZ_1, color = color_sensor3)   
                canvas3.draw()    
        
    except queue.Empty:
        # The queue is empty, nothing to do...
        pass
    
    # Next update:
    window.after(100, update_data)

# First update:
window.after(100, update_data)

# The Show data functionalty will plot all the data of one axis from one sensor.
# With the Span Selector, we will be able to zoom on the graph, save it...
def Show_data():
    global Select_window

    # Creation of the window where the user will choose the sensor, the axis...
    Select_window = Toplevel()
    Select_window.geometry("400x300")
    Select_window.title("Choose the sensor:")
    
    # We need to select which axis we want:
    text0 = Label(Select_window, text= "Select the axis:")
    text0.pack()

    # We will use a combo box:
    sensor_options = ['X data', 'Y data', 'Z data']
    selected_sensor = StringVar() 
    selected_sensor.set(sensor_options[0])
    sensor_menu = OptionMenu(Select_window, selected_sensor, *sensor_options)
    sensor_menu.pack()
     
    # We also need to select the frequency:
    # The goal is to permite for the user to have less data plot (so the plot is faster) or
    # all the data and this plot will take more time.
    text1 = Label(Select_window, text= "Select the frequency = ")
    text1.pack()

    # We also need a combo box:
    frequencies_options = ['10 kHz', '5 kHz', '1 kHz']
    frequency_selected = StringVar() 
    frequency_selected.set(frequencies_options[0])
    frequency_menu = OptionMenu(Select_window, frequency_selected, *frequencies_options)
    frequency_menu.pack()

    text2 = Label(Select_window, text= "\n\n")
    text2.pack()

    # for the frequency, we have 3 options:
    # 10 kHz ie plot all data
    # 5 kHz  ie plot one data, skip one...
    # 1 kHz  ie plot one data, skip nine...
    def read_csv(nom_fichier, Y_chosen):
        t_list = []  # List for the time
        a_list = []  # List for the acceleration

        # We need to know what is the frequency selected:
        f_select = frequency_selected.get()
        if f_select == '10 kHz':
            f = 1
        else: 
            if f_select == '5 kHz':
                f = 2
            else:
                if f_select == '1 kHz':
                    f = 10
        
        # Now we know the frequency used, we need to take 1 data and skip f-1 data.
        i = 0
        with open(nom_fichier, 'r') as fichier_txt:
            lines = fichier_txt.readlines()[5:] 
            for ligne in lines:
                data = ligne.split()
                if len(data) == 5 and data[0] != "SENSOR" and int(data[0]) > 0:
                    
                    # A way to know if we take the data is to use %: if i%f == 0, we need to plot the data.
                    if i%f == 0:
                        t_list.append(int(data[0]))  
                        a_list.append(float(data[Y_chosen]))
                i = i + 1
        return t_list, a_list

    # We also need to know whatt axis, the user wants to study:
    def Sensor_selector():
        global Select_window
        global ax_select

        # By default, the axis chosen is X
        Y_chosen = 1

        # What is the value of the Spinbox for the selected axis?
        data = selected_sensor.get()
        
        if data == 'X data':
            Y_chosen = 1
            title_focus = "Graph on the X axis"
        elif data == 'Y data':
            Y_chosen = 2
            title_focus = "Graph on the Y axis"
        else:
            Y_chosen = 3
            title_focus = "Graph on the Z axis"

        # Now we know what axis plot:
        X_list, Y_list =  read_csv("data.txt",Y_chosen) 
        Select_window.destroy()

        # For the update if there is selection
        def onselect(xmin, xmax):
            ax_select.set_xlim(xmin, xmax)
            fig_select.canvas.draw()
       
        # Preparation of the interactive plotting window:
        plt.ioff()
        fig_select, ax_select = plt.subplots()

        ax_select.plot(X_list, Y_list)
        ax_select.set_title(title_focus)

        # Creation of a selector (SpanSelector)
        span = SpanSelector(ax_select, onselect, 'horizontal', useblit=True)       
            
        fig_select.show()
        plt.ion()

    # We need a button for this functionnality:
    update_button = Button(Select_window, text="Update Graph", command=Sensor_selector)
    update_button.pack()

# The goal of the write_CSV function is to permite to the user to store "data.txt" (the
# fil where all the data are store in a folder of his choise)
# the data.txt will be split in data_part{i}.txt files, where its sizes are size_max_data bytes.
def write_CSV():
    try:
        # Ask the user for the destination folder
        destination_folder = filedialog.askdirectory()
        if not destination_folder:
            # User clicked Cancel
            return

        file_path = "data.txt"

        # Check if the file exists
        if not os.path.exists(file_path):
            messagebox.showerror("Erreur", "Le fichier data.txt n'existe pas.")
            return

        # Check the size of the file
        size_file = os.path.getsize(file_path)

        if size_file > size_max_data:
            # Create a folder where there will have our data
            dossier = "Data Folder"
            data_folder_path = os.path.join(destination_folder, dossier)

            if not os.path.exists(data_folder_path):
                os.mkdir(data_folder_path)
            else:
                # The folder already exists: 
                # We need to delete it and create another one.
                shutil.rmtree(data_folder_path)
                os.mkdir(data_folder_path)

            # Read the data from the file
            with open(file_path, 'r') as input_file:
                data = input_file.read()

            # Split the data based on line breaks
            lines = data.splitlines()

            # Initialize variables
            current_chunk = ""
            current_chunk_size = 0

            # Process each line and create chunks
            for line in lines:
                line_size = len(line.encode('utf-8'))
                if current_chunk_size + line_size > size_max_data:
                    # Save the current chunk to a separate file
                    output_file_path = os.path.join(data_folder_path, f"data_part{len(os.listdir(data_folder_path)) + 1}.txt")
                    with open(output_file_path, 'w') as output_file:
                        output_file.write(current_chunk)
                    current_chunk = ""
                    current_chunk_size = 0

                # Add the line to the current chunk
                current_chunk += line + '\n'
                current_chunk_size += line_size

            # Save the last chunk if it's not empty
            if current_chunk:
                output_file_path = os.path.join(data_folder_path, f"data_part{len(os.listdir(data_folder_path)) + 1}.txt")
                with open(output_file_path, 'w') as output_file:
                    output_file.write(current_chunk)

            messagebox.showinfo("Success", "Files has been cut in the Data Folder")

        else:
            # Build the path with os.path.join
            destination_path = os.path.join(destination_folder, "data.txt")

            # Copy the file
            shutil.copy(file_path, destination_path)

            messagebox.showinfo("Success", f"The file data.txt has been save in the folder: {destination_folder}.")

    except Exception as e:
        messagebox.showerror("Erreur", f"Une erreur s'est produite : {str(e)}")

# The function test_integrite will show us the number of errors:
# A file named "error_report.txt" will be saved and showed to the user:
# This is the form of the document:
#                                     |   On the right : there are errors from the teensy: 
#                                     |   code 0: all the data = 0
#                 X                   |   code 1: too much delay between data
#                                     |   code 2: data repetition
# ____________________________________|_____________________________________________________
# On the right:                       |
# There are data missed from errors   |
# extern to the teensy                |                     X
def test_integrite():
    previous_id = 0
    previous_time = 0
    time_missed = 0

    # We need to create a new file named "error_report.txt"
    with open("error_report.txt", 'w') as file_error_report:

        # The first line we will write is 
        # " previous id     id:     time missed"    => This is for the data missed (external error)
        # " Error Teensy "                          => For the error due to the Teensy 
        file_error_report.write("previous id: \t id: \t time missed: \t\t\t Error Teensy:")
    file_error_report.close()

    # We will find the errors in the data.txt file:
    with open ("data.txt", 'r') as file:
        data_txt = file.readlines()
        nb_val= len(data_txt)- 5
        nb_error = 0
        
        #The first and last data are skip because there are sometimes there are errors due to the connection of CoolTerm
        for j in range(len(data_txt)- nb_val, len(data_txt)-5, 1):
            ligne = data_txt[j]
            data = ligne.split()

            # If this is the firt data, we need to store the previous id and the previous time:
            if j == len(data_txt) - nb_val :
                previous_id = int(data[4])
                previous_time = int(data[0])
                continue

            # Else, this is not the first data, so we can find if there are errors:
            else: 
                
                # There are 2 types of errors:
                #                               _ errors from Teensy
                #                               _ external errors

                # First, let's find the external errors:
                if data[0] != "SENSOR" and len(data) == 5:
                    # Because the errors from teensy can be spotted with the first data in the line : "SENSOR"
                    id = int(data[4])

                    # Every data have its own id:
                    # If the data'id are considered as a sequence data[n]:
                    #       data_id[n+1] = data_id[n] + 1
                    # This is programmed in the teensy's code
                    if id != previous_id +1:

                        # If data_id[n+1] =/= data_id[n] + 1 then there are data missed.
                        with open("error_report.txt", 'a') as file_error_report:
                            
                            # Now let's add a error in the "error_report.txt" file: 
                            nb_error = nb_error + 1

                            # We need the id and previous id AND the time missed
                            file_error_report.write(f"\n{previous_id} \t\t {id} \t { int(data[0]) - previous_time}")

                            # At the end of the "error_report.txt", we will write the total time missed
                            time_missed += int(data[0]) - previous_time
                        file_error_report.close()    

                    # Update the id and time:    
                    previous_id = id
                    previous_time = int(data[0])

                # If there is an error from the teensy:
                if data[0] == "SENSOR": 

                    # Let's take the error code
                    code = int(data[2])

                    # Let's add an error in the "error_report.txt":
                    nb_error = nb_error + 1
                    with open("error_report.txt", 'a') as file_error_report:

                        # code 0: all the data = 0
                        # code 1: too much delay between data
                        # code 2: data repetition
                        if code == 0:
                            file_error_report.write( f"\n\t\t\t\t\t\t\tERROR TEENSY:\t code {int(data[2])}: All data are 0.\n") 
                        else :
                            if code == 1:
                                file_error_report.write( f"\n\t\t\t\t\t\t\tERROR TEENSY:\t code {int(data[2])}: There is too much delay between 2 data.\t {float(data[3])} us missed.\n") 
                                time_missed += float(data[3]) - 100 # The delay should be 100 us.
                            else :
                                if code == 2:
                                    file_error_report.write( f"\n\t\t\t\t\t\t\tERROR TEENSY:\t code {int(data[2])}: There is a data repetition.\n")                  
                    file_error_report.close() 
        
        # At the end of the error_report file, we will write the total time missed:
        # This will be useful because we can calculate a ratio: time missed / total time
        with open("error_report.txt", 'a') as file_error_report:
            file_error_report.write(f"\n\n\n __________________________________________________________________________________________________________________________________________________________________\n\nTotal time missed : {time_missed} us \n Total error: {nb_error}")
        file_error_report.close()

        # Now the error report is ready, we will show how much errors there are,
        # If he wants, he can read the error_report and save it
        window_integrity = Toplevel()
        window_integrity.geometry("300x150")
        window_integrity.title("Integrity test")

        text0 = Label(window_integrity, text= f" There are {nb_error} errors in {data[0]} microsecondes\n There are {len(data_txt)} datas.\nThe total time missed is {time_missed} us!\n")
        text0.pack()

        # Functions for the buttons:
        def show_error_report():
            subprocess.run(["start", "error_report.txt", "error_report.txt"], shell=True)

        def save_error_report():
            # Ask the user for the destination folder
            destination_folder = filedialog.askdirectory()
            if not destination_folder:
            # User clicked Cancel
                return

            file_path = "error_report.txt"

            # Check if the file exists
            if not os.path.exists(file_path):
                messagebox.showerror("Erreur", "Le fichier error_report.txt n'existe pas.")
                return
                # Build the path with os.path.join
            destination_path = os.path.join(destination_folder, "error_data.txt")

            # Copy the file
            shutil.copy(file_path, destination_path)

            messagebox.showinfo("Success", f"The file error_report.txt has been saved in {destination_folder}")

        text_button = Button(window_integrity, text="Show the error report?", command= show_error_report)
        text_button.pack()

        save_button = Button(window_integrity, text = "Save the error report?", command = save_error_report)
        save_button.pack()
        

# We will to calculate the frequency with which we receive our data:
def frequency():
    previous = 0
    sum = 0

    # We will take the average of the delay between two datas:
    # first let's read the data.txt:
    with open("data.txt", 'r') as file:
        data_text = file.readlines()

        # We will use the last 100 lines: 
        for i in range(len(data_text) - 100, len(data_text), 1):
            ligne1 = data_text[i]
            data = ligne1.split()

            # We need to calculate the delay between two data:
            if i == len(data_text) - 100:
                previous = int(data[0])
                continue
            temps = int(data[0]) - previous

            # Tests:
            if temps >= 0: 
                # We add this delay and with the sum, we will calculate the average delay between two data.
                sum = sum + temps
                previous = int(data[0])
    
    # Now we have the sum of the delay for 100 datas. We can calculate the frequecy: f = 1/ average_delay
    avg_time = sum/100
    f= 1/(avg_time*1e-6)

    # Message box for showing the frequency:
    messagebox.showinfo("Actual Frequency", f"The actual frequency is {int(f)} Hz")
    
# min_max function 's goal is to set the max and min acceleration scale:    
def min_max():
    global autoscale
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

    # Creation of a space where the user will choose the axis
    sensor_options = ['X data', 'Y data', 'Z data']
    selected_sensor = StringVar() 
    selected_sensor.set(sensor_options[0])
    sensor_menu = OptionMenu(axis_update_window, selected_sensor, *sensor_options)
    sensor_menu.pack()

    def min_max_funct():
        global autoscale, axis_chosen, min_fixed, max_fixed
        # What is the value of the Spinbox
        data = selected_sensor.get()
            
        if data == 'X data':
            axis_chosen = axis1
        elif data == 'Y data':
            axis_chosen = axis2
        else:
            axis_chosen = axis3

        # Set the min & max for the axis chosen. 
        autoscale = 0
        min_fixed = float(min_acc_entry.get())
        max_fixed = float(max_acc_entry.get())
        
        # Destroy the windows:
        axis_update_window.destroy()      

    update_format_acc_button = Button(axis_update_window, text="Update the max & min of the acceleration", command=min_max_funct)
    update_format_acc_button.pack()

def Help_IHM():
    """
        This function shows a new window to help the user
    """ 
    #Creation of a window:
    help_window = Toplevel()
    help_window.title("Help")

    help_label = Label(help_window, text="This interface has been created with the aim of simplifying the use of the layout as well as the management of output data.\n\n The first page show a graph with all the data and at the left, you will see the graphs of all the sensors")
    help_label.pack()

def About_us():
    """
        This function shows informations about the creator of the interface and how to contact him
    """
    showinfo("About us", "This interface was created by Sébastien Doyez, a MEA5, in 2023... \nIf you need further information, you can contact him at the following address: \nsebastien.doyez@etu.umontpellier.fr")

# If the autoscale_fct is selected, this enables the min_max function.
def autoscale_fct():
    global autoscale
    autoscale = 1
#########################################################
###                    END FONCTIONS                  ###
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

#########################################################
###                      MENU                         ###
#########################################################

# Creation of the menu:
menubar = Menu(window)

# We need 3 menu: "File", "Edit", "Help"
File = Menu(menubar, tearoff=0)

# We need to add the command under the first menu:
File.add_command(label="Export the data to a CSV file", command= write_CSV)
File.add_command(label="Clear")#, command=clear_sensor)
File.add_separator()
File.add_command(label="Exit", command=exit)
menubar.add_cascade(label="File", menu=File)

Edit = Menu(menubar, tearoff=0)
Edit.add_command(label="Show data", command= Show_data)
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

window.mainloop()