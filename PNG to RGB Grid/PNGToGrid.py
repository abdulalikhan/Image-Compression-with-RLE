# you need the PILLOW Image Processing library
# type "pip install Pillow" to install this Python Library
from PIL import Image
print("########   ######   ########")  
print("##     ## ##    ##  ##     ##") 
print("##     ## ##        ##     ##") 
print("########  ##   #### ########")  
print("##   ##   ##    ##  ##     ##") 
print("##    ##  ##    ##  ##     ##") 
print("##     ##  ######   ########")  
print("PNG Image to RGB Grid Converter")
imgFile = input("Enter the filename of the image (with extension) to convert: ")
outputFile = input("Enter the filename of the textfile (with extension) to save to RGB grid to: ")
im = Image.open(imgFile)
pixels = list(im.getdata())
imageWidth, imageHeight = im.size
f = open(outputFile, "w")
f.write(chr(imageWidth))
f.write(chr(imageHeight))
for i in range(0, len(pixels)):
    avg = pixels[i][0]+pixels[i][1]+pixels[i][2]
    avg = round(avg/3)
    if ((i+1)%imageWidth == 0):
        print(avg)
        f.write(chr(avg))
    else:
        print(avg, end=" ")
        f.write(chr(avg))
f.close()
print("")
print('[SUCCESS] RGB grid saved to {0}'.format(outputFile))
