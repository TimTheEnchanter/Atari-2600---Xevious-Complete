import sys, shutil, os, ale_py, numpy as np
from PIL import Image
rom,out=sys.argv[1],sys.argv[2]
os.makedirs('/tmp/ar',exist_ok=True); shutil.copy(rom,'/tmp/ar/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/ar/pong.bin'); a.setDifficulty(0); a.reset_game()
for f in range(60): a.act(0)
d=open(rom,'rb').read(); base=len(d)-8192
for k,v in ((0x87,5),(0x96,d[base+0x9FD+5]),(0x95,d[base+0x9ED+5]),(0x9E,1),(0xA0,0)): a.setRAM(k-0x80,v)
shots=[]; f=0; seen=set()
while f<6000 and len(shots)<10:
    act=3 if (f//40)%2 else 4
    a.act(act); f+=1
    ram=a.getRAM()
    if ram[0x11]&2:
        a.setRAM(0x85-0x80,4)   # keep lives
        b3=ram[0xB3-0x80]
        if b3 not in seen or (f%37==0 and len(shots)<10):
            seen.add(b3); shots.append((b3,a.getScreenRGB().copy()))
print('frame',f,'frames captured',[s[0] for s in shots])
ims=[np.repeat(s[1][0:120,40:130],3,axis=0).repeat(3,axis=1) for s in shots[:8]]
Image.fromarray(np.concatenate(ims,axis=1)).save(out)
