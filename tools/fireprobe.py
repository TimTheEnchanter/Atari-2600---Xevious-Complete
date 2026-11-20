import sys,random,collections; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2]); sym={}
for l in open(sys.argv[3]):
    p=l.split()
    if len(p)>=2:
        try: sym[p[0]]=int(p[1],16)
        except: pass
still=len(sys.argv)>4
H={sym[k]:k for k in ('H_Zoshi','H_Tork','H_Toroid','H_Kapi','H_Jara','Fire')}
e=Emu(rom); b=e.bus; m=e.m; b.swchb=0xCA; e.frame(5); b.swchb=0xCB
random.seed(5); cnt=collections.Counter(); why=collections.Counter(); spawn=collections.Counter(); prev=[0]*12
for f in range(N):
    if f%8==0 and not still: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F
    if f%8==0: b.fire=random.choice((0,0x80))
    tgt=b.frames+1
    while b.frames<tgt:
        if b.bank==0 and m.pc in H:
            k=H[m.pc]; cnt[k]+=1
            if k=='Fire':
                x=m.x; below=(x-1)%12
                if below==e.ram(0xD6): why['bottom']+=1
                elif e.ram(0xA7+below): why['occupied %02X'%e.ram(0xA7+below)]+=1
                else: why['ok']+=1
        c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
    for i in range(12):
        t=e.ram(0xA7+i)
        if t in (3,6,7,8,9,0x0A,0x0E,0x12,0x1A,0x22) and prev[i] in (0,1): spawn[t]+=1
        prev[i]=t
print(dict(cnt)); print(dict(why)); print('spawns',{'%02X'%k:v for k,v in spawn.items()})
