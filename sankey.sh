#!/bin/bash

# Awk line ignores all accounts with balances less than 50. Do not do this with hledger query (like amt:'>50'), or you will end up with
# skewed balances in parent accounts.

# Adjust sed line if your currency symbols are not £ or $
(
  echo "source,target,value"; 
  (
    hledger -f "$1" balance -O csv -N -X USD --tree \
    | sed -nre 's/["USD\-]//g; /expenses,/{s/^/income,/;p}; /expenses[^,]/{s/(.+):([^:]+),/\1,\1:\2,/;p}; /income[^,]/{s/(.+):([^    :]+),/\1:\2,\1,/;p};' \
    | awk '/^expenses/{t=t$0"\n";next}1;END {print t}' \
    | awk -vOFS=, -F, '$3 > 50 {print $1,$2,$3}'
  )
) > ./html/sankey.csv
