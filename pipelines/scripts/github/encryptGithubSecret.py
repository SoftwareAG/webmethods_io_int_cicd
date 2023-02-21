#!/usr/bin/python3

import argparse
from base64 import b64encode
from nacl import encoding, public

parser = argparse.ArgumentParser(description='CLI arguments')
parser.add_argument('public_key', type=str, help='Public Key')
parser.add_argument('secret_value', type=str, help='Secret value')

args = vars(parser.parse_args())
pk = args.get('public_key', "not declared")
sv = args.get('secret_value', "not declared")

def encrypt(public_key: str, secret_value: str) -> str:
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)

    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    
    return b64encode(encrypted).decode("utf-8")
print(encrypt(public_key=pk, secret_value=sv))