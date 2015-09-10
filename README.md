# WhatsappKey
WhatsappKey is a bash script just to get the Whatsapp password from 'pw' and 'me' files.

## Usage
**Android**

1. Get 'pw' file: `/data/data/com.whatsapp/files/pw`
2. Get 'me' file: `/data/data/com.whatsapp/files/me`
3. Copy them to the same directory is WhatsappKey.sh on your computer
4. `$ ./WhatsappKey.sh`
5. Whatsapp password will be shown
6. Furthermore, your Whatsapp password will be stored in a file called `wa_password.key`
7. To show the pass again: `$ base64 wa_password.key`

## Captures

![Screenshot](http://i.imgur.com/BvRov2R.png?1 "First step")

![Screenshot](http://i.imgur.com/SNSzqPc.png?2 "Final result")

![Screenshot](http://i.imgur.com/j9VIejp.png?2 "wa_password.key created")

## Notes

-Error like “undefined reference to PKCS5_PBKDF2_HMAC_SHA1“, change `gcc -o wa_pbkdf2 wa_pbkdf2.c -lssl` to `gcc -o wa_pbkdf2 wa_pbkdf2.c -lcrypto`

-Remember to give permission to the script: `$ chmod +x WhatsappKey.sh`

## Credits

http://www.digitalinternals.com/security/extract-whatsapp-password-android/374/
