import sys, shutil, os, ale_py, numpy as np, json
rom=sys.argv[1]
os.makedirs('/tmp/pc1',exist_ok=True); shutil.copy(rom,'/tmp/pc1/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/pc1/pong.bin'); a.reset_game()
for f in range(40): a.act(0)
res={}
for co in range(4):
    for fi in range(16):
        xs=[]
        for k in range(3):
            a.setRAM(0x92-0x80,co); a.setRAM(0x93-0x80,fi<<4); a.setRAM(0x85-0x80,4); a.act(0)
            im=a.getScreenRGB().astype(int)
            m=(abs(im[:,:,0]-im[:,:,1])<8)&(abs(im[:,:,1]-im[:,:,2])<8)&(im[:,:,0]>90)
            ys,x=np.nonzero(m[110:185])
            if len(x): xs.append(int(x.min()))
        res['%d,%d'%(co,fi)]=min(xs) if xs else None
json.dump(res,open('/home/claude/emu/p1cal.json','w')); print(res)
