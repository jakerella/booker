# What is this?

This is a very simple generator for books based on markdown source files. This is NOT a fancy user interface for managing and generating books, however, it is a very techie-focused library for those of us that like that sort of thing.

## Okay, so what do I do with this?

Clone the repo, then start writing your book. All of your content needs to go in the `chapters` directory. Use simple Markdown (along with some custom styling found in the `book.css` file) to create your content. Install the dependencies (see below) and run a command (again, see below) to generate both PDF and ePub versions of your book.

## Generating a Formatted PDF

1. Install [wkhtmltopdf](https://wkhtmltopdf.org/)
2. Install [pandoc](https://pandoc.org/)
3. Generate the PDF.

### Windows

In PowerShell, run the build script: `.\build.ps1`

> Windows? Blech...
> Yeah well, I found it easier to get wkhtmltopdf and pandoc to work together this way. 

If you are using the PowerShell script, you can also use the `-BumpLevel` CLI option to bump the patch, minor, or major version and automatically create a tag in the git repo. This will also insert the version/build into the PDF or epub file.

For example: `.\build.ps1 -BumpLevel minor`

### Mac/Linux

At some point I will make a more thorough shell script to mimic the PowerShell script, but for now you will need to:

1. Combine the `config-common.yaml` and `config-epub.yaml` (and separately the `config-pdf.yaml`) files
2. Run this command with each of the config files: `pandoc -s -d [COMBINED-CONFIG-FILE] chapters/*.md`

## I don't really like the template, can I change it?

Of course! Open up the `tempalte-pdf.latex` or `template-epub.latex` files and tinker with them! You can't really screw it up, because you can always revert to the stock templates in this source repo.

### Debugging

Something not quite working in the generated output files? Go into the `config-pdf.yaml` file and switch the `output-file` option to be `.\output\book.html` (note the "html" at the end). This will stop generation at the source HTML **before** it is converted to PDF (so you won't get the PDF file). Now you can inspect that file. Ensure the HTML is what you expect, that the CSS is loading properly, and that all JS is present.

## Author & License

Hi, my name is Jordan Kasper. I'm a software engineer, conference speaker, and general technophile. I created this out of a need for myself (and because I'm a complete dork).

This repo is released under the MIT license.
