#? replace(sub = "\t", by = "  ")

#[

A tool to make CP simpler:
- Download problems automatically and open the editor on the problem.
- Fill in the tests and the templates to make sure everything works.
- Autosubmit



]#

import strformat, httpclient

let starting_year = 2015


proc downloadTask(year: int, day: int) =
    let url = fmt"https://adventofcode.com/{year}/{day}"
    echo "URL: ",url

    var client = newHttpClient()

    try:
        let content = client.getContent url
        echo content
    finally:
        client.close()


downloadTask(2015, 1)