import sys,random,collections; sys.path.insert(0,'/home/claude/tools')
from emu import Emu
rom=open(sys.argv[1],'rb').read(); N=int(sys.argv[2]); seed=int(sys.argv[3]) if len(sys.argv)>3 else 3
W=int(sys.argv[4],16) if len(sys.argv)>4 else 0xF09E
e=Emu(rom); b=e.bus; m=e.m; b.swchb=0xCA; e.frame(5); b.swchb=0xCB
random.seed(seed); H=collections.defaultdict(collections.Counter); air=0
for f in range(N):
    if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; b.fire=random.choice((0,0x80))
    tgt=b.frames+1; done=False; air=0
    while b.frames<tgt:
        pc=m.pc
        if b.bank==2 and pc==0xF3D6: air+=1
        if b.bank==2 and pc==W and not done:
            done=True; v=b.tval-(b.cyc-b.tstart)//b.tdiv
            H[(air,e.ram(0x80)&3, e.ram(0x97)!=0)][v]+=1
        c=m.processorCycles; m.step(); b.cyc+=m.processorCycles-c
for k in sorted(H): print(k, sorted(H[k].items()))
