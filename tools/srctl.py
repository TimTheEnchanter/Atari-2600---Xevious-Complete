# stable-retro run with a button script: list of (frames, mask-string) ; mask keys: B=fire S=select R=reset
import sys, numpy as np
import stable_retro as retro
from PIL import Image
em=retro.RetroEmulator(sys.argv[1]); out=sys.argv[2]; script=sys.argv[3]
ims=[]; idx={'B':0,'S':2,'R':3,'U':4,'D':5,'L':6,'Rt':7}
for part in script.split(';'):
    n,keys,shot=part.split(':')
    m=np.zeros(8,dtype=np.uint8)
    for k in keys.split('+'):
        if k: m[idx[k]]=1
    em.set_button_mask(m,0)
    for f in range(int(n)): em.step()
    if shot=='1': ims.append(np.repeat(em.get_screen(),2,axis=1))
Image.fromarray(np.concatenate(ims,axis=1)).save(out)
