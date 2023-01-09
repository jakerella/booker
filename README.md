# What is this?

This is a very simple generator for books based on markdown source files. This is NOT a fancy user interface for managing and generating books, however, it is a very techie-focused library for those of us that like that sort of thing.

## Okay, so what do I do with this?

Click on the "Use this template" button in GitHub to create a new repo, then start writing your book. All of your content needs to go in the `chapters` directory. Use simple Markdown (along with some custom styling found in the `book.css` file) to create your content. Install the dependencies (see below) and run a command (again, see below) to generate both PDF and ePub versions of your book.

As an added bonus, this framework can help you manage versions/builds (see below) and will count the number of words across your entire book (roughly, it also captures some markdown artifacts that aren't words).

## Generating ePub & PDF

1. Install [wkhtmltopdf](https://wkhtmltopdf.org/)
2. Install [pandoc](https://pandoc.org/)
  * NOTE: make sure to get the latest, especially on linux (aptitude has a very old version)
3. Write your chapters with `.md` files in the `chapters` directory
4. Generate the output documents using the `build.ps1` (PowerShell) or `build.sh` (bash) scripts

### Versioning

You can also use the `-BumpLevel` CLI option to bump the patch, minor, or major version and automatically create a tag in the git repo. This will also insert the version/build into the PDF and epub file's title page.

For example: `.\build.ps1 -BumpLevel minor`

> NOTE: you should manually create a tag the first time (like `git tag v1.0.0`)

## I don't really like the template, can I change it?

Of course! Open up the `tempalte-pdf.latex` or `template-epub.latex` files and tinker with them! You can't really screw it up, because you can always revert to the stock templates in this source repo.

### Debugging

Something not quite working in the generated output files? Go into the `config-pdf.yaml` file and switch the `output-file` option to be `.\output\book.html` (note the "html" at the end). This will stop generation at the source HTML **before** it is converted to PDF (so you won't get the PDF file). Now you can inspect that file. Ensure the HTML is what you expect, that the CSS is loading properly, and that all JS is present.

## Author & License

Hi, my name is Jordan Kasper. I'm a software engineer, conference speaker, and general technophile. I created this out of a need for myself (and because I'm a complete dork).

This repo is released under the MIT license.
