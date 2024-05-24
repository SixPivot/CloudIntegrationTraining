Invoke-WebRequest -Uri https://cacerts.digicert.com/DigiCertAssuredIDRootCA.crt -OutFile "C:\Windows\Temp\DigiCertAssuredIDRootCA.crt"
certutil -addstore -f "Root" "C:\Windows\Temp\DigiCertAssuredIDRootCA.crt"
