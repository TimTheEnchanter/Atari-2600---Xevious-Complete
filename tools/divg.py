import sys,random; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
A=open(sys.argv[1],'rb').read(); B=open(sys.argv[2],'rb').read(); N=int(sys.argv[3]); swb=int(sys.argv[4],16)
ea,eb=Emu(A),Emu(B)
for e in (ea,eb): e.bus.swchb=swb&~1
random.seed(7)
for f in range(N):
    if f==5:
        for e in (ea,eb): e.bus.swchb=swb
    if f%8==0:
        j=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; fi=random.choice((0,0x80))
        for e in (ea,eb): e.bus.swcha=j; e.bus.fire=fi
    ea.frame(); eb.frame()
    if f>=N-4:
        for e in (ea,eb): print(f,'80=%02X A5=%02X A6=%02X D6=%02X D4=%02X D3=%02X'%tuple(e.ram(a) for a in (0x80,0xA5,0xA6,0xD6,0xD4,0xD3)),'T',' '.join('%02X'%e.ram(0xA7+i) for i in range(12)),'X',' '.join('%02X'%e.ram(0xBF+i) for i in range(12)))
