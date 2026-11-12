import sys,random,json; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); FR=int(sys.argv[2]); seed=int(sys.argv[3])
nb=len(rom)//4096; reads={k:set() for k in range(nb)}
E=Emu(rom); b=E.bus; m=E.m
G=emu.Bus.__getitem__
def g(s,a):
    if (a&0x1000):
        pc=m.pc&0xFFF; o=a&0xFFF
        if not (pc<=o<pc+3): reads[s.bank].add(o)
    return G(s,a)
emu.Bus.__getitem__=g
random.seed(seed); b.swchb=0xCA; E.frame(5); b.swchb=0xCB if seed%2 else 0x0B
area=0
for f in range(FR):
    if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; b.fire=random.choice((0,0x80))
    if f%600==0:   # hop areas to cover all terrain/objects
        b.ram[0x87-0x80]=area%16; b.ram[0x9E-0x80]=1; area+=1
    E.frame()
json.dump({k:sorted(v) for k,v in reads.items()},open(sys.argv[4],'w')); print('done',{k:len(v) for k,v in reads.items()})
