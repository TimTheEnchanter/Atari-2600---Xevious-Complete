import sys, shutil, os, ale_py, numpy as np
rom=sys.argv[1]; mode=sys.argv[2]
os.makedirs('/tmp/sc'+mode,exist_ok=True); shutil.copy(rom,'/tmp/sc'+mode+'/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/sc'+mode+'/pong.bin'); a.reset_game()
for f in range(30): a.act(0)
res=[]
for v in range(0,256,4):
    cols=set()
    for k in range(4):
        a.setRAM(0xCF-0x80,v); a.setRAM(0x85-0x80,4); a.act(0)
        im=a.getScreenRGB().astype(int); ram=a.getRAM()
        if ram[0xCF-0x80]!=v: break
        m=(abs(im[:,:,0]-im[:,:,1])<8)&(abs(im[:,:,1]-im[:,:,2])<8)&(im[:,:,0]>90)
        # stem rows: look at bottom region rows 110..190, take column histogram
        ys,xs=np.nonzero(m[110:200])
        cols|=set(xs.tolist())
    res.append((v,min(cols) if cols else None,max(cols) if cols else None))
print(res)
