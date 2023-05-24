import glob, os
f = False
for pyx in glob.glob('./*.pyx'):
    if '_1' in pyx:
        f = True
        pass
    else:
        continue
    os.rename(pyx, '.'+pyx.rsplit('.')[1][:-2]+'.pyx')

if f:
    exit()
for pyx in glob.glob('./*.pyx'):
    if '_1' in pyx:
        continue
    os.rename(pyx, '.'+pyx.rsplit('.')[1]+'_1.pyx')