import sys; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); nb=len(rom)//4096; kb=1 if nb==4 else nb-1  # kernel bank
log=[]
G=emu.Bus.__getitem__
def g(s,a):
    if s.bank==kb and (a&0x1000) and EM.m.pc&0xFFF in range(0x1B4,0x1F8):
        o=a&0xFFF
        if 0xE00<=o<0xF20: log.append(o)
    return G(s,a)
emu.Bus.__getitem__=g
EM=Emu(rom); e=EM
e.bus.swchb=0x0A; e.frame(5); e.bus.swchb=0x0B; e.frame(60)
for k,v in ((0x87,5),(0x96,0x56),(0x95,0x1D),(0x9E,1),(0xA0,0)): e.bus.ram[k-0x80]=v
for f in range(3500):
    e.bus.swcha=0x7F if (f//40)%2 else 0xBF
    e.frame()
bad=sorted(set(o for o in log if 0xE00<=o<0xE20)); good=sorted(set(o for o in log if o>=0xF0B))
print(sys.argv[1].split('/')[-1],'reads total',len(log),'| from $BE0B-$BE1F (wrong):',len([o for o in log if o<0xE20]),'| from $BF0B-$BF16 (core frame 5):',len([o for o in log if 0xF0B<=o<=0xF16]))
