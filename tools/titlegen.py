# Generate src/titledata.inc for the M5 title screen (bank 0).
# Logo: original chunky playfield lettering (not the arcade logo), 7 rows x 40 PF columns.
# Text: 3x5 font in 4-px cells, two chars per 8-px sprite cell, rows doubled (10 lines).
# Score uses Tod's 8-px digit font (bank 2 $FF24, 7 rows) doubled; copyright is Tod's strip
# bitmap ("(c)1983 ATARI", bank 2 $FEEA..) doubled. Blocks never cross a page ((ind),Y timing).
import sys
ROM = sys.argv[1]; OUT = sys.argv[2]
rom = open(ROM, 'rb').read(); b2 = rom[0x2000:0x3000]

LOGO = {
 'X': ["#...#","#...#",".#.#.","..#..",".#.#.","#...#","#...#"],
 'E': ["#####","#....","#....","####.","#....","#....","#####"],
 'V': ["#...#","#...#","#...#","#...#",".#.#.",".#.#.","..#.."],
 'I': ["###",".#.",".#.",".#.",".#.",".#.","###"],
 'O': [".###.","#...#","#...#","#...#","#...#","#...#",".###."],
 'U': ["#...#","#...#","#...#","#...#","#...#","#...#",".###."],
 'S': [".####","#....","#....",".###.","....#","....#","####."],
}
rows = ['.'] * 7
rows = ['.' for _ in range(7)]
for i, ch in enumerate("XEVIOUS"):
    for r in range(7):
        rows[r] += LOGO[ch][r] + ('.' if i < 6 else '')
rows = [r.ljust(40, '.') for r in rows]
assert all(len(r) == 40 for r in rows)

def pf(cols):  # 20 columns -> PF0, PF1, PF2 (non-reflected)
    c = [ch == '#' for ch in cols]
    p0 = sum(1 << (4 + i) for i in range(4) if c[i])
    p1 = sum(1 << (7 - i) for i in range(8) if c[4 + i])
    p2 = sum(1 << i for i in range(8) if c[12 + i])
    return p0, p1, p2

tabs = {k: [] for k in ('LgL0', 'LgL1', 'LgL2', 'LgR0', 'LgR1', 'LgR2')}
for r in reversed(rows):              # kernel counts Y down: row 6 = top
    a = pf(r[:20]); b = pf(r[20:])
    for k, v in zip(('LgL0', 'LgL1', 'LgL2'), a): tabs[k].append(v)
    for k, v in zip(('LgR0', 'LgR1', 'LgR2'), b): tabs[k].append(v)

# shimmer gradient: 64-entry loop, plus 48 wrap entries (index = phase + line)
grad = [0x80, 0x82, 0x84, 0x86, 0x88, 0x8A, 0x8C, 0x8E, 0x9E, 0x0E, 0x0E, 0x1E, 0x1C, 0x1A, 0x18, 0x28,
        0x2A, 0x2C, 0x1E, 0x0E, 0x0E, 0x9E, 0x8E, 0x8C, 0x8A, 0x88, 0x86, 0x84, 0x82, 0x84, 0x86, 0x88]
grad = grad + grad
grad = grad + grad[:48]

FONT = {
 ' ': ["...", "...", "...", "...", "..."],
 'A': [".#.", "#.#", "###", "#.#", "#.#"], 'C': [".##", "#..", "#..", "#..", ".##"],
 'E': ["###", "#..", "##.", "#..", "###"], 'F': ["###", "#..", "##.", "#..", "#.."],
 'G': [".##", "#..", "#.#", "#.#", ".##"], 'I': ["###", ".#.", ".#.", ".#.", "###"],
 'M': ["#.#", "###", "###", "#.#", "#.#"], 'O': [".#.", "#.#", "#.#", "#.#", ".#."],
 'P': ["##.", "#.#", "##.", "#..", "#.."], 'R': ["##.", "#.#", "##.", "#.#", "#.#"],
 'S': [".##", "#..", ".#.", "..#", "##."], 'U': ["#.#", "#.#", "#.#", "#.#", "###"],
 'L': ["#..", "#..", "#..", "#..", "###"], 'Y': ["#.#", "#.#", ".#.", ".#.", ".#."],
 '0': ["###", "#.#", "#.#", "#.#", "###"], '1': [".#.", "##.", ".#.", ".#.", "###"],
 '2': ["##.", "..#", ".#.", "#..", "###"], '3': ["##.", "..#", ".#.", "..#", "##."],
 '4': ["#.#", "#.#", "###", "..#", "..#"], '5': ["###", "#..", "##.", "..#", "##."],
 '6': [".##", "#..", "###", "#.#", "###"], '7': ["###", "..#", ".#.", ".#.", ".#."],
 '8': ["###", "#.#", "###", "#.#", "###"], '9': ["###", "#.#", "###", "..#", "##."],
}

