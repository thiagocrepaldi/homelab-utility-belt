'''Certificate refresher for Synology DSM Services

This script refreshes the current Synology DSM services assignment to the specified Let's Encrypt certificate.
This is useful when the certificate files are replaced without using Synology certificate API,
(e.g. SSH copy). It assigns all relevant services to a temporary self-signed certificate before
assigning them back to the new certificate.

The temporary certificate must be any valid self-signed certificate
The new (official) certificate must be a valid Let's Encrypt certificate
'''

import argparse
import time

from synology_dsm import SynologyDSM

################################################################################
# Setup
################################################################################

# CLI arguments
parser = argparse.ArgumentParser()
parser.add_argument(
    'ip', help='Synology IP address or FQDN (e.g. localhost)', type=str)
parser.add_argument('port', help='Synology port (e.g. 5001)', type=int)
parser.add_argument('username', help='Synology username', type=str)
parser.add_argument('password', help='Synology password', type=str)
parser.add_argument('--use-https', help='Use HTTPS', action='store_true')
parser.add_argument(
    '--verify-ssl', help='Verify SSL certificate', action='store_true')
parser.add_argument('--temp-certificate',
                    help='Temporary certificate name to assign to --services', type=str)
parser.add_argument('--new-certificate',
                    help='New certificate name to assign to --services', type=str)
parser.add_argument('--debug', help='Enable debug logs', action='store_true')
args = parser.parse_args()

# Connecting to Synology DSM and fetching certificate info
if args.debug:
    print(f'Connecting to {args.username}@{args.ip}:{args.port}')
api = SynologyDSM(dsm_ip=args.ip,
                  dsm_port=args.port,
                  username=args.username,
                  password=args.password,
                  use_https=args.use_https,
                  verify_ssl=args.verify_ssl)
api.certificate.update()
self_signed = api.certificate.self_signed
lets_encrypt = api.certificate.lets_encrypt
services = api.certificate.services()

################################################################################
# input validation
################################################################################
# Temporary certificate
if args.temp_certificate is not None:
    if args.debug:
        print(f'A temporary self-signed certificate "{args.temp_certificate}" will be used!'
              f'\nThe available self-signed certificates are: {self_signed}')

    if len(self_signed) <= 0:
        raise RuntimeError(
            'At least one self-signed must be installed on the Synology DSM!')

    if args.temp_certificate not in self_signed:
        raise RuntimeError(
            f'"{args.temp_certificate}" is not installed on the Synology DSM!')

# New certificate
if len(lets_encrypt) <= 0:
    raise RuntimeError(
        'At least one Lets Encrypt certificate must be installed on the Synology DSM!')
elif args.debug:
    print(f'The available Lets Encrypt certificates are: {lets_encrypt}')

if args.new_certificate is not None and args.new_certificate not in lets_encrypt:
    raise RuntimeError(
        f'"{args.new_certificate}" is not installed on the Synology DSM!')

# Services
current_services = sorted(
    api.certificate.services_by_certificate(args.new_certificate))
if not current_services:
    raise RuntimeError('At least one Synology DSM service must be specified!'
                       f'\nThe available services are: {services}')
if args.debug:
    print(f'{args.new_certificate} has the following assigned services: {current_services}')

################################################################################
# Assigning certificates to certificates
################################################################################

if args.temp_certificate is not None:
    if args.debug:
        print(
            f'Temporary certificate "{args.temp_certificate}" will be assigned to services {current_services}')
    res = api.certificate.assign_certificate_to_service(
        args.temp_certificate, current_services)
    success = bool(res["success"])
    if args.debug:
        print(
            f'Temporary certificate assignment to services: {"Succeeded" if success else "Failed"}')
    if 'default' in current_services:
        if args.debug:
            print(
                'Web server needs to be restarted. Sleeping for 30s before reassigning certificates.')
        time.sleep(30)

if args.new_certificate is not None:
    api.certificate.update()
    if args.debug:
        print(
            f'New certificate "{args.new_certificate}" will be assigned to services {current_services}')
    res = api.certificate.assign_certificate_to_service(
        args.new_certificate, current_services)
    if args.debug:
        print(
            f'Official certificate assignment to services: {"Succeeded" if success else "Failed"}')
