import sys
from py65.devices.mpu6502 import MPU
from py65.disassembler import Disassembler
d=open(sys.argv[1],'rb').read()
bank=int(sys.argv[2]); start=int(sys.argv[3],16); n=int(sys.argv[4])
m=MPU(); 
for i in range(4096): m.memory[0xF000+i]=d[bank*4096+i]
dis=Disassembler(m)
pc=start
for _ in range(n):
    l,s=dis.instruction_at(pc)
    print('%d:%04X  %-12s %s'%(bank,pc,' '.join('%02X'%m.memory[pc+k] for k in range(l)),s)); pc+=l
