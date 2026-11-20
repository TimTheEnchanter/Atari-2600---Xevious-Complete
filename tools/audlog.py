import sys,collections; sys.path.insert(0,'/home/claude/tools')
import emu
from emu import Emu
rom=open(sys.argv[1],'rb').read()
e=Emu(rom); b=e.bus; m=e.m
cur={}; S=emu.Bus.__setitem__
def s(bus,a,v):
    if (a&0x1FFF)<0x80 and not(a&0x80):
        r=a&0x3F
        if 0x15<=r<=0x1A: cur[r]=v
    S(bus,a,v)
emu.Bus.__setitem__=s
b.swchb=0x0A; e.frame(5); b.swchb=0x0B
log=[]
def run(n,tag,fire=lambda f:0x80):
    for f in range(n):
        b.fire=fire(f); e.frame()
        log.append((tag,cur.get(0x15,0)&15,cur.get(0x17,0)&31,cur.get(0x19,0)&15,cur.get(0x16,0)&15,cur.get(0x18,0)&31,cur.get(0x1A,0)&15,e.ram(0x98),e.ram(0x9D),e.ram(0xD3)&7))
run(200,'start')
run(60,"bomb",lambda f:0x00 if f<2 else 0x80)
e.bus.ram[0x9E-0x80]=0x15   # just before the end of area 1
run(900,"area")
def show(tag,maxn=60):
    rows=[r for r in log if r[0]==tag][:maxn]
    print('==',tag,' (c0 f0 v0 | c1 f1 v1 | snd 9D bomb)')
    prev=None
    for i,r in enumerate(rows):
        k=r[1:]
        if k!=prev: print('%3d  %2d %2d %2d | %2d %2d %2d | %2d %02X %d'%((i,)+k))
        prev=k
show("bomb"); show("area",900); print("area now",e.ram(0x87))
log.clear()
run(300,'quiet')
run(80,'bomb2',lambda f:0x00 if f<2 else 0x80)
show('bomb2',80)
log.clear()
import random; random.seed(1)
e.bus.ram[0x87-0x80]=3
run(1500,'spario',lambda f:0x00 if f%30<2 else 0x80)
print('frames with sound 4 starting:',sum(1 for i in range(1,len(log)) if log[i][7]==4 and log[i-1][7]!=4))
log.clear()
for f in range(300):
    e.bus.ram[0x91-0x80]|=0x02; b.fire=0x80; e.frame()
    log.append(('andor',cur.get(0x15,0)&15,cur.get(0x17,0)&31,cur.get(0x19,0)&15,cur.get(0x16,0)&15,cur.get(0x18,0)&31,cur.get(0x1A,0)&15,e.ram(0x98),e.ram(0x82)&0x1C,0))
show('andor',300)
