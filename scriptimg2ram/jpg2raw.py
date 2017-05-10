# UECC ferney beltran 2016
import os, sys
import Image

im = Image.open("/media/lexuil/Ubuntu Data/Codigos/LVDS2/scriptimg2ram/image7.jpg")

tam= [640, 480]
pix = im.load()
print "size: ", im.size

# Write data to a file

print "Wait ... generating image"

nfileR = '/media/lexuil/Ubuntu Data/Codigos/LVDS2/scriptimg2ram/imageR.mem'
nfileG = '/media/lexuil/Ubuntu Data/Codigos/LVDS2/scriptimg2ram/imageG.mem'
nfileB = '/media/lexuil/Ubuntu Data/Codigos/LVDS2/scriptimg2ram/imageB.mem'
with open(nfileR, 'wb') as f:
    for y in range(tam[1]): 
        for x in range(tam[0]): 
            try:
                val = pix[x,y]
                f.write(format((val[0]*63)/255, '02x'))
                f.write('\n')
 
            except:
								f.write('0000FF\n')
								print "error", y,x

with open(nfileG, 'wb') as f:
    for y in range(tam[1]): 
        for x in range(tam[0]): 
            try:
                val = pix[x,y]
                f.write(format((val[1]*63)/255, '02x'))
                f.write('\n')
 
            except:
								f.write('0000FF\n')
								print "error", y,x

with open(nfileB, 'wb') as f:
    for y in range(tam[1]): 
        for x in range(tam[0]): 
            try:
                val = pix[x,y]
                f.write(format((val[2]*63)/255, '02x'))
                f.write('\n')
 
            except:
								f.write('0000FF\n')
								print "error", y,x


print 'generated -> ', nfileR
