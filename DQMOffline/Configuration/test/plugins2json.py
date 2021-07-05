#!/usr/bin/env python3
from sys import exit, argv
from json import dump, dumps
from re import compile
from subprocess import getstatusoutput
err, out = getstatusoutput("edmPluginHelp -o -b -a")
if err:
  print(out)
  exit(1)

data = {}
regex = compile('^[1-9][0-9]*\s+[a-zA-Z]+.+$')
for line in out.split("\n"):
  if regex.match(line):
    items = [x.replace('"', '') for x in line.split(' ') if x]
    data[items[1]] = items[2:]
if len(argv)>1:
  print("Found %s plugins" % str(len(data)))
  with open(argv[1],"w") as ref:
    dump(data, ref, indent=2, sort_keys=True)
else:
  print(dumps(data, indent=2, sort_keys=True))
