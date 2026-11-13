import sys, shutil, os, ale_py, numpy as np
from PIL import Image
rom,out=sys.argv[1],sys.argv[2]; co,fi=int(sys.argv[3]),int(sys.argv[4],16)
os.makedirs('/tmp/ss',exist_ok=True); shutil.copy(rom,'/tmp/ss/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/ss/pong.bin'); a.reset_game()
ims=[]
for f in range(64):
    a.setRAM(0x92-0x80,co); a.setRAM(0x93-0x80,fi); a.setRAM(0x85-0x80,4); a.act(0)
    if f>=60: ims.append(np.repeat(a.getScreenRGB(),2,axis=1))
Image.fromarray(np.concatenate(ims,axis=1)).save(out)
