import sys,random,time,collections; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2])
e=Emu(rom); e.bus.swchb=0xCA; e.frame(5); e.bus.swchb=0xCB
random.seed(3); seen=collections.defaultdict(collections.Counter); t=time.time()
for f in range(N):
    if f%8==0:
        e.bus.swcha=random.choice((0xFF,0x7F,0xBF))|0x0F; e.bus.fire=random.choice((0,0x80))
    e.frame()
    if f%4==0:
        a=e.ram(0x87)
        for i in range(12):
            ty=e.ram(0xA7+i)
            if ty: seen[a][ty]+=1
for a in sorted(seen): print('area',a,' '.join('%02X:%d'%(k,v) for k,v in sorted(seen[a].items())))
print('t',time.time()-t,'lives',e.ram(0x85))
