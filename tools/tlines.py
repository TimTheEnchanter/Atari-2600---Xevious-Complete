import sys,collections; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); sym={}
for l in open(sys.argv[2]):
    p=l.split()
    if len(p)>=2:
        try: sym[p[0]]=int(p[1],16)
        except: pass
e=Emu(rom); b=e.bus; m=e.m; b.swchb=0x0B
e.frame(40)
watch={sym[k]:k for k in ('TFrame','T48Pos','T48Draw','T_Idle') if k in sym}
f0=None; S=emu.Bus.__setitem__; st={'vs':None}
def s(bus,a,v):
    if (a&0x1FFF)<0x80 and not(a&0x80) and (a&0x3F)==0 and v&2 and not bus.vs: st['vs']=bus.cyc
    S(bus,a,v)
emu.Bus.__setitem__=s
tgt=b.frames+2; seen=[]
while b.frames<tgt:
    if b.bank==0 and m.pc in watch and st['vs'] is not None and b.frames==tgt-1:
        seen.append((watch[m.pc],(b.cyc-st['vs'])//76,(b.cyc-st['vs'])%76))
    c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
for x in seen: print(x)
print('T48Draw',hex(sym['T48Draw']),'T48Pos',hex(sym['T48Pos']))
