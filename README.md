[![Build Status](https://travis-ci.org/ameer1234567890/tinifier.svg?branch=master)](https://travis-ci.org/ameer1234567890/tinifier)

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

#### Docker
 It's possible to use it with docker or docker-compose, basically instructions is similar:

 * Create folders `files` and `compressed` and file `.tinify_api_key`;
 * Place files you want to convert to the folder `files`;

 If you use docker:
 * Build image: `docker build --pull --force-rm -t tinifier --file ./Dockerfile .`

 * Execute container:
   ```bash
   docker run -ti --rm \
     -v ${PWD}/.tinify_api_key:/.tinify_api_key \
     -v ${PWD}/files:/tinifier/files \
     -v ${PWD}/compressed:/tinifier/compressed \
     tinifier
   ```

 If you use docker-compose:
 * Check/edit given `docker-compose.yml` file (i.e. volumes section);
 * Build image: `docker-compose build tinifier`;
 * Run it: `docker-compose run --rm tinifier`.
