import sys,collections; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); sym={}
for l in open(sys.argv[2]):
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
TF=sym['TFrame']
def run(n,label):
    st=collections.Counter(); intitle=0
    for f in range(n):
        tgt=b.frames+1; t=False
        while b.frames<tgt:
            if b.bank==0 and m.pc==TF: t=True
            c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
        intitle+=t
    L=[(marks[i+1]-marks[i]+38)//76 for i in range(len(marks)-n-1,len(marks)-1)]
    print('%-22s frames %4d title %4d 91=%02X 93=%02X 87=%02X lines %s'%(label,n,intitle,e.ram(0x91),e.ram(0x93),e.ram(0x87),dict(collections.Counter(L))))
b.swchb=0x0B; b.fire=0x80; b.swcha=0xFF
run(300,'power-on idle')
b.swchb=0x09; run(80,'select held'); b.swchb=0x0B
run(400,'idle -> demo')
run(1700,'demo')
b.fire=0x00; run(3,'fire in demo'); b.fire=0x80; run(20,'released')
b.fire=0x00; run(30,'fire on title')
b.fire=0x80; run(200,'game')
print('lives',e.ram(0x85),'area',e.ram(0x87))
