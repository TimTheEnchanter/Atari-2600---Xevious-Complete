import sys,random,collections; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2])
e=Emu(rom); b=e.bus; marks=[]
S=emu.Bus.__setitem__
def s(bus,a,v):
    if (a&0x1FFF)<0x80 and not(a&0x80) and (a&0x3F)==0 and v&2 and not bus.vs: marks.append(bus.cyc)
    S(bus,a,v)
emu.Bus.__setitem__=s
b.swchb=0xCA; e.frame(5); b.swchb=0xCB; random.seed(5)
for f in range(N):
    if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; b.fire=random.choice((0,0x80))
    e.frame()
d=collections.Counter((marks[i+1]-marks[i]+38)//76 for i in range(5,len(marks)-1))
print(sys.argv[1],dict(sorted(d.items())))
