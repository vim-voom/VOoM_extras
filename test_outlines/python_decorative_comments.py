# This is test outline for testing VOoM python mode (:Voom python).

# Decorative comment lines are comment lines containing only # = - spaces and tabs.
# If stand-alone (separator): ignore.
# If followed by a comment headline: associate with that headline.
# To find real-life examples:
#   :cd C:\Python27\Lib
#   :vimgrep /^\s*#\s*\(\S\)\1\{2,}\s*$/j **/*.py
#   :copen



###############################
### PRETTY HEADER 0
###############################

def do_something():
#-------------------------------------
    pass

#-------------------------------------
# # # # # # # # # # # # # # # # # # # # # 
    #====================================

# the above decorative separators are ignored

def do_something_else():
    pass

######################################


###########################
#                         #
#   PRETTY HEADER 1       #
x = 1

# the next headers are forced (unconditional): start with ###, #--, #==

###########################
### PRETTY HEADER 2     ###
###########################
y = 2

#---------------------------------------------------
#-- PRETTY HEADER 3
#---------------------------------------------------
z = 3

#===================================================
#== PRETTY HEADER 4
#===================================================
a = 0

