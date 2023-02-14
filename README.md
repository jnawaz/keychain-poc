# keychain-poc

## Create the key and cert

`openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes -subj /CN=iphone.example.com`

## Create PKCS12 file
`openssl pkcs12 -export -in cert.pem -inkey key.pem -out iphone.p12 -name "cert alias"`

