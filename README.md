![ShellCheck](https://github.com/ameer1234567890/tinifier/actions/workflows/main.yml/badge.svg)

#### Works with
* Almost any linux based shell.
* Cygwin shell on Windows.
* Git Bash on Windows.

#### Requirements
* cURL
* Some patience.

#### Setup Instructions
* Create a file named `.tinify_api_key` one level above the `tinifier.sh` file. This file should contain the tinify.com API key without a leading CR and/or LF.
* Create two folders named `files` and `compressed` in the same folder as `tinifier.sh`.
* Place all pictures which needs to be compressed, inside the `files` folder.
* If you are on linux, ensure that `tinifier.sh` is chmodded to `755`.
* Run `./tinifier.sh`.
