# -*- coding: utf-8 -*-
import io, re
p = r'd:\Demo\C4jly\C4F7N_Demo\Core\Src\main.c'
ls = io.open(p, 'rb').read().decode('utf-8', 'replace').splitlines()
for i, l in enumerate(ls, 1):
    for m in re.finditer(r'"([^"]*)"', l):
        s = m.group(1)
        if any(ord(c) > 127 for c in s):
            print('%4d| %r' % (i, s))