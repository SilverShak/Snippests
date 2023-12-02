from tkinter import Tk, Label, Menu, Entry, Button, StringVar, messagebox, PhotoImage
from tkinter.messagebox import showinfo
from pytube import YouTube
import os, sys

# Init global
current_directory = os.path.dirname(sys.argv[0])
status_label = None

# configs
fonts = {
    "font_name": "arial",
    "lablel_font_size": 14,
    "button_font_size": 12
}


status_message = {
    "GettingVideo": "מקבל פרטי וידאו",
    "ErrorGettingVideo": "שגיאה באיתור וידאו",
    "OutputAlreadyExists": "קובץ כבר קיים ביעד",
    "ExtractingAudio": "מחלץ אודיו",
    "Downloading": "מוריד",
    "Completed": "הורדה הסתיימה"
}

status_type = {
    "error": "red",
    "success": "green",
    "info": "black"
}

def update_status(message, type):
    status_value.set(status_message[message])
    status_label.config(fg=status_type[type])
    window.update_idletasks()
    
def download():

    video_link = url_value.get()
    
    # download
    try:
        yt = YouTube(video_link)
    except:
        update_status('ErrorGettingVideo','error')
        return
    
    # check destination
    output_path = os.path.join(current_directory, yt.title + ".mp4")
    
    if os.path.exists(output_path):
        update_status('OutputAlreadyExists','info')
        return

    # extract only audio 
    update_status('ExtractingAudio','info')
    video = yt.streams.filter(only_audio=True).first() 

    # download the file 
    update_status('Downloading','info')
    out_file = video.download(output_path=current_directory) 

    # result of success 
    update_status('Completed','success')
                  
def show_about():
    
    sys_info = {
        "version": 1.0,
        "author": "SilverShak",
        "pytube_version": "15.0.0"
    }
    
    sys_info_formatted = '\n'.join([f'{key}: {value}' for key, value in sys_info.items()])
    messagebox.showinfo("About", sys_info_formatted)

                     
# setup TK
window = Tk()

menu_bar = Menu(window)
window.config(menu=menu_bar)

# Add a command to the Help menu
menu_bar.add_command(label="אודות", command=show_about)

# get the screen dimension
window_width = 350
window_height = 180

screen_width = window.winfo_screenwidth()
screen_height = window.winfo_screenheight()

# find the center point
center_x = int(screen_width/2 - window_width / 2)
center_y = int(screen_height/2 - window_height / 2)

# set the position of the window to the center of the screen
window.geometry(f'{window_width}x{window_height}+{center_x}+{center_y}')

window.winfo_toplevel().title("Youtube Downloader")

# video url
Label(text="כתובת קישור", font=(fonts['font_name'], fonts['lablel_font_size'])).grid(row=0, column=1, sticky="EW")
url_value = Entry(width=24) # must declare seperatly than grid in order to access variable later
url_value.grid(row=1, column=1,sticky="EW")

# download button
download_image = PhotoImage(file="download.png")
Button(text="הורדה", image=download_image, command=download, bd=0, highlightthickness=0).grid(row=2, column=1, sticky="WE")

# status
status_value = StringVar()
status_label = Label(textvariable=status_value,font=(fonts['font_name'], fonts['lablel_font_size']))
status_label.grid(row=3, column=1, sticky="EW")

# listen to Enter key
window.bind('<Return>', download)

# center column #1 to entire 
window.columnconfigure(1, weight=1)

window.mainloop()


