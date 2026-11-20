import sys, shutil, os, ale_py, numpy as np
from PIL import Image
rom,out=sys.argv[1],sys.argv[2]
os.makedirs('/tmp/ss',exist_ok=True); shutil.copy(rom,'/tmp/ss/boxing.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/ss/boxing.bin'); a.reset_game(); acts=a.getLegalActionSet()
ims=[]; f=0; got=0
while f<6000 and got<2:
    a.act(acts[[1,11,12,1,0][(f//40)%5]] if f>60 else acts[0]); f+=1
    r=a.getRAM()
    if r[0x11]&0x20:          # dying
        for k in range(32):
            if k%2==0:
                scr=a.getScreenRGB(); ims.append(np.repeat(scr[150:200],2,axis=1))
            a.act(acts[0]); f+=1
        got+=1
        while a.getRAM()[0x11]&0x20: a.act(acts[0]); f+=1
rows=[np.concatenate(ims[i:i+8],axis=1) for i in range(0,len(ims),8)]
Image.fromarray(np.repeat(np.concatenate(rows,axis=0),2,axis=0)).save(out); print('deaths',got,'frames',f)
