PREV INSERT COMPLETE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin lets you quickly recall previous insertions and insert them again
at the cursor position. Essentially, it's the built-in i\_CTRL-A command
souped up with history and selection.

In insert mode, you can narrow down the candidates by typing a keyword first;
then, only insertions with a match will be offered as completion candidates.
In normal mode, you can directly recall the [count]'th previous insertion, or
have it list the last 9 insertions and let you choose.
To avoid that the many minor tactical edits clobber up the history, only
significant (longer) edits are recalled.

### SEE ALSO

- Check out the CompleteHelper.vim plugin page ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)) for a full
  list of insert mode completions powered by it.

USAGE
------------------------------------------------------------------------------

    CTRL-X CTRL-A           Find previous insertions (i_CTRL-A, quote.) whose
                            contents match the keyword before the cursor. First, a
                            match at the beginning is tried; if that returns no
                            results, it may match anywhere.
                            Further use of CTRL-X CTRL-A will append insertions done
                            after the previous recall.

    [count]q<CTRL-@>        Recall and append previous [count]'th insertion.

    [count]q<CTRL-A>        Lists the last 9 insertions, then prompts for a number.
                            The chosen insertion is appended [count] times.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-PrevInsertComplete
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim PrevInsertComplete*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.015 or
  higher.
- Requires the CompleteHelper.vim plugin ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)), version 1.11 or
  higher.
- repeat.vim ([vimscript #2136](http://www.vim.org/scripts/script.php?script_id=2136)) plugin (optional)

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

Very short insertions are often just minor corrections and not worthwhile to
recall. The threshold number of inserted characters can be set via:

    let g:PrevInsertComplete_MinLength = 6

The number of recorded insertions can be adjusted.

    let g:PrevInsertComplete_HistorySize = 100

The recorded insertions can be kept and restored across Vim sessions, using
the viminfo file. For this to work, the "!" flag must be part of the
'viminfo' setting:

    set viminfo+=!  " Save and restore global variables.

By default, all recorded insertions are persisted. You can reduce the maximum
number of insertions to be stored via:

    let g:PrevInsertComplete_PersistSize = 10

or completely turn off persistence by setting the variable to 0.

If you want to use different mappings, map your keys to the
&lt;Plug&gt;(PrevInsert...) mapping targets _before_ sourcing the script (e.g. in
your vimrc):

    imap <C-a> <Plug>(PrevInsertComplete)
    nmap <Leader><C-a> <Plug>(PrevInsertRecall)
    nmap <Leader><A-a> <Plug>(PrevInsertList)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-PrevInsertComplete/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.11    29-Nov-2013
- Change qa mapping default to q&lt;C-@&gt;; I found it confusing that I could not
  record macros into register a any more. To keep the previous mapping, use
 <!-- -->

  :nmap qa &lt;Plug&gt;(PrevInsertRecall)

- Make recall of insertion (q&lt;CTRL-@&gt;, q&lt;CTRL-A&gt;) repeatable.
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

__You need to separately
  install ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.015 (or higher)!__

##### 1.10    15-Oct-2012
- ENH: Persist recorded insertions across Vim invocations in the viminfo file.
This can be controlled by the g:PrevInsertComplete\_PersistSize
configuration.

##### 1.00    22-Aug-2012
- Initial release.

##### 0.01    06-Oct-2011
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2011-2020 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
