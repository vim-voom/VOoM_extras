"""Convert test_outline.txt to other markups."""
import sys
# Path to directory with voom_mode_*.py files. Convertion to some
# markups requires importing stuff from corresponding voom_mode_* files.
VOOM_DIR = 'D:/HOME/vimfiles/autoload/voom'
if not VOOM_DIR in sys.path:
    sys.path.append(VOOM_DIR)
# Path to input file to convert.
INP = 'test_outline.txt'

#---------------------------------------------------------------------
import re
MARKER = '{{{'                         # }}}
MARKER_RE = re.compile(r'{{{(\d+)')    # }}}


def convert(inpFile, make_head, ext, modeName, note='', maxLevel=None): #{{{1
    lines = []
    f = open(inpFile)
    for line in f:
        m = MARKER_RE.search(line)
        if not m:
            lines.append(line)
            continue
        new_lines = make_head(line, m)
        lines.extend(new_lines)
    f.close()

    # replace first two lines
    lines[0] = '  :Voom %s\n' %modeName
    lines[1] = '  This is VOoM markup mode test file. Converted from **%s**.\n' %inpFile
    if note:
        lines[2:2] = ['  NOTE: %s\n' %note]

    # edit line with VO.levels = [...] -- set levels exceeding maxLevel to maxLevel
    if maxLevel:
        idx = None
        for i in xrange(len(lines)):
            if "ID_LEVELS VO.levels=[1" in lines[i]:
                idx = i
                break
        if idx:
            line = lines[idx]
            part1, part2 = line.split('ID_LEVELS VO.levels=')
            levs = part2.strip().strip('[]').split(',')
            new_levs = []
            for i in levs:
                j = int(i.strip())
                if j > maxLevel:
                    new_levs.append('%s' %maxLevel)
                else:
                    new_levs.append('%s' %j)
            lines[idx] = part1 + 'ID_LEVELS VO.levels=[' + ', '.join(new_levs) + ']\n'


    fOut = open(inpFile[:-3] + ext, 'wb')
    fOut.write(''.join(lines))
    fOut.close()


