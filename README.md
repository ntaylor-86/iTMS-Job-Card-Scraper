# iTMS-Job-Card-Scraper
A shell script that scans Job tickets that have been exported from iTMS into a .txt format. Once the job has been scanned it saves all the relevant data into different arrays. With this data it is possible to print all the customer pdf's, print the existing ROTO programs... More functions to come.

## Getting Started

You will need a .txt file for the script to scrape all the information from. In iTMS, open Jobs (5), Print Job Ticket (3), enter the job number, click on print, choose Number. This will open the iTMS Print Preview, click on Export, choose Text as the file type and save the .txt file in the same location as the shell script.

### Prerequisites

What things you need to install the software and how to install them

```
dos2unix

debian based distros:
$ sudo apt install dos2unix
```

### Installing

Copy the script to your home directory preferably its own folder and make the script executable

```
Change into the directory where the script is located,
$ cmod +x scrape-job.sh
```
