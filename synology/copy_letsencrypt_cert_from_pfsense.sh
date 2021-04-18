# Your environment variables
LETSENCRYPT_SHARE=""
CERTIFICATE_NAME=""
PFSENSE_PORT=""
PFSENSE_USER=""
PFSENSE_HOSTNAME=""

while getopts s:n:p:u:h: flag
do
    case "${flag}" in
        s) LETSENCRYPT_SHARE=${OPTARG};;
        n) CERTIFICATE_NAME=${OPTARG};;
        p) PFSENSE_PORT=${OPTARG};;
        u) PFSENSE_USER=${OPTARG};;
        h) PFSENSE_HOSTNAME=${OPTARG};;
    esac
done

[ -z "${LETSENCRYPT_SHARE}" ] && echo "Set Let's Encrypt share path through -s (e.g. -s /volume1/LetsEncrypt)" && exit 1
[ -z "${CERTIFICATE_NAME}" ] && echo "Set Certificate name as displayed (case sensitive) on pfSense UI -n (e.g. -n Synology)" && exit 1
[ -z "${PFSENSE_PORT}" ] && echo "Set pfSense SSH port -p (e.g. -p 22)" && exit 1
[ -z "${PFSENSE_USER}" ] && echo "Set pfSense SSH user with pre-installed public keys through -u (e.g. -u synouser)" && exit 1
[ -z "${PFSENSE_HOSTNAME}" ] && echo "Set pfSense hostname through -h (e.g. -h mypfsense" && exit 1

# Copy certificates from pfSense into Synology's share
scp -v  -P ${PFSENSE_PORT} ${PFSENSE_USER}@${PFSENSE_HOSTNAME}:/conf/acme/${CERTIFICATE_NAME}* ${LETSENCRYPT_SHARE}/
