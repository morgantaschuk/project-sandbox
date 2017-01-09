# grep-rc : grep rows and columns

Searches a tab-delimited file with a regex and selects the rows AND columns that match the query.

Originally designed to select the appropriate rows and columns from a symmetric matrix of Jaccard indices.

## Dependencies

* Python 2.7

## Usage

```
$ ./grep-rc -h
usage: grep-rc [-h] --extended-regexp EXTENDED_REGEXP tsv

Grep through a tsv to select rows AND columns that match a regular expression

positional arguments:
  tsv                   the tsv to grep through

optional arguments:
  -h, --help            show this help message and exit
  --extended-regexp EXTENDED_REGEXP, -E EXTENDED_REGEXP
                        Regular expression to use for grepping (python regex)
```

## Examples

Using the provided input.tsv, grep out the rows and columns that contain 'a' or 'c':

```
$ ./grep-rc -E "a|c" input.tsv > ac_input.tsv
$ cat ac_input.tsv
    a   c
a   2   6
c   3   2
```

## Questions

Leave a question or request on the issue tracker on the GitHub repository: https://github.com/morgantaschuk/grep-rc


## License

[MIT](LICENSE)
