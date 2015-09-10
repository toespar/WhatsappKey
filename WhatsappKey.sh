#!/bin/bash
read -p "Write your telephone number with your country code (without '+'), please: " number
#Need 3 keys from the password file: salt, IV and the encrypted key
dd if=pw bs=1 skip=29 count=4 > pw_salt
dd if=pw bs=1 skip=33 count=16 > pw_iv
dd if=pw bs=1 skip=49 count=20 > pw_ekey

#FIRST STEP OF DECRYPTION
#Need to use the PBKDF2 key derivation function with a pass phrase
echo -n 'c2991ec29b1d0cc2b8c3b7556458c298c29203c28b45c2973e78c386c395' | xxd -r -p > pbkdf2_pass.bin

#Append mobile number to the pass phrase
echo -n $number | hexdump -e '2/1 "%02x"' | xxd -r -p >> pbkdf2_pass.bin

#PBKDF2 function (Base64)
echo -ne 'I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPG9wZW5zc2wv
eDUwOS5oPgojaW5jbHVkZSA8b3BlbnNzbC9ldnAuaD4KI2luY2x1ZGUgPG9wZW5zc2wvaG1hYy5o
PgoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkKewoJdW5zaWduZWQgY2hhciBwYXNz
WzEwMjRdOyAgICAgIC8vIHBhc3NwaHJhc2UgcmVhZCBmcm9tIHN0ZGluCgl1bnNpZ25lZCBjaGFy
IHNhbHRbMTAyNF07ICAgICAgLy8gc2FsdCAKCWludCBzYWx0X2xlbjsgICAgICAgICAgICAgICAg
ICAvLyBzYWx0IGxlbmd0aAoJaW50IGljOyAgICAgICAgICAgICAgICAgICAgICAgIC8vIGl0ZXJh
dGlvbgoJdW5zaWduZWQgY2hhciByZXN1bHRbMTAyNF07ICAgIC8vIHJlc3VsdAoJRklMRSAqZnBf
c2FsdDsKCglpZiAoIGFyZ2MgIT0gMyApIHsKCQlmcHJpbnRmKHN0ZGVyciwgInVzYWdlOiAlcyBz
YWx0X2ZpbGUgaXRlcmF0aW9uIDwgcGFzc3dkX2ZpbGUgPiBiaW5hcnlfa2V5X2ZpbGUgXG4iLCBh
cmd2WzBdKTsKCQlleGl0KDEpOwoJfQoKCWljID0gYXRvaShhcmd2WzJdKTsKICAKCWZwX3NhbHQg
PSBmb3Blbihhcmd2WzFdLCAiciIpOwoJaWYoIWZwX3NhbHQpIHsKCQlmcHJpbnRmKHN0ZGVyciwg
ImVycm9yIG9wZW5pbmcgc2FsdCBmaWxlOiAlc1xuIiwgYXJndlsxXSk7CgkJZXhpdCgyKTsKCX0K
CglzYWx0X2xlbj0wOwoJaW50IGNoOwkKCXdoaWxlKChjaCA9IGZnZXRjKGZwX3NhbHQpKSAhPSBF
T0YpIHsJCQoJCXNhbHRbc2FsdF9sZW4rK10gPSAodW5zaWduZWQgY2hhciljaDsJCQoJfQkKCiAg
ICBmY2xvc2UoZnBfc2FsdCk7CQogICAKICAgIGZnZXRzKHBhc3MsIDEwMjQsIHN0ZGluKTsKICAg
IGlmICggcGFzc1tzdHJsZW4ocGFzcyktMV0gPT0gJ1xuJyApCgkJcGFzc1tzdHJsZW4ocGFzcykt
MV0gPSAnXDAnOwogIAoJUEtDUzVfUEJLREYyX0hNQUNfU0hBMShwYXNzLCBzdHJsZW4ocGFzcyks
IHNhbHQsIHNhbHRfbGVuLCBpYywgMTYsIHJlc3VsdCk7CgoJZndyaXRlKHJlc3VsdCwgMSwgMTYs
IHN0ZG91dCk7CgoJcmV0dXJuKDApOwp9Cg=='| base64 -d > wa_pbkdf2.c

gcc -o wa_pbkdf2 wa_pbkdf2.c -lssl
chmod +x wa_pbkdf2

#Generate the output hash from the PBKDF2 function 
./wa_pbkdf2 pw_salt 16 < pbkdf2_pass.bin > pbkdf2_key.bin

#SECOND STEP OF DECRYPTION
k=$(hexdump -e '2/1 "%02x"' pbkdf2_key.bin)
iv=$(hexdump -e '2/1 "%02x"' pw_iv)
openssl enc -aes-128-ofb -d -nosalt -in pw_ekey -K $k -iv $iv -out wa_password.key

read -p "Do you want delete created files during the process? (y/n): " opcion
case $opcion in
      y|Y) 
        rm pw_salt
	rm pw_iv
	rm pw_ekey
	rm pbkdf2_pass.bin
	rm pbkdf2_key.bin
	rm wa_pbkdf2
	rm wa_pbkdf2.c
      ;;
      n|N)
      ;;
      *)
      ;;
esac

echo -n "Your Whatsapp password is: " 
base64 wa_password.key
