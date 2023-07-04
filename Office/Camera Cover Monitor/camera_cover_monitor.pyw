import cv2
from tkinter import Tk
from tkinter.messagebox import showinfo

saturation_max = 20

def pop_up(text):
    pop_up_root = Tk()
    pop_up_root.withdraw()
    showinfo(title="camera alert", message=text)
    pop_up_root.destroy()

try:

    # capture media from camera
    cap = cv2.VideoCapture(0)

    # extract frame
    image = cap.read()[1]

    #if camera is unavailable
    if image is None:
        raise Exception("camera monitor failed")
    else:
        # check frame saturation
        saturation = image[:, :, 1].mean()
        if saturation > saturation_max:
            print(f"saturation is {saturation}")
            raise Exception("camera isn't covered")
        else:
            print("picture has taken and it's black so camera is covered")

# show pop-up if problem occured
except Exception as e:
    pop_up(e)
