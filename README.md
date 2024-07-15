# Refind

A script to search for files and display the results in a color-coded format.

## Installation

Run the following command to install the script:

```sh
sudo ./install.sh
```

This will copy the script to `/usr/local/bin` and make it executable.

## Usage

```sh
refind [SEARCH_TERM] [DIRECTORY]
```
- SEARCH_TERM: The term to search for using the find command.
- [DIRECTORY]: The directory to search in (optional, default is current directory).

## Examples

```sh
refind "vc_red.msi" /path/to/search
```

This will search for vc_red.msi in the specified directory.

```sh
refind "vc_red.msi"
```

This will search for vc_red.msi in the current directory.

## Description

This script searches for files matching the SEARCH_TERM in the specified DIRECTORY (or current directory if not specified). It displays the search progress and results in a color-coded format. On script exit, it shows detailed results and cleans up temporary log files.

[MIT License](LICENSE)
