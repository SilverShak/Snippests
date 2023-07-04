from sys import exit as sys_exit
from time import sleep
from tkinter import Tk, Label, Entry, Button, Checkbutton, IntVar
from tkinter.messagebox import showinfo
from datetime import datetime, timedelta
import os

# if you want to use slack notifications, set the script path here
slack_util_path = "C://Users//username//tools//slack_me.py"

def schedule_reminder(*event):

    # get user input
    schedule_value = delay_time.get()
    note_entry_value = note_entry.get()

    #print("schedule_value is: " + str(schedule_value))
    #print("note_entry_value is: " + str(note_entry_value))
    #print("slack enable status is " + str(slack_enabled.get()))
  
    # abort if schedule value is empty
    if len(schedule_value) == 0:
        return

    # determinate schedule value pattern - time or minutes delay
    colon_count = schedule_value.count(':')

    if colon_count == 0:
        time_to_alert = datetime.now() + timedelta(minutes=int(schedule_value))
    elif colon_count == 1:
        h = int(schedule_value.split(":")[0])
        m = int(schedule_value.split(":")[1])
        time_to_alert = datetime.now().replace(hour=h, minute=m)

    elif colon_count == 2:
        h = int(schedule_value.split(":")[0])
        m = int(schedule_value.split(":")[1])
        s = int(schedule_value.split(":")[2])
        time_to_alert = datetime.now().replace(hour=h, minute=m, second=s)

    # set time to wait and hide window meantime
    seconds_to_sleep = (time_to_alert - datetime.now()).total_seconds()
    window.destroy()
    sleep(seconds_to_sleep)
    show_reminder(note_entry_value)


def show_reminder(note_entry_value):
    pop_up_root = Tk()
    pop_up_root.withdraw()

    print("note_entry_value is: " + str(note_entry_value))

    if note_entry_value is not None:
        message_reminder = note_entry_value
    else:
        message_reminder = "Time's Up!"
        
    if slack_enabled.get():
        os.system(f'python {slack_util_path}' + message_reminder + '"""')
    
    showinfo(title=None, message=message_reminder)
    pop_up_root.destroy()
    sys_exit()


# Create main window
window = Tk()

#window_style = ttk.Style(window)
#window_style.theme_use('azure')

window_width = 250
window_height = 120

# get the screen dimension
screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()

# find the center point
center_x = int(screen_width/2 - window_width / 2)
center_y = int(screen_height/2 - window_height / 2)

# set the position of the window to the center of the screen
window.geometry(f'{window_width}x{window_height}+{center_x}+{center_y}')

window.winfo_toplevel().title("Reminder")

label_font_name = "arial"
label_font_size = "14"

label_font_name = "arial"
button_font_size = "12"

# time
delay_time_label = Label(text="Time",font=(label_font_name, label_font_size)).grid(row=0, column=0, sticky="W", padx=(5))
delay_time = Entry(width=5) # must declare seperatly than grid in order to access variable later
delay_time.grid(row=0, column=1,sticky="W")

# note
note_label = Label(text="Note",font=(label_font_name, label_font_size)).grid(row=1, column=0, sticky="W",padx=(5))
note_entry = Entry(width=24) # must declare seperatly than grid in order to access variable later
note_entry.grid(row=1, column=1,sticky="W") 

# slack notificaiton trigger
slack_enabled = IntVar()
Checkbutton(text="Slack", variable=slack_enabled).grid(row=2, column=0, sticky="W", padx=(5))

# submit
schedule_button = Button(text="remind me", width=10, command=schedule_reminder, font=(label_font_name, button_font_size)).grid(row=3, column=1, sticky="W")

# listen to Enter key
window.bind('<Return>', schedule_reminder)

window.mainloop()
