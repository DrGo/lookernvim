# Looker.nvim  
A basic neovim plugin to lookup information in arbitrary file, 
and optionally insert it in the current buffer at the cursor.  
For instance, I use it to search a bibtex/biblatex file and insert a selected citation key 
in a markdown file. In fact, this functionality is included as the `Bib` command
So this plugin 
can be simply used to select and insert bibtex citations. 
However, the builtin bib command also serves as an example of how to implement 
your own custom select and insert commands. 

## Installation and configuration  
Install and configure with [lazy.nvim](https://github.com/folke/lazy.nvim) 

To use the `Bib` command: 

```lua 
{
   'drgo/lookernvim',
   ft = { 'markdown' },
   opts = {
      bib = {
        search_file = '/Users/drgo/local/writing/refs/vdec.bib',
        close_on_selection = true
      }
    },
},
```
None of the options is mandatory. 

## Usage 
### Bib 
- In a markdown file, position the cursor wherever you want to insert the citation. 
- In the command prompt, type `Bib filename` to open a floating window containing 
the file (or the default bib file if `filename` is omitted).
- search for citations to insert and press enter anywhere within the text of a citation 
to insert its key in your document using [pandoc markdown citation syntax](https://pandoc.org/chunkedhtml-demo/8.20-citation-syntax.html). 

### Custom lookup  
- The easiest way is to define your own custom user command in your nvim settings file,
by providing a custom `search_specs` table indexed by a key that will be then used as the 
subcommand.for instance, this is how the builtin `Bib` command can be defined as a table within 
the `opts` table with its key functioning as the command name: 

```lua 
{
   'drgo/lookernvim',
   ft = { 'markdown' },
   opts = {
		bib = {
			search_file = '',
			record_marker = "@",
			extract_id_regex = "{(.+),",
			id_format = "[@{%s};]",
			close_on_selection = true,
		},
    },
},
```
to invoke the command, type `Lookup cmdname args` (e.g., `Lookup bib`).


Alternatively, you could define a standard user command 
For example, this is how the `bib` command is created:

```lua 
	vim.api.nvim_create_user_command("Bib", 'Lookup bib', { nargs = '?', complete = 'file' })
```
The custom lookup table (called `search_spec`) should have the following entries: 
+ `searchfile`: path to a file to open by default (when no file is specified in the lookup command).
+ `record_marker`: string used to find the text to insert, e.g., in a bibtex file, `@` marks the 
citation key. 
+ `extract_id_regex`: a regex used to extract the text to be inserted. E.g., this regex `"{(.+),"`
extract the citation key which is any text between `{` and `,` following an `@articletype`.
+ `id_format`: how to format the extracted text for insertion. E.g., `[@{%s};]` defines that the 
citation key should be inserted between `[@{` and `};]`.
+ `close_on_selection`: if true, the window will close after pressing enter. Default is true.  

## Commands 
`Bib [filename]` opens filename for searching. If filename is not specified, or if `filename` 
is omitted, the default file specified in the configuration under `opts.bibfile`. 

`Lookup subcommand [arg]` 
The Lookup accepts either 1 or 2 arguments. If 1 argument is specified,
it's interpreted as command if it is string or as search_spec table if it is a table.
if 2 arguments are specified, the first must be a valid subcommand name (valid entry in
the `opts` table) and the second is a path to file to be opened for searching.

## Limitations 
- inserts one entry at a time. 

