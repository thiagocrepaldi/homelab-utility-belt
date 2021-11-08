# Your environment variables
LETSENCRYPT_SHARE=""
CERTIFICATE_NAME=""

while getopts s:n: flag
do
    case "${flag}" in
        s) LETSENCRYPT_SHARE=${OPTARG};;
        n) CERTIFICATE_NAME=${OPTARG};;
        f) CERTIFICATE_PATH=${OPTARG};;
    esac
done

display_help=0
if [[ -z "${CERTIFICATE_PATH}" ]]; then
    [[ -z "${LETSENCRYPT_SHARE}" ]]  && display_help=1
    [[ -z "${CERTIFICATE_NAME}" ]] && display_help=1
    [[ -n "${CERTIFICATE_PATH}" ]] && echo "-f should not be used with -s -n"  && display_help=1
else
    [[ ! -f "${CERTIFICATE_PATH}" ]] && echo "${CERTIFICATE_PATH} : File not found" && display_help=1
    [[ -n "${LETSENCRYPT_SHARE}" || -n "${CERTIFICATE_NAME}" ]] && echo "-f should not be used with -s -n"  && display_help=1
fi

if [[ "${display_help}" ]]; then
    echo << __EO_HELP__
This script updates the Synology CRT with a renewed one then restarts services if needed.

You may use it in 2 ways:

1) With a share and a certificate name:
-s crt_share : Set Let's Encrypt share path (e.g. -s /volume1/LetsEncrypt)
-n crt_name :  Set Certificate name as displayed (case sensitive) on pfSense UI (e.g. -n Synology)

2) With the CRT full path:
-f crt_path : Set Let's Encrypt crt path (e.g. -f /volume1/docker/swag/etc/letsencrypt/live/my.domain.com/priv-fullchain-bundle.pem)

__EO_HELP__

exit

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
fi
