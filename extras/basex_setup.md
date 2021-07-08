# biosample-basex
Using the BaseX XML database to discover structure in NCBI's Biosample database

BaseX can be installed with homebrew on Macs. It can be installed with `apt-get` on Ubuntu Linux machines, but I prefer to download the `.zip` archive. That makes it easier to increase the allocated RAM in the launch scripts. For eaxmple, `basex/bin/basex` might look like this:

```bash
#!/usr/bin/env bash

# Path to this script
FILE="${BASH_SOURCE[0]}"
while [ -h "$FILE" ] ; do
  SRC="$(readlink "$FILE")"
  FILE="$( cd -P "$(dirname "$FILE")" && \
           cd -P "$(dirname "$SRC")" && pwd )/$(basename "$SRC")"
done
MAIN="$( cd -P "$(dirname "$FILE")/.." && pwd )"

# Core and library classes
CP=$MAIN/BaseX.jar:$MAIN/lib/custom/*:$MAIN/lib/*:$CLASSPATH

# Options for virtual machine (can be extended by global options)
BASEX_JVM="-Xmx24g $BASEX_JVM"

# Run code
exec java -cp "$CP" $BASEX_JVM org.basex.BaseX "$@"
```

https://docs.basex.org/wiki/Main_Page

https://basex.org/download/



