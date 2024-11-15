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

In normal mode, there's a direct mapping that lets you recall the [N]'th
previous insertion, one of the last recalls via "{1-9}, or a named insertion
via "{a-zA-Z}. Alternatively, another mapping shows a list of the last 9
insertions, recalled and named ones, and interactively queries one.

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

    [N]q<ALT-A>             Recall and append previous [N]'th insertion.
    [count]"{1-9}q<ALT-A>   Recall and append the insertion that was recalled last
                            (1), second-to-last (2), etc. [count] times.
    [count]"{a-zA-Z}q<ALT-A>
                            Recall and append the insertion named {a-zA-Z} by
                            invoking the q_CTRL-A mapping.

    [count]q<CTRL-A>        Lists the last 9 insertions, last 9 recalled
                            insertions, and any named {a-zA-Z} insertions, then
                            prompts to choose one.
                            That chosen insertion is appended [count] times.
    [count]"{a-zA-Z}q<CTRL-A>
                            Like above, but name the chosen insertion as {a-zA-Z}
                            for a recall.

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
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.044 or
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

By default, the named ({a-zA-Z}) and recalled ({1-9}) insertions are
persisted, too. To disable that:

    let g:PrevInsertComplete_PersistNamed = 0
    let g:PrevInsertComplete_PersistRecalled = 0

Insertions are by default inserted at the beginning of the line if the cursor
is in column 1, else appended after the current character. You can change that
behavior via one of the values described at g:IngoLibrary\_InsertHereStrategy
put into g:PrevInsertComplete\_RecallInsertStrategy.

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

##### 2.00    12-Nov-2024
- CHG: q&lt;C-@&gt; direct recall mapping is broken in GVIM 8.2 (cp.
  https://github.com/vim/vim/issues/6457#issuecomment-658960270); choose
  different q&lt;A-a&gt; default to avoid these issues.
- ENH: Allow naming of (important) insertions similar to the built-in
  registers, and offer a shortlist of the last 9 recalls, too - previous
  recalls likely get recalled again.
- CHG: Insert recalled insertion before the cursor when on the first column,
  and allow to tweak that via g:PrevInsertComplete\_RecallInsertStrategy.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.044!__

##### 1.12    28-Dec-2020
- BUG: "E899: Argument of insert() must be a List or Blob" in
  PrevInsertComplete#Record#Insertion().

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
Copyright: (C) 2011-2024 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
