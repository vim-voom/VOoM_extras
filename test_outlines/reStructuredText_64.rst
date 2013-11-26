This is reStructuredText file with all possible adornment styles, all 64 levels.
Execute the following VimScript code to create it:

tabnew
Voom rest
let tree = bufnr('')
let start = reltime()
for i in range(1,64)
    call voom#OopInsert('as_child')
    call voom#ToTree(tree)
endfor
echo reltimestr(reltime(start))
unlet tree start i




===========
NewHeadline
===========

-----------
NewHeadline
-----------

NewHeadline
===========

NewHeadline
-----------

NewHeadline
***********

NewHeadline
"""""""""""

NewHeadline
'''''''''''

NewHeadline
```````````

NewHeadline
~~~~~~~~~~~

NewHeadline
:::::::::::

NewHeadline
^^^^^^^^^^^

NewHeadline
+++++++++++

NewHeadline
###########

NewHeadline
...........

NewHeadline
___________

!!!!!!!!!!!
NewHeadline
!!!!!!!!!!!

NewHeadline
!!!!!!!!!!!

"""""""""""
NewHeadline
"""""""""""

###########
NewHeadline
###########

$$$$$$$$$$$
NewHeadline
$$$$$$$$$$$

NewHeadline
$$$$$$$$$$$

%%%%%%%%%%%
NewHeadline
%%%%%%%%%%%

NewHeadline
%%%%%%%%%%%

&&&&&&&&&&&
NewHeadline
&&&&&&&&&&&

NewHeadline
&&&&&&&&&&&

'''''''''''
NewHeadline
'''''''''''

(((((((((((
NewHeadline
(((((((((((

NewHeadline
(((((((((((

)))))))))))
NewHeadline
)))))))))))

NewHeadline
)))))))))))

***********
NewHeadline
***********

+++++++++++
NewHeadline
+++++++++++

,,,,,,,,,,,
NewHeadline
,,,,,,,,,,,

NewHeadline
,,,,,,,,,,,

...........
NewHeadline
...........

///////////
NewHeadline
///////////

NewHeadline
///////////

:::::::::::
NewHeadline
:::::::::::

;;;;;;;;;;;
NewHeadline
;;;;;;;;;;;

NewHeadline
;;;;;;;;;;;

<<<<<<<<<<<
NewHeadline
<<<<<<<<<<<

NewHeadline
<<<<<<<<<<<

>>>>>>>>>>>
NewHeadline
>>>>>>>>>>>

NewHeadline
>>>>>>>>>>>

???????????
NewHeadline
???????????

NewHeadline
???????????

@@@@@@@@@@@
NewHeadline
@@@@@@@@@@@

NewHeadline
@@@@@@@@@@@

[[[[[[[[[[[
NewHeadline
[[[[[[[[[[[

NewHeadline
[[[[[[[[[[[

\\\\\\\\\\\
NewHeadline
\\\\\\\\\\\

NewHeadline
\\\\\\\\\\\

]]]]]]]]]]]
NewHeadline
]]]]]]]]]]]

NewHeadline
]]]]]]]]]]]

^^^^^^^^^^^
NewHeadline
^^^^^^^^^^^

___________
NewHeadline
___________

```````````
NewHeadline
```````````

{{{{{{{{{{{
NewHeadline
{{{{{{{{{{{

NewHeadline
{{{{{{{{{{{

|||||||||||
NewHeadline
|||||||||||

NewHeadline
|||||||||||

}}}}}}}}}}}
NewHeadline
}}}}}}}}}}}

NewHeadline
}}}}}}}}}}}

~~~~~~~~~~~
NewHeadline
~~~~~~~~~~~

