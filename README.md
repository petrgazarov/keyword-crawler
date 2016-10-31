# Keyword crawler

This script helps find content on websites.
Given keywords, it scans the `body` tag of the html.
It reports back in a csv file.

## Setup

- Clone repo locally
- cd into main directory
- install recent version of ruby if necessary
- run `bundle`

## Usage

Okay! Here is how to use this.

- Make sure your list of websites are in `websites.txt` file, one per line
- Change `KEYWORDS` constant in `lib/website_parser.rb` to point to an array of desired keywords
- Script runs with `ruby lib/run.rb`
- When finished, the results will be saved in `results.csv`
- Note, it will also scan the url address for keywords

## License

MIT.
