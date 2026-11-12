# Log TIA writes for one frame: line, cycle-in-line, reg, value, pc
import sys; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
NAMES="VSYNC VBLANK WSYNC RSYNC NUSIZ0 NUSIZ1 COLUP0 COLUP1 COLUPF COLUBK CTRLPF REFP0 REFP1 PF0 PF1 PF2 RESP0 RESP1 RESM0 RESM1 RESBL AUDC0 AUDC1 AUDF0 AUDF1 AUDV0 AUDV1 GRP0 GRP1 ENAM0 ENAM1 ENABL HMP0 HMP1 HMM0 HMM1 HMBL VDELP0 VDELP1 VDELBL RESMP0 RESMP1 HMOVE HMCLR CXCLR".split()
def run(rom,frames,regs,setup=None):
    E=Emu(rom); L=[]; st={'on':False,'vs':0}
    S=emu.Bus.__setitem__
    def s(b,a,v):
        if st['on'] and (a&0x1FFF)<0x80 and not (a&0x80):
            r=a&0x3F
            # account for the store's own write cycle: use current cycle
            if r<len(NAMES) and NAMES[r] in regs:
                fc=b.cyc-st['f0']; L.append((fc//76,fc%76,NAMES[r],v,E.m.pc))
        if (a&0x1FFF)<0x80 and not(a&0x80) and (a&0x3F)==0 and v&2 and not b.vs: st['f0']=b.cyc
        S(b,a,v)
    emu.Bus.__setitem__=s
    if setup: setup(E)
    else:
        E.bus.swchb=0xCA; E.frame(5); E.bus.swchb=0xCB
    E.frame(frames); st['on']=True; E.frame(1); st['on']=False
    emu.Bus.__setitem__=S
    return E,L
if __name__=='__main__':
    rom=open(sys.argv[1],'rb').read()
    E,L=run(rom,int(sys.argv[2]),set(sys.argv[3].split(',')))
    for l in L: print('%3d %2d %-6s %02X %04X'%l)
