import sys,random; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2])
E=Emu(rom); b=E.bus; m=E.m
late=[]; st={'f0':0}; fc=[]
S=emu.Bus.__setitem__
def s(bb,a,v):
    if (a&0x1FFF)<0x80 and not (a&0x80):
        r=a&0x3F
        if r==2 and bb.cyc%76>73 and bb.bank==1: late.append((bb.cyc%76,m.pc))
        if r==0 and v&2 and not bb.vs: fc.append(bb.cyc)
    S(bb,a,v)
emu.Bus.__setitem__=s
random.seed(9); b.swchb=0xCA; E.frame(5); b.swchb=0xCB
for f in range(N):
    if f%8==0:
        b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF))|0x0F; b.fire=random.choice((0,0x80))
        b.ram[0xCF-0x80]=random.randint(0,255)
    if f%500==0: b.ram[0x87-0x80]=(f//500)%16; b.ram[0x9E-0x80]=1
    if f%1500==750: b.swchb^=0x40
    E.frame()
from collections import Counter
d=Counter(round((fc[i+1]-fc[i])/76) for i in range(len(fc)-1))
print('frame lengths',d.most_common(5)); print('late WSYNC writes',Counter((c,'%04X'%p) for c,p in late).most_common(8))
