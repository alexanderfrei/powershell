$certname = "CERTIFICATE_NAME"    ## Replace {CERTIFICATE_NAME}


# This command specifies a value for NotAfter. The certificate expires in 48 months.
# This will put the cert in Local Computer -CertStoreLocation "cert:\LocalMachine\My"
# This will put the cert in Current User -CertStoreLocation "cert:\CurrentUser\My" ---> Certificates --> Current User --> Personal --Certificates
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter (Get-Date).AddMonths(48)

#The command below exports the certificate in .cer format. You can also export it in other formats supported on the Azure portal including .pem and .crt.
Export-Certificate -Cert $cert -FilePath "C:\Users\admin\Documents\$certname.cer"   ## Specify your preferred location

#this is to export the private key
$mypwd = ConvertTo-SecureString -String "YOUR_PASSPHRASE" -Force -AsPlainText  ## Replace {YOUR_PASSPHRASE}
Export-PfxCertificate -Cert $cert -FilePath "C:\Users\admin\Documents\$certname.pfx" -Password $mypwd   ## Specify your preferred location
