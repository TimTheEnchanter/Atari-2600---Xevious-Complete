import sys,subprocess,os
sys.path.insert(0,'/home/claude/tools'); from patches import P
X='/home/claude/xevious'; S=X+'/src'
s=open(X+'/xevious.asm').read()
head,rest=s.split('\n;'+'='*70+'\n; BANK 0',1)
b0,b1=('; BANK 0'+rest).split(';'+'='*70+'\n; BANK 1',1)
b0=b0.replace('\tORG $0000','\tORG $2000').replace('SEG bank0','SEG bank2').replace('; BANK 0  (runs at $F000)','; BANK 2  (original bank 0, runs at $F000)')
b1=('; BANK 1'+b1).replace('\tORG $1000','\tORG $3000').replace('SEG bank1','SEG bank3').replace('; BANK 1  (runs at $B000)','; BANK 3  (original bank 1, runs at $B000)')
files={'equates.asm':head.replace('\tprocessor 6502\n','')+'\n','bank2_orig0.asm':';'+'='*70+'\n'+b0,'bank3_orig1.asm':';'+'='*70+'\n'+b1}
skip=set(sys.argv[1:])
for name,f,old,new in P:
    if name in skip: continue
    assert files[f].count(old)==1, 'patch failed: '+name
    files[f]=files[f].replace(old,new)
for f,t in files.items(): open(S+'/'+f,'w').write(t)
subprocess.run(['python3','-I','/home/claude/tools/mkbank1.py'],check=True)
r=subprocess.run(['/home/claude/dasm/bin/dasm','xevious16k.asm','-f3','-o../xevious16k.a26','-l../xevious16k.lst','-s../xevious16k.sym'],cwd=S,capture_output=True,text=True)
r2=subprocess.run(['/home/claude/dasm/bin/dasm','shipk.asm','-f3','-oshipk.bin','-sshipk.sym'],cwd=S,capture_output=True,text=True); assert 'Complete' in r2.stdout, r2.stdout
rom=bytearray(open(X+'/xevious16k.a26','rb').read()); ov=open(S+'/shipk.bin','rb').read(); assert len(ov)<=0x1E7
rom[0x1D00:0x1D00+len(ov)]=ov
r3=subprocess.run(['/home/claude/dasm/bin/dasm','shiptab.asm','-f3','-oshiptab.bin'],cwd=S,capture_output=True,text=True); assert 'Complete' in r3.stdout, r3.stdout
tb=open(S+'/shiptab.bin','rb').read(); assert len(tb)==60; rom[0x1960:0x1960+60]=tb; open(X+'/xevious16k.a26','wb').write(rom)
print(r.stdout[-300:],r.stderr[-300:]); print('size',os.path.getsize(X+'/xevious16k.a26'))
