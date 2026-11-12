# Coverage runner: py65 CPU + F8 banking + RIOT timer + stub TIA. Records executed (bank,offset).
import sys, random, json
from py65.devices.mpu6502 import MPU
rom=open(sys.argv[1],'rb').read(); FR=int(sys.argv[2]); seed=int(sys.argv[3])
random.seed(seed); NOISY=seed<100; COLL=(0,0,0,0x80,0x40,0xC0) if seed%2 else (0,)*60+(0x80,0x40,0xC0)
if seed>=200: COLL=(0,)
class Bus:
    def __init__(s):
        s.bank=0; s.ram=[0]*128; s.cyc=0; s.tstart=0; s.tdiv=1024; s.tval=0; s.frames=0; s.vs=0
        s.swcha=0xFF; s.swchb=0x0B; s.fire=0x80; s.coll=0
    def timer(s):
        el=(s.cyc-s.tstart)//s.tdiv
        v=s.tval-el
        if v>=0: return v
        # after underflow counts every cycle
        u=(s.cyc-s.tstart)-(s.tval+1)*s.tdiv
        return (-1-u)&0xFF
    def __getitem__(s,a):
        if isinstance(a,slice): return [s[i] for i in range(*a.indices(0x10000))]
        a&=0x1FFF
        if a&0x1000:
            if a in (0x1FF8,0x1FF9): s.bank=a-0x1FF8
            return rom[s.bank*4096+(a&0xFFF)]
        if a&0x80:
            if not a&0x200: return s.ram[a&0x7F]
            r=a&0x2FF
            if r&4:
                return s.timer()&0xFF if not r&1 else 0xC0
            r&=3
            return (s.swcha,0,s.swchb,0)[r]
        r=a&0xF
        if r<8: return random.choice(COLL)  # collisions
        if r==0xC: return s.fire
        return 0x80
    def __setitem__(s,a,v):
        a&=0x1FFF
        if a&0x1000:
            if a in (0x1FF8,0x1FF9): s.bank=a-0x1FF8
            return
        if a&0x80:
            if not a&0x200: s.ram[a&0x7F]=v&0xFF; return
            if a&0x14==0x14:
                s.tdiv=(1,8,64,1024)[a&3]; s.tval=v; s.tstart=s.cyc
            return
        r=a&0x3F
        if r==0x02:  # WSYNC
            s.cyc+= (76-(s.cyc%76))%76
        if r==0x00:
            if v&2 and not s.vs: s.frames+=1
            s.vs=v&2
bus=Bus(); m=MPU(memory=bus)
m.pc=rom[0xFFC]|rom[0xFFD]<<8
seen={0:set(),1:set()}; jinst={}
DUMP=[]
RL={0x87:set(),0x81:set(),0x91:set(),0xA4:set(),0x86:set()}
last=0; stepcap=FR*40000
steps=0; inp_t=0
while bus.frames<FR and steps<stepcap:
    pc=m.pc
    seen[bus.bank].add(pc&0xFFF)
    c0=m.processorCycles
    m.step(); steps+=1
    bus.cyc+=m.processorCycles-c0
    if bus.frames!=inp_t:
        inp_t=bus.frames
        for k in RL: RL[k].add(bus.ram[k-0x80])
        DUMP.append(bytes(bus.ram))
        if inp_t%8==0:
            bus.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F,0x6F,0xAF))|0x0F
            bus.fire=random.choice((0,0x80,0x80))
            bus.swchb=0x0B|random.choice((0,0,0x40,0x80,0xC0))
            if inp_t<10 or (NOISY and random.random()<0.01): bus.swchb&=~1  # reset
            elif NOISY and random.random()<0.01: bus.swchb&=~2
print('ramlog',{k:sorted(v) for k,v in RL.items()})
open(sys.argv[4]+'.ram','wb').write(b''.join(DUMP))
json.dump({str(k):sorted(v) for k,v in seen.items()},open(sys.argv[4],'w'))
print('frames',bus.frames,'steps',steps,'bank0',len(seen[0]),'bank1',len(seen[1]),'pc %04X'%m.pc)
