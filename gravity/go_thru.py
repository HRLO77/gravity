import glob, os
f = False
ext='pxd'
for pyx in glob.glob('./*.'+ext):
    if '_1' in pyx:
        f = True
        pass
    else:
        continue
    os.rename(pyx, '.'+pyx.rsplit('.')[1][:-2]+'.'+ext)

if f:
    exit()
for pyx in glob.glob('./*.'+ext):
    if '_1' in pyx:
        continue
    os.rename(pyx, '.'+pyx.rsplit('.')[1]+'_1.'+ext)