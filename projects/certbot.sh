export DOMAIN=your-domain.com
export EMAIL=your@email.here
export WORKDIR=$PWD/letsencrypt

certbot certonly \
    --config-dir $WORKDIR/config \
    --work-dir $WORKDIR/work \
    --logs-dir $WORKDIR/logs \
    --manual \
    --preferred-challenges=dns \
    --email $EMAIL \
    --server https://acme-v02.api.letsencrypt.org/directory \
    --agree-tos \
    -d *.ws.$DOMAIN \
    -d *.$DOMAIN \
    -d $DOMAIN
