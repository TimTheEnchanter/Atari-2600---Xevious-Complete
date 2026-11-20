import sys,random,collections; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2]); sym={}
for l in open(sys.argv[3]):
    p=l.split()
    if len(p)>=2:
        try: sym[p[0]]=int(p[1],16)
        except: pass
FIRE=sym['Fire']; e=Emu(rom); b=e.bus; m=e.m; b.swchb=0xCA; e.frame(5); b.swchb=0xCB
random.seed(5); minsp=0xFF; hr=99; fires=collections.Counter(); fired=collections.Counter(); bad=0; area=collections.Counter()
for f in range(N):
    if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; b.fire=random.choice((0,0x80))
    tgt=b.frames+1; done=False
    while b.frames<tgt:
        pc=m.pc
        if b.bank==0:
            minsp=min(minsp,m.sp)
            if pc==FIRE: fires[e.ram(0xA7+m.x)&0xFE]+=1
        if b.bank==2 and pc==0xF09E and not done:
            done=True; hr=min(hr,b.tval-(b.cyc-b.tstart)//b.tdiv)
        c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
    area[e.ram(0x87)]+=1
    if any(e.ram(0xA7+i)>0x49 for i in range(12)): bad+=1
fl=collections.Counter(b.frame_lines[5:])
print('minSP bank0 %02X'%minsp,'min headroom',hr,'lines',dict(fl),'badtypes',bad)
print('areas',dict(area)); print('Fire calls by type',dict(fires))
