# Recursive-descent tracer for 8K F8 ROM. Usage: trace.py rom
import sys, json
rom=open(sys.argv[1],'rb').read()
ORG={0:0xF000,1:0xB000}
# opcode table: (mnemonic, mode)
ops={}
def add(m,mode,*codes):
    for c in codes: ops[c]=(m,mode)
T="""ADC imm69 zp65 zpx75 abs6D abx7D aby79 izx61 izy71
AND imm29 zp25 zpx35 abs2D abx3D aby39 izx21 izy31
ASL acc0A zp06 zpx16 abs0E abx1E
BIT zp24 abs2C
CMP immC9 zpC5 zpxD5 absCD abxDD abyD9 izxC1 izyD1
CPX immE0 zpE4 absEC
CPY immC0 zpC4 absCC
DEC zpC6 zpxD6 absCE abxDE
EOR imm49 zp45 zpx55 abs4D abx5D aby59 izx41 izy51
INC zpE6 zpxF6 absEE abxFE
JMP abs4C ind6C
JSR abs20
LDA immA9 zpA5 zpxB5 absAD abxBD abyB9 izxA1 izyB1
LDX immA2 zpA6 zpyB6 absAE abyBE
LDY immA0 zpA4 zpxB4 absAC abxBC
LSR acc4A zp46 zpx56 abs4E abx5E
ORA imm09 zp05 zpx15 abs0D abx1D aby19 izx01 izy11
ROL acc2A zp26 zpx36 abs2E abx3E
ROR acc6A zp66 zpx76 abs6E abx7E
SBC immE9 zpE5 zpxF5 absED abxFD abyF9 izxE1 izyF1
STA zp85 zpx95 abs8D abx9D aby99 izx81 izy91
STX zp86 zpy96 abs8E
STY zp84 zpx94 abs8C
BPL rel10
BMI rel30
BVC rel50
BVS rel70
BCC rel90
BCS relB0
BNE relD0
BEQ relF0"""
for line in T.split('\n'):
    p=line.split(); m=p[0]
    for t in p[1:]:
        mode=t.rstrip('0123456789ABCDEF'); code=int(t[len(mode):],16); ops[code]=(m,mode)
for m,c in [('BRK',0),('PHP',8),('CLC',0x18),('PLP',0x28),('SEC',0x38),('RTI',0x40),('PHA',0x48),('CLI',0x58),('RTS',0x60),('PLA',0x68),('SEI',0x78),('DEY',0x88),('TXA',0x8A),('TYA',0x98),('TXS',0x9A),('TAY',0xA8),('TAX',0xAA),('CLV',0xB8),('TSX',0xBA),('INY',0xC8),('DEX',0xCA),('CLD',0xD8),('INX',0xE8),('NOP',0xEA),('SED',0xF8)]:
    ops[c]=(m,'imp')
SIZE={'imp':1,'acc':1,'imm':2,'zp':2,'zpx':2,'zpy':2,'izx':2,'izy':2,'rel':2,'abs':3,'abx':3,'aby':3,'ind':3}
def b(bank,off): return rom[bank*4096+off]
code={0:{},1:{}}  # off -> length
entries={0:set(),1:set()}; jumpTargets={0:set(),1:set()}; notes=[]
def trace(bank,off):
    stack=[off]
    while stack:
        o=stack.pop()
        while 0<=o<4096 and o not in code[bank]:
            op=b(bank,o)
            if op not in ops: notes.append(('badop',bank,o,op)); break
            m,mode=ops[op]; n=SIZE[mode]
            if o+n>4096: break
            code[bank][o]=n
            if n==3: tgt=b(bank,o+1)|b(bank,o+2)<<8
            nxt=o+n
            if mode=='abs' and m in('STA','LDA','BIT','STX','STY','LDX','LDY') and tgt&0x1FFF in (0x1FF8,0x1FF9):
                nb=(tgt&0x1FFF)-0x1FF8
                if nb!=bank:
                    jumpTargets[nb].add(nxt); entries[nb].add(nxt); trace_q.append((nb,nxt)); break
            if m=='JMP' and mode=='abs':
                if tgt&0x1000: jumpTargets[bank].add(tgt&0xFFF); o=tgt&0xFFF; continue
                notes.append(('jmpRAM',bank,o,tgt)); break
            if m=='JMP': notes.append(('jmpind',bank,o,tgt)); break
            if m=='JSR':
                if tgt&0x1000: jumpTargets[bank].add(tgt&0xFFF); stack.append(tgt&0xFFF)
                else: notes.append(('jsrRAM',bank,o,tgt))
            if mode=='rel':
                r=b(bank,o+1); r=r-256 if r>127 else r; t=nxt+r; jumpTargets[bank].add(t); stack.append(t)
            if m in('RTS','RTI','BRK'): break
            o=nxt
trace_q=[(0,0),(1,0)]
extra=json.load(open(sys.argv[2])) if len(sys.argv)>2 else []
for bk,a in extra: trace_q.append((bk,a&0xFFF))
for bk in (0,1):
    for v in (0xFFA,0xFFC,0xFFE):
        a=b(bk,v)|b(bk,v+1)<<8; trace_q.append((bk,a&0xFFF))
while trace_q:
    bk,o=trace_q.pop(); trace(bk,o)
for bk in (0,1):
    tot=sum(code[bk].values()); print('bank',bk,'code bytes',tot)
for n in notes: print(n[0],n[1],'%04X'%(ORG[n[1]]+n[2]),'%04X'%n[3] if n[0]!='badop' else hex(n[3]))
import pickle; pickle.dump((code,jumpTargets,ops,SIZE),open('/home/claude/tools/trace.pkl','wb'))
