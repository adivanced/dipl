0:  55                      push   rbp
1:  48 89 e5                mov    rbp,rsp
4:  48 89 7d e8             mov    QWORD PTR [rbp-0x18],rdi
8:  48 89 75 e0             mov    QWORD PTR [rbp-0x20],rsi
c:  48 c7 45 f0 00 00 00    mov    QWORD PTR [rbp-0x10],0x0
13: 00
14: e9 6b 01 00 00          jmp    0x184 ; L2
19: 48 8b 45 f0         L6: mov    rax,QWORD PTR [rbp-0x10]
1d: 48 8d 14 c5 00 00 00    lea    rdx,[rax*8+0x0]
24: 00
25: 48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
29: 48 01 d0                add    rax,rdx
2c: 48 8b 10                mov    rdx,QWORD PTR [rax]
2f: 48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
33: 48 8d 0c c5 00 00 00    lea    rcx,[rax*8+0x0]
3a: 00
3b: 48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
3f: 48 01 c8                add    rax,rcx
42: 48 8b 00                mov    rax,QWORD PTR [rax]
45: 48 0f af c2             imul   rax,rdx
49: 48 8b 55 f0             mov    rdx,QWORD PTR [rbp-0x10]
4d: 48 8d 0c d5 00 00 00    lea    rcx,[rdx*8+0x0]
54: 00
55: 48 8b 55 e8             mov    rdx,QWORD PTR [rbp-0x18]
59: 48 01 d1                add    rcx,rdx
5c: 48 c1 e8 02             shr    rax,0x2
60: 48 ba c3 f5 28 5c 8f    movabs rdx,0x28f5c28f5c28f5c3
67: c2 f5 28
6a: 48 f7 e2                mul    rdx
6d: 48 89 d0                mov    rax,rdx
70: 48 c1 e8 02             shr    rax,0x2
74: 48 89 01                mov    QWORD PTR [rcx],rax
77: 48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
7b: 48 83 c0 01             add    rax,0x1
7f: 48 39 45 e0             cmp    QWORD PTR [rbp-0x20],rax
83: 76 4a                   jbe    0xcf
85: 48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
89: 48 8d 14 c5 00 00 00    lea    rdx,[rax*8+0x0]
90: 00
91: 48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
95: 48 01 d0                add    rax,rdx
98: 48 8b 08                mov    rcx,QWORD PTR [rax]
9b: 48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
9f: 48 83 c0 01             add    rax,0x1
a3: 48 8d 14 c5 00 00 00    lea    rdx,[rax*8+0x0]
aa: 00
ab: 48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
af: 48 01 d0                add    rax,rdx
b2: 48 8b 00                mov    rax,QWORD PTR [rax]
b5: 48 8b 55 f0             mov    rdx,QWORD PTR [rbp-0x10]
b9: 48 8d 34 d5 00 00 00    lea    rsi,[rdx*8+0x0]
c0: 00
c1: 48 8b 55 e8             mov    rdx,QWORD PTR [rbp-0x18]
c5: 48 01 f2                add    rdx,rsi
c8: 48 0f af c1             imul   rax,rcx
cc: 48 89 02                mov    QWORD PTR [rdx],rax
cf: 48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
d3: 48 8d 14 c5 00 00 00    lea    rdx,[rax*8+0x0]
da: 00
db: 48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
df: 48 01 d0                add    rax,rdx
e2: 48 8b 00                mov    rax,QWORD PTR [rax]
e5: 48 8b 55 f0             mov    rdx,QWORD PTR [rbp-0x10]
e9: 48 c1 e2 03             shl    rdx,0x3
ed: 48 8d 4a f8             lea    rcx,[rdx-0x8]
f1: 48 8b 55 e8             mov    rdx,QWORD PTR [rbp-0x18]
f5: 48 01 ca                add    rdx,rcx
f8: 48 8b 12                mov    rdx,QWORD PTR [rdx]
fb: 48 8d 72 01             lea    rsi,[rdx+0x1]
ff: 48 8b 55 f0             mov    rdx,QWORD PTR [rbp-0x10]
103:    48 8d 0c d5 00 00 00    lea    rcx,[rdx*8+0x0]
10a:    00
10b:    48 8b 55 e8             mov    rdx,QWORD PTR [rbp-0x18]
10f:    48 01 d1                add    rcx,rdx
112:    ba 00 00 00 00          mov    edx,0x0
117:    48 f7 f6                div    rsi
11a:    48 89 01                mov    QWORD PTR [rcx],rax
11d:    48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
121:    48 83 c0 01             add    rax,0x1
125:    48 89 45 f8             mov    QWORD PTR [rbp-0x8],rax
129:    eb 4a                   jmp    0x175
12b:    48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
12f:    48 8d 14 c5 00 00 00    lea    rdx,[rax*8+0x0]
136:    00
137:    48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
13b:    48 01 d0                add    rax,rdx
13e:    48 8b 08                mov    rcx,QWORD PTR [rax]
141:    48 8b 45 f8             mov    rax,QWORD PTR [rbp-0x8]
145:    48 8d 14 c5 00 00 00    lea    rdx,[rax*8+0x0]
14c:    00
14d:    48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
151:    48 01 d0                add    rax,rdx
154:    48 8b 10                mov    rdx,QWORD PTR [rax]
157:    48 8b 45 f0             mov    rax,QWORD PTR [rbp-0x10]
15b:    48 8d 34 c5 00 00 00    lea    rsi,[rax*8+0x0]
162:    00
163:    48 8b 45 e8             mov    rax,QWORD PTR [rbp-0x18]
167:    48 01 f0                add    rax,rsi
16a:    48 01 ca                add    rdx,rcx
16d:    48 89 10                mov    QWORD PTR [rax],rdx
170:    48 83 45 f8 01          add    QWORD PTR [rbp-0x8],0x1
175:    48 8b 45 f8             mov    rax,QWORD PTR [rbp-0x8]
179:    48 3b 45 e0             cmp    rax,QWORD PTR [rbp-0x20]
17d:    72 ac                   jb     0x12b
17f:    48 83 45 f0 01          add    QWORD PTR [rbp-0x10],0x1
184:    48 8b 45 f0        L2:  mov    rax,QWORD PTR [rbp-0x10]
188:    48 3b 45 e0             cmp    rax,QWORD PTR [rbp-0x20]
18c:    0f 82 87 fe ff ff       jb     0x19 ; L6
192:    90                      nop
193:    90                      nop
194:    5d                      pop    rbp
195:    c3                      ret 