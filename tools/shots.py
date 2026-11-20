import sys, shutil, os, ale_py, numpy as np
from PIL import Image
rom,out,start,step,n=sys.argv[1],sys.argv[2],int(sys.argv[3]),int(sys.argv[4]),int(sys.argv[5])
area=int(sys.argv[6]) if len(sys.argv)>6 else -1
os.makedirs('/tmp/ss',exist_ok=True); shutil.copy(rom,'/tmp/ss/boxing.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/ss/boxing.bin'); a.reset_game()
acts=a.getLegalActionSet(); import random; random.seed(2)
ims=[]; log=[]
for f in range(start+step*n):
    a.setRAM(0x85-0x80,4)
    if area>=0 and f<3: a.setRAM(0x87-0x80,area)
    act=acts[[1,11,12,1,0][(f//40)%5]] if f>60 else acts[0]   # fire, right+fire, left+fire
    a.act(act)
    if f>=start and (f-start)%step==0:
        ims.append(np.repeat(a.getScreenRGB(),2,axis=1)); r=a.getRAM(); log.append(' '.join('%02X'%r[0x27+i] for i in range(12)))
rows=[np.concatenate(ims[i:i+8],axis=1) for i in range(0,len(ims),8)]
Image.fromarray(np.concatenate(rows,axis=0)).save(out)
print('area',a.getRAM()[0x07]); print('\n'.join(log))
