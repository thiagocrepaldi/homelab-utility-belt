# Your environment variables
PYTHON=""
INSTALL_DIR=""
SUPERMICRO_CERT=""
SUPERMICRO_KEY=""
SUPERMICRO_ADMIN=""
SUPERMICRO_PASS=""
SUPERMICRO_URL=""
LOG_LEVEL=1

while getopts p:i:c:k:a:s:u:v: flag
do
    case "${flag}" in
        p) PYTHON=${OPTARG};;
        i) INSTALL_DIR=${OPTARG};;
        c) SUPERMICRO_CERT=${OPTARG};;
        k) SUPERMICRO_KEY=${OPTARG};;
        a) SUPERMICRO_ADMIN=${OPTARG};;
        s) SUPERMICRO_PASS=${OPTARG};;
        u) SUPERMICRO_URL=${OPTARG};;
    esac
done

[ -z "${PYTHON}" ] && echo "Set python binary name through -p" && exit 1
[ -z "${INSTALL_DIR}" ] && echo "Set temporary IPMI updater dir through -i" && exit 1
[ -z "${SUPERMICRO_CERT}" ] && echo "Set certificate filename through -c" && exit 1
[ -z "${SUPERMICRO_KEY}" ] && echo "Set private key filename through -k" && exit 1
[ -z "${SUPERMICRO_ADMIN}" ] && echo "Set IPMI username through -a" && exit 1
[ -z "${SUPERMICRO_PASS}" ] && echo "Set IPMI password through -s" && exit 1
[ -z "${SUPERMICRO_URL}" ] && echo "Set IPMI URL through -u" && exit 1
[ -z "${LOG_LEVEL}" ] && echo "Set log level through -v (0, 1 or 2)" && exit 1

# Checking python
${PYTHON} --version || ( echo "${PYTHON} is not installed! Aborting" && exit 1 )

# Preparing temporary folder for IPMI updater
rm -r ${INSTALL_DIR}/* || mkdir -p ${INSTALL_DIR}
wget https://raw.githubusercontent.com/thiagocrepaldi/homelab-utility-belt/main/supermicro/ipmi-updater/ipmi-updater.py -O ${INSTALL_DIR}/ipmi-updater.py
wget https://raw.githubusercontent.com/thiagocrepaldi/homelab-utility-belt/main/supermicro/ipmi-updater/requirements.txt -O ${INSTALL_DIR}/requirements.txt

# Install python dependencies
${PYTHON} -m pip ||  ( wget https://bootstrap.pypa.io/get-pip.py -O ${INSTALL_DIR}/get-pip.py && ${PYTHON} ${INSTALL_DIR}/get-pip.py && ${PYTHON} -m pip install -r ${INSTALL_DIR}/requirements.txt )

# Copy certificates with appropriate names
#    Certificate must end with .cert and private key with .pem
cp -fv ${SUPERMICRO_CERT} ${INSTALL_DIR}/new_cert.cert
cp -fv ${SUPERMICRO_KEY} ${INSTALL_DIR}/new_priv_key.pem

# Install new certificate
${PYTHON} ${INSTALL_DIR}/ipmi-updater.py --ipmi-url ${SUPERMICRO_URL} --username ${SUPERMICRO_ADMIN} --password ${SUPERMICRO_PASS} --key-file ${INSTALL_DIR}/new_priv_key.pem --cert-file ${INSTALL_DIR}/new_cert.cert --log-level=${LOG_LEVEL}
