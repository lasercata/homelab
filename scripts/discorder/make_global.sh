#!/usr/bin/env bash

OUT_FILE="/bin/discorder"

echo '#!/usr/bin/env bash' > "$OUT_FILE"
echo "cd $(pwd)" >> "$OUT_FILE"
echo './discorder.sh $1 $2' >> "$OUT_FILE"
