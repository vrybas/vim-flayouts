# flayouts.vim - Layouts for Fugitive

Flayouts.vim aims to ease work with [Fugitive](https://github.com/tpope/vim-fugitive) by providing window
layouts for certain operations, such as:

  * Commit

  * Pull Request review

  * Conflict Resolution

#### :GlstatusTab - a "Commit" layout.

- Run `:GlstatusTab`(or `:Glc`)
- Review diff
- Jump to "status" window
- Press `-` to add/remove files
- Run `:Git diff` or `:Git diff --cached` in a diff window to update
  diff
- Press `C` in "status" window to enter a commit message
- Run `:Glcommit`(or `:Glc` again) to commit
- Run `:Glabort` to cancel commit and close tab

![](http://f.cl.ly/items/0a0H2o290j2P0b40233M/Screen%20Shot%202014-03-10%20at%208.29.10%20AM.png)

##### :GlpullRequestSummaryTab - a "Pull Request Review" layout.

- Run `:GlpullRequestSummaryTab`
- Review diff
- Run `:GlopenFromDiff` on code chunk to open corresponding file
- Run `:Gblame` to show "git-blame" of current file
- Press `o` on commit SHA to open commit where chunk was added.

![](http://f.cl.ly/items/1j0Q0P2s390y0T0x1W44/Screen_Shot_2014-03-10_at_8_35_40_AM.png)

##### :GlresolveConflictTab - a "Resolve Conflict" layout.

- Run `:GlresolveConflictTab`
- Compare "HEAD"(ours) versions and "MERGE"(theirs) version
- Resolve conflict on "both modified" version
- Run `:Glwrite` on "both modified" version to add file to index and
  close tab

![](http://f.cl.ly/items/310G3x140d0y0w3O0c2E/Screen_Shot_2014-03-10_at_8_44_07_AM.png)


All available commands and their description can be found here:
https://github.com/vrybas/vim-flayouts/blob/master/doc/flayouts.txt

## Installation

```vimrc
Bundle 'tpope/vim-fugitive'
Bundle 'vrybas/vim-flayouts'
```

## License

Copyright (c) Vladimir Rybas.
