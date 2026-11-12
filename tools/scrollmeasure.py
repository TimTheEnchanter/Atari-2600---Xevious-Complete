import sys, shutil, os, ale_py, numpy as np
rom,diff,N=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
os.makedirs('/tmp/alerom2',exist_ok=True); shutil.copy(rom,'/tmp/alerom2/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/alerom2/pong.bin'); a.setDifficulty(diff); a.reset_game()
prev=None; sh=[]
for f in range(200+N):
    a.act(0)
    im=a.getScreenRGB()[:170,20:40,1].astype(int)  # left terrain strip
    if f>=200 and prev is not None:
        best=min(range(0,8),key=lambda k: np.abs(im[20+k:150+k]-prev[20:150]).sum())
        sh.append(best)
    prev=im
print(diff,''.join(str(x) for x in sh), 'avg %.2f'%(sum(sh)/len(sh)))
