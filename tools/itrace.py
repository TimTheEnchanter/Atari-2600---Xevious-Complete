# Instruction trace with (line,cycle) for a frame range of lines. usage: itrace.py rom frames L0 L1
import sys; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
from py65.disassembler import Disassembler
rom=open(sys.argv[1],'rb').read(); FR=int(sys.argv[2]); L0,L1=int(sys.argv[3]),int(sys.argv[4])
E=Emu(rom); b=E.bus; m=E.m
b.swchb=0xCA; E.frame(5); b.swchb=0xCB; E.frame(FR)
st={'f0':None}
S=emu.Bus.__setitem__
def s(bb,a,v):
    if (a&0x1FFF)<0x80 and not(a&0x80) and (a&0x3F)==0 and v&2 and not bb.vs: st['f0']=bb.cyc
    S(bb,a,v)
emu.Bus.__setitem__=s
while st['f0'] is None:
    c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
dis=Disassembler(m)
t=b.frames+1
while b.frames<t:
    fc=b.cyc-st['f0']; L=fc//76
    if L0<=L<=L1:
        n,txt=dis.instruction_at(m.pc)
        print('%3d %2d %d:%04X %s'%(L,fc%76,b.bank,m.pc,txt))
    c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
    if fc//76>L1: break
