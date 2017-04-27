# UECC ferney beltran 2016
import os, sys
import Image

im = Image.open("/home/lexuil/Descargas/LVDS1/scriptimg2ram/image.jpg")

tam= [100, 100]
pix = im.load()
print "size: ", im.size

# Write data to a file

print "Wait ... generating image"

nfile = '/home/lexuil/Descargas/LVDS1/scriptimg2ram/image.mem'
with open(nfile, 'wb') as f:
    for y in range(tam[1]): 
        for x in range(tam[0]): 
            try:
                val = pix[x,y]
                f.write(format(val[0], '02x'))
                f.write(format(val[1], '02x'))
                f.write(format(val[2], '02x'))
 
            except:
								f.write('0000FF\n')
								print "error", y,x

print 'generated -> ', nfile
