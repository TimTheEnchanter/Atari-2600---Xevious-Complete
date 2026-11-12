# ALE (Stella) screenshot harness. usage: shots.py rom outprefix startframe count [diff]
import sys, shutil, os, ale_py, numpy as np
from PIL import Image
rom,pre,start,cnt=sys.argv[1],sys.argv[2],int(sys.argv[3]),int(sys.argv[4]); diff=int(sys.argv[5]) if len(sys.argv)>5 else 0
os.makedirs('/tmp/alerom',exist_ok=True); shutil.copy(rom,'/tmp/alerom/pong.bin')
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1)
a.loadROM('/tmp/alerom/pong.bin'); a.setDifficulty(diff); a.reset_game()
acts=[0,1,3,4,11,12]
import random; random.seed(1)
imgs=[]
for f in range(start+cnt):
    act = 1 if f%30<3 else (3 if (f//60)%2 else 4)
    a.act(act)
    if f>=start: imgs.append(a.getScreenRGB().copy())
W=imgs[0].shape[1]; H=imgs[0].shape[0]
cols=min(cnt,6); rows=(cnt+cols-1)//cols
sheet=np.zeros((rows*H,cols*W*2,3),np.uint8)
for i,im in enumerate(imgs):
    r,c=divmod(i,cols); sheet[r*H:(r+1)*H,c*W*2:(c+1)*W*2]=np.repeat(im,2,axis=1)
Image.fromarray(sheet).save(pre+'.png'); print(a.getAvailableDifficulties(), sheet.shape)
