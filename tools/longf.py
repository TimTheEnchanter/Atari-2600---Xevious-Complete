import sys,random,collections; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2]); sym={}
for l in open(sys.argv[3]):
    p=l.split()
    if len(p)>=2:
        try: sym[p[0]]=int(p[1],16)
        except: pass
e=Emu(rom); b=e.bus; m=e.m; marks=[]
S=emu.Bus.__setitem__
def s(bus,a,v):
    if (a&0x1FFF)<0x80 and not(a&0x80) and (a&0x3F)==0 and v&2 and not bus.vs: marks.append(bus.cyc)
    S(bus,a,v)
emu.Bus.__setitem__=s
b.swchb=0xCA; e.frame(5); b.swchb=0xCB; random.seed(5)
TF=sym['TFrame']; TI=sym['Title']; out=collections.Counter(); ex=[]
for f in range(N):
    if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; b.fire=random.choice((0,0x80))
    tgt=b.frames+1; t=0; pcs=set()
    while b.frames<tgt:
        if b.bank==0 and m.pc in (TF,TI): t|=1 if m.pc==TF else 2
        c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
    if len(marks)>=2:
        L=(marks[-1]-marks[-2]+38)//76
        if L>259:
            key=(t,e.ram(0x91)&0xA2)
            out[key]+=1
            if len(ex)<6: ex.append((f,L,t,'%02X'%e.ram(0x91)))
print(dict(out)); print(ex)
