# Reusable scripted emulator: py65 + F8/F6 banking + RIOT + stub TIA (collisions=0). For regression/RAM tracing.
from py65.devices.mpu6502 import MPU
class Bus:
    def __init__(s,rom):
        s.rom=rom; s.nb=len(rom)//4096; s.bank=0; s.ram=[0]*128; s.cyc=0; s.tstart=0; s.tdiv=1024; s.tval=0
        s.frames=0; s.vs=0; s.swcha=0xFF; s.swchb=0x0B; s.fire=0x80; s.wsync=0; s.lines=0; s.frame_lines=[]
        s.hs=0x1FF8 if s.nb==2 else (0x1FF6 if s.nb==4 else 0x1FF4)
    def timer(s):
        el=(s.cyc-s.tstart)//s.tdiv; v=s.tval-el
        if v>=0: return v
        u=(s.cyc-s.tstart)-(s.tval+1)*s.tdiv; return (-1-u)&0xFF
    def sw(s,a):
        if s.hs<=a<s.hs+s.nb: s.bank=a-s.hs
    def __getitem__(s,a):
        a&=0x1FFF
        if a&0x1000: s.sw(a); return s.rom[s.bank*4096+(a&0xFFF)]
        if a&0x80:
            if not a&0x200: return s.ram[a&0x7F]
            r=a&0x2FF
            if r&4: return s.timer()&0xFF if not r&1 else 0xC0
            return (s.swcha,0,s.swchb,0)[r&3]
        r=a&0xF
        if r<8: return 0
        if r==0xC: return s.fire
        return 0x80
    def __setitem__(s,a,v):
        a&=0x1FFF
        if a&0x1000: s.sw(a); return
        if a&0x80:
            if not a&0x200: s.ram[a&0x7F]=v&0xFF; return
            if a&0x14==0x14: s.tdiv=(1,8,64,1024)[a&3]; s.tval=v; s.tstart=s.cyc
            return
        r=a&0x3F
        if r==0x02: s.cyc+=(76-(s.cyc%76))%76; s.lines+=1
        if r==0x00:
            if v&2 and not s.vs: s.frames+=1; s.frame_lines.append(s.lines); s.lines=0
            s.vs=v&2
class Emu:
    def __init__(s,rom):
        s.bus=Bus(rom); s.m=MPU(memory=s.bus)
        s.m.pc=rom[0xFFC]|rom[0xFFD]<<8; s.cov={}
    def frame(s,n=1,cov=False):
        b=s.bus; m=s.m; tgt=b.frames+n
        while b.frames<tgt:
            if cov: s.cov.setdefault(b.bank,set()).add(m.pc&0xFFF)
            c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
    def ram(s,a): return s.bus.ram[a-0x80]
