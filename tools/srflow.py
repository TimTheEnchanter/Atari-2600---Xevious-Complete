import sys, time, numpy as np
import stable_retro as retro
from PIL import Image
em=retro.RetroEmulator(sys.argv[1]); shots=[int(x) for x in sys.argv[2].split(',')]; ims=[]
t=time.time()
for f in range(max(shots)+1):
    em.step()
    if f in shots: ims.append(np.repeat(em.get_screen(),2,axis=1))
print('%.1fs'%(time.time()-t))
Image.fromarray(np.concatenate(ims,axis=1)).save(sys.argv[3])
