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
DSM_MAJOR_VERSION=$([[ $(grep majorversion /etc/VERSION) =~ [0-9] ]] && echo ${BASH_REMATCH[0]})
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
if [[ ${DSM_MAJOR_VERSION} == 6]]; then
    synoservice --restart nginx
    synoservice --restart nmbd
    synoservice --restart smbd
    synoservice --restart avahi
    synoservice --restart pkgctl-WebStation.service
else
    systemctl restart nginx
    systemctl restart pkg-synosamba-nmbd.service
    systemctl restart pkg-synosamba-smbd.service
    systemctl restart avahi
    systemctl restart pkgctl-WebStation.service
