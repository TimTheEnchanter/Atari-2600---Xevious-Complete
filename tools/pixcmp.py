import sys, shutil, os, ale_py, numpy as np
def run(rom,tag,N,diff):
    d='/tmp/pc'+tag; os.makedirs(d,exist_ok=True); shutil.copy(rom,d+'/pong.bin')
    a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
    a.setFloat('repeat_action_probability',0.0); a.setInt('frame_skip',1); a.setInt('random_seed',1)
    a.loadROM(d+'/pong.bin'); a.setDifficulty(diff); a.reset_game()
    out=[]
    for f in range(N):
        a.act([0,1,3,4,11,12][(f//23)%6])
        if f%600==0:   # hop areas so all terrain/objects get drawn
            a.setRAM(0x87-0x80,(f//600)%16); a.setRAM(0x9E-0x80,1)
        a.setRAM(0x85-0x80,4)
        out.append(a.getScreenRGB().copy())
    return out
A=run(sys.argv[1],'a',int(sys.argv[3]),int(sys.argv[4])); B=run(sys.argv[2],'b',int(sys.argv[3]),int(sys.argv[4]))
bad=[i for i in range(len(A)) if not np.array_equal(A[i],B[i])]
print('frames',len(A),'differing frames',len(bad),bad[:10])
