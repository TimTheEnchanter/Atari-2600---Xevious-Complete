import sys,random; sys.path.insert(0,'/home/claude/tools')
import tialog
def get(romf,target):
    rom=open(romf,'rb').read()
    def setup(E):
        b=E.bus; b.swchb=0xCA; E.frame(5); b.swchb=0xCB; random.seed(5)
        for f in range(target):
            if f%8==0: b.swcha=random.choice((0xFF,0x7F,0xBF,0xDF,0xEF,0x5F,0x9F))|0x0F; b.fire=random.choice((0,0x80))
            E.frame()
    E,L=tialog.run(rom,0,{'WSYNC'},setup)
    return [(l[0],l[1],l[4]) for l in L]
A=get(sys.argv[1],int(sys.argv[3])); B=get(sys.argv[2],int(sys.argv[3]))
for i,(a,b) in enumerate(zip(A,B)):
    if a[0]!=b[0]:
        print('first line divergence at WSYNC #%d'%i); 
        for k in range(max(0,i-6),i+3): print(A[k],'|',B[k])
        break
