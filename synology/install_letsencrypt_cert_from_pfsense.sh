# Your environment variables
LETSENCRYPT_SHARE=""
CERTIFICATE_NAME=""

while getopts s:n: flag
do
    case "${flag}" in
        s) LETSENCRYPT_SHARE=${OPTARG};;
        n) CERTIFICATE_NAME=${OPTARG};;
    esac
done

[ -z "${LETSENCRYPT_SHARE}" ] && echo "Set Let's Encrypt share path through -s (e.g. -s /volume1/LetsEncrypt)" && exit 1
[ -z "${CERTIFICATE_NAME}" ] && echo "Set Certificate name as displayed (case sensitive) on pfSense UI -n (e.g. -n Synology)" && exit 1

# Existing certificates are replaced below
DEFAULT_CERT_ROOT_DIR="/usr/syno/etc/certificate"
DEFAULT_ARCHIVE_CERT_DIR="${DEFAULT_CERT_ROOT_DIR}/_archive"
DEFAULT_ARCHIVE_CERT_NAME=${DEFAULT_ARCHIVE_CERT_DIR}/$(cat ${DEFAULT_ARCHIVE_CERT_DIR}/DEFAULT)
EXISTING_CERT_FOLDERS=$(find /usr/syno/etc/certificate -path */_archive/* -prune -o -name cert.pem -exec dirname '{}' \;)
NEW_CERT="${LETSENCRYPT_SHARE}/${CERTIFICATE_NAME}.all.pem"

for _dir in ${EXISTING_CERT_FOLDERS} ${DEFAULT_ARCHIVE_CERT_NAME}; do
    echo "Replacing certificates from ${_dir}"
    _certs=$(find ${_dir} -name "*.pem")
    for _cert in ${_certs}; do
        echo "Replacing ${_cert} with ${NEW_CERT}"
        cp -f ${NEW_CERT} ${_cert}
    done
done

# Restart web server
synoservice --restart nginx
synoservice --restart nmbd
synoservice --restart avahi