# Build bank 1 as a relabelled copy of the (patched) bank 3 kernel bank.
import re
S='/home/claude/xevious/src/'
t=open(S+'bank3_orig1.asm').read()
t=t.replace('SEG bank3','SEG bank1').replace('ORG $3000','ORG $1000').replace('; BANK 3  (original bank 1, runs at $B000)','; BANK 1  (new kernel bank; started as a copy of bank 3)')
t=re.sub(r'\b([LD])(B[0-9A-F]{3})\b',r'K\1\2',t)          # LB01E -> KLB01E, DBA00 -> KDBA00
t=re.sub(r'\bFREE_(B[0-9A-F]{3})\b',r'KFREE_\1',t)
# trampoline landing for bank 2's FAR_KERNEL slot ($FFEF: STA SEL1 -> bank 1 continues at offset $FF2)
old_free=re.search(r'KFREE_BFB4.*?; end free BFB4\n',t,re.S).group(0)
new_free="""KFREE_BFB4	; ---- unused space (68 bytes) ----
	DS.B $BFF2-., 0
	JMP    KLB01E                ; $FFF2 (offset) = landing for bank 2 FAR_KERNEL
	DS.B $BFF8-., 0
; end free BFB4
"""
t=t.replace(old_free,new_free)
# ship band hook + move Tod's junk timing RMWs off $E7 (now a span variable) to unused TIA $2D
t=t.replace('\tLDA    #$B0                  ; B2A2\n\tJMP    KLB2C2                 ; B2A4\n','\tJMP    $BDC4                 ; B2A2 -> SHIPDET (shipk.asm)\n\tNOP\n\tNOP\n')
for a in ('B215','B217','B21C','B21E','B220','B222','B224'):
    t=re.sub(r'(\t(?:INC|DEC|STA)\s+)\$E7(\s+; '+a+')',r'\g<1>$2D\2',t)
t=t.replace('\tJMP    $F006                 ; B284','\tJMP    $BDB0                 ; B284 -> POSTK (shipk.asm)')
assert 'JMP    $BDB0' in t
assert 'JMP    $BDC4' in t and t.count('$2D ')+t.count('$2D\t')>=1
open(S+'bank1.asm','w').write(t)
