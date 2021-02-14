# Homelab utility belt
A set of utilities to help managing a homelab

# Content
- [Homelab utility belt](#homelab-utility-belt)
- [Content](#content)
  - [Supermicro IPMI certificate updater](#supermicro-ipmi-certificate-updater)

## Supermicro IPMI certificate updater

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
