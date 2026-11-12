import sys, shutil, os, ale_py, numpy as np
rom=sys.argv[1]
os.makedirs('/tmp/sx',exist_ok=True); shutil.copy(rom,'/tmp/sx/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/sx/pong.bin'); a.setDifficulty(3); a.reset_game()
def shipcols():
    im=a.getScreenRGB().astype(int); ram=a.getRAM()
    # ship color: gray pixels (r==g==b, >100) in lower area
    m=(abs(im[:,:,0]-im[:,:,1])<8)&(abs(im[:,:,1]-im[:,:,2])<8)&(im[:,:,0]>90)
    ys,xs=np.nonzero(m[100:185]); return (xs.min(),xs.max(),ram[0xCF-0x80],ram[0xBB-0x80]) if len(xs) else None
for name,act in (('left',4),('right',3)):
    for f in range(400): a.setRAM(0x85-0x80,4); a.act(act)
    print(name,[shipcols() for _ in range(2) if not a.act(act)])
