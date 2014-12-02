#!/bin/sh
mkdir -p "${STACKATO_FILESYSTEM}/configs"
if [[ ! -e "${STACKATO_FILESYSTEM}/configs/znc.conf" ]] ; then
    cp /app/znc.conf "${STACKATO_FILESYSTEM}/configs/znc.conf"
fi
sed -i "s#^\(\s\+Port\s*=\s*\)[0-9]\+#\1${PORT}#g" "${STACKATO_FILESYSTEM}/configs/znc.conf"
exec /app/bin/znc --foreground --debug --no-color --datadir "${STACKATO_FILESYSTEM}"
