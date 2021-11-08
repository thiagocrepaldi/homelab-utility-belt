# Homelab utility belt
A set of utilities to help managing a homelab

# Content
- [Homelab utility belt](#homelab-utility-belt)
- [Content](#content)
  - [Supermicro](#supermicro)
    - [IPMI certificate updater](#ipmi-certificate-updater)
  - [Synology](#synology)
    - [IPMI certificate updater on DSM](#ipmi-certificate-updater-on-dsm)
    - [Copy LetsEncrypt SSL certificate from pfSense into Synology DSM](#copy-letsencrypt-ssl-certificate-from-pfsense-into-synology-dsm)
    - [Install LetsEncrypt SSL certificate from pfSense into Synology DSM](#install-letsencrypt-ssl-certificate-from-pfsense-into-synology-dsm)

## Supermicro

### IPMI certificate updater

Requirements: Python 2.7+ or Python 3 with modules listed at `requirements.txt`

How to get started:
```bash
$ pip install -r supermicro/ipmi-updater/requirements.txt
$ python supermicro/ipmi-updater/ipmi-updater.py --help

usage: ipmi-updater.py [-h] --ipmi-url IPMI_URL --key-file KEY_FILE --cert-file CERT_FILE --username USERNAME --password PASSWORD [--no-reboot] [--log-level {0,1,2}]

Update Supermicro IPMI SSL certificate

optional arguments:
  -h, --help            show this help message and exit
  --ipmi-url IPMI_URL   Supermicro IPMI 2.0 URL
  --key-file KEY_FILE   X.509 Private key filename
  --cert-file CERT_FILE
                        X.509 Certificate filename
  --username USERNAME   IPMI username with admin access
  --password PASSWORD   IPMI user password
  --no-reboot           The default is to reboot the IPMI after upload for the change to take effect.
  --log-level {0,1,2}   Log level (0: quiet, 1: info, 2: debug)
```

An example usage would be similar to:

```bash
$ python supermicro/ipmi-updater/ipmi-updater.py --ipmi-url https://mysupermicrohostname --username USERNAME --password PASSWORD --key-file /path/to/private_key.pem --cert-file /path/to/cert_file.cert --log-level=1
```

And the output would be:

```bash
********************************************************************************************************************************
Authenticating on Supermicro IPMI!
********************************************************************************************************************************
Login succeeded.

********************************************************************************************************************************
Fetching current IPMI certificate!
********************************************************************************************************************************
There exists a certificate, which is valid until: May 14 21:58:04 2021

********************************************************************************************************************************
Uploading new IPMI certificate!
********************************************************************************************************************************
New IPMI certificate was uploaded.

********************************************************************************************************************************
Checking new IPMI certificate was properly uploaded!
********************************************************************************************************************************
New IPMI certificate is valid.

********************************************************************************************************************************
Fetching new IPMI certificate!
********************************************************************************************************************************
After upload, there exists a certificate, which is valid until: May 14 21:58:04 2021

********************************************************************************************************************************
Rebooting IPMI to apply changes!
********************************************************************************************************************************

********************************************************************************************************************************
All done!
********************************************************************************************************************************
```
## Synology

### IPMI certificate updater on DSM

This is pretty much the same [script for IPMI certificate updater](#ipmi-certificate-updater) but wrapped on a Almquist shell so that it can be automated from a Synology NAS.

How to get started:
```bash
bash supermicro-ipmi-updater.sh -p PYTHON -i INSTALL_DIR -c CERT -k KEY -a USERNAME -s SECRET -u URL -v VERBOSE

# Arguments:
#  -p PYTHON             Python binary name, such as 'python2' or 'python3'
#  -i INSTALL_DIR        Temporary dir to download IPMI updater scripts
#  -c CERT               Filename for the new certificate file
#  -k KEY                Filename for the private key
#  -a USERNAME           Username with admin access
#  -s SECRET             Password for the username
#  -u URL                IPMI URL, including http/https
#  -v VERBOSE            Log level (0: quiet, 1: info, 2: debug)
```

### Copy LetsEncrypt SSL certificate from pfSense into Synology DSM

This scripts copy the specified LetsEncrypt certificate issue by your pfSense into a share and then install it on your Synology DSM

How to get started:
```bash
bash copy_letsencrypt_cert_from_pfsense.sh -s LETSENCRYPT_SHARE -n CERTIFICATE_NAME -p PFSENSE_SSH_PORT -u PFSENSE_USERNAME -h PFSENSE_HOSTNAME

# Arguments:
#  -s LETSENCRYPT_SHARE    Full share path to download the LetsEncrypt certificates into (e.g. /volume1/LetsEncrypt)
#  -n CERTIFICATE_NAME     Let's Encrypt certificate name as displayed on pfSense UI (e.g. SynologySSL)
#  -p PFSENSE_SSH_PORT     SSH port for the pfSense (e.g. -p 22)
#  -u PFSENSE_USERNAME     Username (with proper SSH keys) for the pfSense - cannot be 'admin' (-u synouser)
#  -h PFSENSE_HOSTNAME     pfSense hostame (e.g. mypfsense.lan.example.com)
```

### Install LetsEncrypt SSL certificate from pfSense into Synology DSM

This scripts installs the specified LetsEncrypt certificate issue by your pfSense from a local share into your Synology DSM

How to get started:
```bash
bash install_letsencrypt_cert_from_pfsense.sh -s LETSENCRYPT_SHARE -n CERTIFICATE_NAME

# Arguments:
#  -s LETSENCRYPT_SHARE    Full share path to download the LetsEncrypt certificates into (e.g. /volume1/LetsEncrypt)
#  -n CERTIFICATE_NAME     Let's Encrypt certificate name as displayed on pfSense UI (e.g. SynologySSL)
```
