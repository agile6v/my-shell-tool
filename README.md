# my-shell-tool

## Install

Please make sure your system $PATH includes "/usr/local/bin/". 

```sh
sudo sh -c "curl https://raw.githubusercontent.com/agile6v/my-shell-tool/master/mst.sh -o /usr/local/bin/mst && chmod +x /usr/local/bin/mst"
```

## Usage
Usage: mst.sh <command|option>

```
Options:
    -V, --version    Print program version
    -h, --help       Print help

Commands:
    replace       Replace the contents in the files
    json          Json pretty print (The json string should be inside the single quotes)
    count         Count the lines of code in a file or directory
    ip            Translate IP address from dotted-decimal address to decimal format and vice versa,
                  and also support to calculate from CIDR ip address to network & broadcast address
    convert       convert arbitrary base to arbitrary base within 2,8,10,16
    urlencode     encode url string
    urldecode     decode url string
    calc          calculator
    
Use mst.sh [command] --help for more information about a command.
```

