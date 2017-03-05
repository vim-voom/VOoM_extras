#!/usr/bin/env python3
'''writes calendar_outline.txt'''
# Author: Vlad Irnov  (vlad DOT irnov AT gmail DOT com)
# License: CC0, see http://creativecommons.org/publicdomain/zero/1.0/

import sys
assert sys.version_info[0] > 2
import calendar
import datetime

cal = calendar.Calendar()
years = range(2009, 2020)

with open('calendar_outline_new.txt', 'wt', encoding='ascii', newline='\n') as f:
    f.write(" vim:fdm=marker:fdl=0:\n")
    f.write(" vim:foldtext=getline(v\:foldstart).'...'.(v\:foldend-v\:foldstart):\n")
    f.write('\n')
    for year in years:
        f.write('--- %s ---{{{1\n' %year)
        f.write('\n')
        for month in range(1,13):
            monthName = datetime.date(year,month,1).strftime('%B')
            filler = '-'*(9-len(monthName))
            f.write('------ %s-%02d, %s %s---{{{2\n' %(year, month, monthName, filler))
            f.write('\n')
            for day in cal.itermonthdays(year,month):
                if day==0: continue
                weekday = datetime.date(year,month,day).strftime('%a')
                f.write('--------- %s-%02d-%02d %s ---{{{3\n' %(year, month, day, weekday))
                f.write('\n')
                f.write('jakdje aejlekjei efjeeae jweeiyy ddlc.we aeee6e3e fadkje24 &5 efefae* 8683kkjj\n'*10)
                f.write('\n\n')

# vim: fdm=manual