def cell2(a, b):                      # 2 chars -> 5 rows, top first
    out = []
    for r in range(5):
        bits = FONT[a][r] + '.' + FONT[b][r] + '.'
        out.append(sum(1 << (7 - i) for i, ch in enumerate(bits) if ch == '#'))
    return out

def dbl(rows_top_first):              # kernel draws Y = h-1 .. 0 top to bottom
    d = []
    for v in rows_top_first: d += [v, v]
    return list(reversed(d))

blocks = {}                           # name -> bytes (bottom-up, as the kernel reads)
def addcell(pair): blocks['c_' + pair.replace(' ', '_')] = dbl(cell2(pair[0], pair[1]))

STR = {  # 12 chars each
 'sGame': "GAME 1   1UP", 'sPress': " PRESS FIRE ", 'sArea': "FROM AREA 05", 'sSkill': "",
}
static_pairs = set()
for name, s in (('sGame', "GAME ?   ?UP"), ('sPress', " PRESS FIRE "), ('sArea', "FROM AREA ??")):
    for i in range(0, 12, 2):
        p = s[i:i + 2]
        if '?' not in p: static_pairs.add(p)
for p in sorted(static_pairs): addcell(p)
for n in range(1, 9): addcell(' ' + str(n))
for n in range(1, 17): addcell('%02d' % n)
# Tod's digits (bank 2 $FF24 + 7k, stored bottom-up) and copyright cells
for d in range(10):
    raw = list(b2[0xF24 + 7 * d:0xF24 + 7 * d + 7])           # bottom-up already
    blocks['d_%d' % d] = [v for v in raw for _ in (0, 1)]
cp = [b2[0xF0D + 2 * i] | b2[0xF0E + 2 * i] << 8 for i in range(6)]
for i, p in enumerate(cp):
    raw = list(b2[(p & 0xFFF):(p & 0xFFF) + 7])
    blocks['cp_%d' % i] = [v for v in raw for _ in (0, 1)]

# pack into pages (relative to a page-aligned origin)
order = sorted(blocks)
lay = {}; off = 0; data = []
for k in order:
    n = len(blocks[k])
    if (off % 256) + n > 256:
        pad = 256 - off % 256; data += [0] * pad; off += pad
    lay[k] = off; data += blocks[k]; off += n

o = []
o.append('; generated by tools/titlegen.py - do not edit')
def bytes_(name, vals, per=16):
    o.append(name)
    for i in range(0, len(vals), per):
        o.append('\t.byte ' + ','.join('$%02X' % v for v in vals[i:i + per]))
for k in ('LgL0', 'LgL1', 'LgL2', 'LgR0', 'LgR1', 'LgR2'): bytes_(k, tabs[k])
bytes_('LgCol', grad)
o.append('\tALIGN 256')
o.append('TxtBase')
for k in order: o.append('%s = TxtBase+%d' % (k, lay[k]))
bytes_('TxtData', data)
def ptrs(name, cells):
    o.append(name + 'Lo\t.byte ' + ','.join('<' + c for c in cells))
    o.append(name + 'Hi\t.byte ' + ','.join('>' + c for c in cells))
ptrs('PNum', ['c__%d' % n for n in range(1, 9)])
ptrs('PArea', ['c_%02d' % n for n in range(1, 17)])
ptrs('PDig', ['d_%d' % d for d in range(10)])
def strp(name, s):
    cells = []
    for i in range(0, 12, 2):
        p = s[i:i + 2]
        cells.append('c_' + p.replace(' ', '_') if '?' not in p else 'c___')
    ptrs(name, cells)
blocks_needed = 'c___'
if 'c___' not in blocks: pass
strp('SGame', "GAME ?   ?UP")
strp('SPress', " PRESS FIRE ")
strp('SArea', "FROM AREA ??")
ptrs('SCopy', ['cp_%d' % i for i in range(6)])
open(OUT, 'w').write('\n'.join(o) + '\n')
print('text bytes', len(data), 'blocks', len(blocks))
