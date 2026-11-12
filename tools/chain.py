import sys; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
rom=open(sys.argv[1],'rb').read(); FR=int(sys.argv[2]); lo,hi=int(sys.argv[3]),int(sys.argv[4])
E=Emu(rom); b=E.bus; m=E.m
b.swchb=0xCA; E.frame(5); b.swchb=0xCB; E.frame(FR)
f0=None; out=[]; t=b.frames+1; prevind=False
while b.frames<t:
    if b.vs and f0 is None: pass
    pc=m.pc; op=b.rom[b.bank*4096+(pc&0xFFF)]
    c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
    if op==0x6C:
        out.append((b.cyc,m.pc))
# frame start = last vsync; approximate: lines relative to first WSYNC-count reset
base=out[0][0]
import collections
d=collections.OrderedDict()
fs=[x for x in out]
# compute line numbers relative to vsync start via bus.frame_lines unavailable; use cycle/76 relative to frame start cycle
