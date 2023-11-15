# nvimbib 
A basic neovim plugin to search a bibtex/biblatex file and insert citation key at the cursor.


## Installation and configuration  
Install and configure with [lazy.nvim](https://github.com/folke/lazy.nvim) 

```lua 
{
  'drgo/nvimbib',
  ft = { 'markdown' },
  opts = {
    bibfile = '/path/to/file.bib',
    close_on_selection = true
  },
},
},
```
None of the options is mandatory. 

## Usage 
- In a markdown file, position the cursor wherever you want to insert the citation. 
- In the command prompt, type `Bib filename` to open a floating window containing 
the file (or the default bib file if `filename` is omitted).
- search for citations to insert and press enter anywhere within the text of a citation 
to insert its key in your document using [pandoc markdown citation syntax](https://pandoc.org/chunkedhtml-demo/8.20-citation-syntax.html). 

## Options 
`bibfile`: path to bib file to open by default (when no file is specified in the Bib command)
`close_on_selection`: if true, the window will close after pressing enter. Default is true.  

## Commands 
`Bib [filename]` opens filename for searching. If filename is not specified, or if `filename` 
is omitted, the default file specified in the configuration under `opts.bibfile`. 

## Limitations 
- inserts one reference at a time. 
