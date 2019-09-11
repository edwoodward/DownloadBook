# DownloadBook
Exercise to learn Ruby. 

Some classes that

  * Retrieve the TOC Json for the given book
  * Loops through the TOC
  * Downloads the HTML for each page and saves it in a file
  * Downloads any images and saves them to a file
  * Fixes path to images so the locally saved images display in the HTML
  * Creates a toc.html file to navigate the book locally


**To Run**

* On the command line: ruby cli.rb
* Enter a Book UUID when prompted such as Astrology: 2e737be8-ea65-48c3-aa0a-9f35b4c6a966

**Caveats**

* Does not work with books that contain units such as Biology
* Does not handle pages generated via baking correctly. They error. The issue is the URL needed to download them correctly. Decided to stop trying to fix it since this is a learning exercise for Ruby syntax.
