import sys,random; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2]); watch=int(sys.argv[3],16)
e=Emu(rom); e.bus.swchb=0xCA; e.frame(5); e.bus.swchb=0xCB
random.seed(3); b=e.bus; m=e.m
mins={}; minall=0xFF; atw=set(); A5=[];BB=set()
for f in range(N):
    if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF))|0x0F; b.fire=random.choice((0,0x80))
    tgt=b.frames+1
    while b.frames<tgt:
        if b.bank==2 and m.pc==watch: atw.add(m.sp); A5.append((e.ram(0xA5)>>1, e.ram(0xBB)))
        if b.bank==2: minall=min(minall,m.sp)
        c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
print('min SP in bank2 logic %02X'%minall,'SP at watch',sorted('%02X'%x for x in atw))
print('E7 range',min(a for a,_ in A5),max(a for a,_ in A5),'BB range',min(b for _,b in A5),max(b for _,b in A5))
