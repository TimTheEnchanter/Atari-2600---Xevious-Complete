# Compare RAM frame-by-frame between two ROMs under identical scripted random input.
import sys,random; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
A=open(sys.argv[1],'rb').read(); B=open(sys.argv[2],'rb').read(); N=int(sys.argv[3]); swb=int(sys.argv[4],16) if len(sys.argv)>4 else 0xCB
ignore=set(int(x,16) for x in sys.argv[5].split(',')) if len(sys.argv)>5 and sys.argv[5] else set()
ea,eb=Emu(A),Emu(B)
for e in (ea,eb): e.bus.swchb=swb&~1
random.seed(7); first=None; diffs=0
for f in range(N):
    if f==5:
        for e in (ea,eb): e.bus.swchb=swb
    if f%8==0:
        j=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; fi=random.choice((0,0x80))
        for e in (ea,eb): e.bus.swcha=j; e.bus.fire=fi
    ea.frame(); eb.frame()
    d=[0x80+i for i in range(128) if ea.bus.ram[i]!=eb.bus.ram[i] and 0x80+i not in ignore and i<0x7A]
    if d:
        diffs+=1
        if first is None: first=(f,d)
print('frames',N,'frames with RAM diffs',diffs,'first',first and (first[0],' '.join('%02X'%x for x in first[1][:12])))
