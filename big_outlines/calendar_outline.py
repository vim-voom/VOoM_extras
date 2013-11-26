'''writes calendar_outline.txt'''
# Author: Vlad Irnov  (vlad DOT irnov AT gmail DOT com)
# License: CC0, see http://creativecommons.org/publicdomain/zero/1.0/

import calendar
import datetime
import sys
cal = calendar.Calendar()
years = range(2009, 2020)

fOut = open('calendar_outline.txt', 'wb')
sys.stdout_ = sys.stdout
sys.stdout = fOut

print " vim:fdm=marker:fdl=0:"
print " vim:foldtext=getline(v\:foldstart).'...'.(v\:foldend-v\:foldstart):"
print

for year in years:
    print '--- %s ---{{{1' %year
    print
    for month in range(1,13):
        monthName = datetime.date(year,month,1).strftime('%B')
        filler = '-'*(9-len(monthName))
        print '------ %s-%02d, %s %s---{{{2' %(year, month, monthName, filler)
        print
        for day in cal.itermonthdays(year,month):
            if day==0: continue
            weekday = datetime.date(year,month,day).strftime('%a')
            print '--------- %s-%02d-%02d %s ---{{{3' %(year, month, day, weekday)
            print
            print 'jakdje aejlekjei efjeeae jweeiyy ddlc.we aeee6e3e fadkje24 &5 efefae* 8683kkjj\n'*10
            print

fOut.close()
sys.stdout = sys.stdout_