def make_head_fmr2(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    e = line[m.start():].strip()
    return ['%s   %s\n' %(e,head)]


def make_head_wiki(line,m): #{{{1
    lev = int(m.group(1))
    e = '='*lev
    head = line[:m.start()].strip().strip('-=~').strip()
    head = head.replace('<', '&lt;').replace('>', '&gt;')
    part2 = line[m.start():].strip().replace('<', '&lt;').replace('>', '&gt;')
    return ['%s %s %s <!--%s-->\n' %(e,head,e, part2)]


def make_head_vimwiki(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    e = '='*lev
    return ['%s %s %s\n' %(e,head,e)]


def make_head_dokuwiki(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    # Max possible level is 5.
    if lev >=5:
        e = '=='
    else:
        e = '='*(7-lev)
    return ['%s %s %s\n' %(e,head,e)]


def make_head_dokuwiki3(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    # Max possible level is 3 instead of actual 5.
    if lev >=3:
        e = '===='
    else:
        e = '='*(7-lev)
    return ['%s %s %s\n' %(e,head,e)]


def make_head_inverseAtx(line,m): #{{{1
    # For testing purposes the max possible level is 10:
    #   @@@@@@@@@@ Healdine level1
    #   @ Headline level 10
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    if lev >=10:
        e = '@'
    else:
        e = '@'*(11-lev)
    return ['%s %s\n' %(e,head)]


def make_head_txt2tags(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    if lev < 3: e = '='*lev
    else:       e = '+'*lev
    return [' %s %s %s[ref]\n' %(e,head,e)]


def make_head_org(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    e = '*'*lev
    return ['%s %s\n' %(e,head)]


def make_head_hashes(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    e = '#'*lev
    return ['%s %s\n' %(e,head)]


def make_head_cwiki(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    e = '+'*lev
    return ['++%s %s\n' %(e,head)]


def make_head_html(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    head = head.replace('<', '&lt;').replace('>', '&gt;')
    part2 = line[m.start():].strip().replace('<', '&lt;').replace('>', '&gt;')
    return ['<h%s>%s</h%s> <!--%s-->\n' %(lev,head,lev, part2)]


def make_head_markdown(line,m): #{{{1
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    head = 'h' + head.replace('<', '&lt;').replace('>', '&gt;')
    z = len(unicode(head, 'utf-8', 'replace'))
    if lev==1:
        return ['%s\n' %head,
                '%s\n' %('='*z)]
    elif lev==2:
        return ['%s\n' %head,
                '%s\n' %('-'*z)]
    else:
        return ['%s %s %s\n' %('#'*lev, head, '#'*lev)]


def make_head_pandoc(line,m): #{{{1
    # same as markdown but make sure there is a blank line before each heading
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    head = 'h' + head.replace('<', '&lt;').replace('>', '&gt;')
    z = len(unicode(head, 'utf-8', 'replace'))
    if lev==1:
        return ['\n%s\n' %head,
                '%s\n' %('='*z)]
    elif lev==2:
        return ['\n%s\n' %head,
                '%s\n' %('-'*z)]
    else:
        return ['\n%s %s %s\n' %('#'*lev, head, '#'*lev)]


def make_head_asciidoc(line,m): #{{{1
    # two-line style headlines
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    head = 'h %s' %head
    #head = 'h' + head.replace('<', '&lt;').replace('>', '&gt;')
    z = len(unicode(head, 'utf-8', 'replace'))
    if lev==1:
        return [ '\n%s\n' %head,
                '%s\n' %('='*z)]
    elif lev==2:
        return ['[[X2]]\n',
                '%s\n' %head,
                '%s\n' %('-'*z)]
    elif lev==3:
        return ['[[X3]]\n',
                '[ATTR]\n',
                '%s\n' %head,
                '%s\n' %('~'*z)]
    elif lev==4:
        return [ '\n%s\n' %head,
                '%s\n' %('^'*z)]
    elif lev==5:
        return [ '\n%s\n' %head,
                '%s\n' %('+'*z)]
    else:
        return ['\n%s %s %s\n' %('='*lev, head, '='*lev)]


def make_head_asciidoc1(line,m): #{{{1
    # one-line style headlines
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    head = '%s h %s %s' %('='*lev, head, '='*lev)
    #head = 'h' + head.replace('<', '&lt;').replace('>', '&gt;')
    z = len(unicode(head, 'utf-8', 'replace'))
    if lev==2:
        return ['[[X2]]\n',
                '%s\n' %head]
    elif lev==3:
        return ['[[X3]]\n',
                '[ATTR]\n',
                '%s\n' %head]
    else:
        return ['\n%s\n' %head]


def make_head_asciidoc3(line,m): #{{{1
    # a mix of one-style and two-style headlines
    # not suitable for some tests
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    head = 'h %s' %head
    #head = 'h' + head.replace('<', '&lt;').replace('>', '&gt;')
    z = len(unicode(head, 'utf-8', 'replace'))
    if lev==1:
        return ['\n%s\n' %head,
                '%s\n' %('='*z)]
    elif lev==2:
        return ['[[X2]]\n',
                '%s\n' %head,
                '%s\n' %('-'*z)]
    elif lev==3:
        return ['[[X3]]\n',
                '[ATTR]\n',
                '%s\n' %head,
                '%s\n' %('~'*z)]
    else:
        return ['\n%s %s %s\n' %('='*lev, head, '='*lev)]


#--- reST --- {{{1o
### reST adornment styles
# make sure they are in same order as in the voom_mode_rest.py
from voom_mode_rest import AD_STYLES
lev = 1
level_ads = {}
for ad in AD_STYLES:
    level_ads[lev] = ad
    lev+=1

def make_head_rest(line,m): #{{{2
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    #z = len(head)
    z = len(unicode(head, 'utf-8', 'replace'))
    ad = level_ads[lev]
    # don't inset headlines--screws up test suite
    # don't add trailing whitespace to overlines--screws up Right/Left test
    if len(ad)==2:
        return ['%s\n' %(ad[0]*z),
                '%s    \n' %head,
                '%s\n' %(ad[0]*z)]
    else:
        return ['\n%s  \n' %head,
                '%s\n' %(ad*z)]


#--- LaTeX, DTX --- {{{1o
from voom_mode_latex import LEVS_SECTS
from voom_mode_latex import SECTIONS

def make_head_latex(line,m): #{{{2
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    sect = LEVS_SECTS.get(lev, SECTIONS[-1])
    return ['\n%s{%s}\n' %(sect, head)]

def make_head_dtx(line,m): #{{{2
    lev = int(m.group(1))
    head = line[:m.start()].strip().strip('-=~').strip()
    sect = LEVS_SECTS.get(lev, SECTIONS[-1])
    return ['\n%% %s{%s}\n' %(sect, head)]


def convert_to_otl(inpFile, ext, modeName): #{{{1
    lines = []
    lev = 1
    f = open(inpFile)
    for line in f:
        m = MARKER_RE.search(line)
        if not m:
            line = line.strip()
            if not line:
                lines.append('\n')
                continue
            lines.append('%s| %s\n' %('\t'*(lev-1), line))
            continue
        lev = int(m.group(1))
        head = line[:m.start()].strip().strip('-=~').strip()
        # VimOutliner interprets leading < as body text
        head = head.replace('<', '\\<')
        lines.append('%s%s\n' %('\t'*(lev-1), head))
    f.close()

    # replace first two lines
    lines[0] = '|  :Voom %s\n' %modeName
    lines[1] = '|  This is VOoM markup mode test file. Converted from "%s".\n' %inpFile

    fOut = open(inpFile[:-3] + ext, 'wb')
    fOut.write(''.join(lines))
    fOut.close()


def convert_to_taskpaper(inpFile, ext, modeName): #{{{1
    lines = []
    lev = 1
    f = open(inpFile)
    for line in f:
        m = MARKER_RE.search(line)
        if not m:
            line = line.strip()
            if not line:
                lines.append('\n')
                continue
            lines.append('%s%s\n' %('\t'*lev, line))
            continue
        lev = int(m.group(1))
        head = line[:m.start()].strip().strip('-=~').strip()
        #head = head.replace('<', '\\<')
        if lev==1:
            head = '%sProject %s:\n' %('\t'*(lev-1), head)
        else:
            head = '%s- %s\n' %('\t'*(lev-1), head)
        lines.append(head)
    f.close()

    # replace first two lines
    lines[0] = '  :Voom %s\n' %modeName
    lines[1] = '  This is VOoM markup mode test file. Converted from "%s".\n' %inpFile

    fOut = open(inpFile[:-3] + ext, 'wb')
    fOut.write(''.join(lines))
    fOut.close()


#--- _main_ --- {{{1
if __name__=='__main__':
    convert(INP, make_head_fmr2, 'fmr2', 'fmr2')
    convert(INP, make_head_wiki, 'wiki', 'wiki',
            note='MediaWiki format, with fold markers')
    convert(INP, make_head_vimwiki, 'vimwiki', 'vimwiki')
    convert(INP, make_head_org, 'org', 'org')
    convert(INP, make_head_hashes, 'hashes', 'hashes')
    convert(INP, make_head_cwiki, 'cwiki', 'cwiki')
    convert(INP, make_head_txt2tags, 't2t', 'txt2tags')
    convert(INP, make_head_html, 'html', 'html')
    convert(INP, make_head_markdown, 'markdown', 'markdown')
    convert(INP, make_head_pandoc, 'pandoc', 'pandoc')
    convert(INP, make_head_asciidoc, 'asciidoc', 'asciidoc')
    convert(INP, make_head_asciidoc1, 'asciidoc1', 'asciidoc')
    convert(INP, make_head_asciidoc3, 'asciidoc3', 'asciidoc')
    convert(INP, make_head_rest, 'rst', 'rest',
            note='no gotchas, suitable for test suite')
    convert(INP, make_head_latex, 'latex', 'latex',
            note='sections only')
    convert(INP, make_head_dtx, 'dtx', 'dtx',
            note='sections only')
    convert_to_otl(INP, 'otl', 'thevimoutliner')
    convert_to_taskpaper(INP, 'taskpaper', 'taskpaper')
    convert(INP, make_head_dokuwiki, 'dokuwiki', 'dokuwiki',
            note='maxLevel=5, test Right/Left/Right fails',
            maxLevel=5)
    convert(INP, make_head_dokuwiki3, 'dokuwiki3', 'dokuwiki',
            note='maxLevel=3 to make test Right/Left/Right pass',
            maxLevel=3)
    convert(INP, make_head_inverseAtx, 'inverseAtx', 'inverseAtx',
            note="let g:voom_inverseAtx_max = 10 | let g:voom_inverseAtx_char = '@'")
