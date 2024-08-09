$clientId = "YOUR_CLIENT_ID"
$tenantId = "YOUR_TENANT_ID"

Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.Authentication

# Connect using certificate Thumbprint
Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumbprint "YOUR_CERT_THUMBPRINT" -NoWelcome

$MaxPasswordAge = 90
$Today = (Get-date)
$First_Notification = 14
$Second_Notification = 7
$from = "YOUR_EMAIL_SENDER"

$Date  = Get-date -Format ddMMMyyHHmmss
$Domain = Get-MgDomain | where {$_.IsDefault -eq $true }

# PW for SMTP
$secpasswd = ConvertTo-SecureString “<YOUR_SMTP_PW>” -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential (“<>”, $secpasswd)

# For Email message timestamp
$CETZONE= [System.TimeZoneInfo]::FindSystemTimeZoneById("Romance Standard Time")
$CETTIME = [System.TimeZoneInfo]::ConvertTimeFromUtc((Get-Date).ToUniversalTime(), $CETZONE)

$newline = "<br>"
$body = ""
$Users = ""
$User  = ""

$users = Get-MgUser -All

$index = 0
$indexExpiringUser = 0

foreach ($user in $users) {

    $usersProperties = Get-MgUser -UserId $user.Id -Property "UserPrincipalName, PasswordPolicies, LastPasswordChangeDateTime, otherMails" | Select UserPrincipalName, PasswordPolicies, LastPasswordChangeDateTime, otherMails

     #Write-Host $user.displayName $usersPwChangeDate

     $UPN = $User.UserPrincipalName
     $Expireson = $usersProperties.LastPasswordChangeDateTime.AddDays($MaxPasswordAge)
     $Daystoexpire = (New-TimeSpan -Start $Today -End $Expireson).Days


    # users that does not have Password Policy DisablePasswordExpiration
    if ($usersProperties.PasswordPolicies -eq "None")
    {
        $index = $index+1
       # Write-Host "This user does not have disable PW Expiration:" $index $user.UserPrincipalName $user.LastPasswordChangeDateTime
       # Write-Host $user.LastPasswordChangeDateTime
         

        if ( ($Daystoexpire -ge 0) -And ($Daystoexpire -lt 15) ) {


            If (($Daystoexpire -eq $First_Notification) -or ($Daystoexpire -eq $Second_Notification) ) {

                #$User |Select-Object DisplayName,UserPrincipalName | export-csv -Append $OutFileName -NoTypeInformation

                # Index how many users have expiring password
                $indexExpiringUser = $indexExpiringUser+1

                $subject = "Your Azure password will expire in " + $Daystoexpire + " day(s)"

                $body = ""
                $body += "Dear " + $User.GivenName + "," + $newline + $newline
                $body += " The password for your Azure account '<font color=blue>" + $UPN + "</font>' is due to expire in " + $Daystoexpire + " day(s)." 
                $body += " Please remember to change your password before <u><font color=blue>" + $Expireson.date.tostring('dd/MM/yyyy') + "</font></u>."
                $body += $newline + $newline
                $body += "<b>How do I change my password? Just follow this simple step/s!</b>"
                $body += $newline + $newline
                $body += "<li>Open Incognito/InPrivate window and login to <a href=https://mysignins.microsoft.com/security-info/password/change>this site</a> with your  '<font color=blue>" + $Domain.Id.split(".")[0] + "</font>' Credentials.</li>"
                $body += $newline + $newline
                $body += "If you have forgotten your password, you can use <a href=https://passwordreset.microsoftonline.com>this site</a> to reset your password or email YOUR_EMAIL at <YOUR_EMAIL_SENDER> should you require further assistance."
                $body += $newline + $newline + $newline
                $body += "Thank You," + $newline
                $body += "Your IT" + $newline
                $body += "Email: "YOUR_EMAIL_SENDER""
                $body += $newline + $newline
                $body += "<h5>[Message Timestamp: $CETTIME]</h5>"
                $body += "</font>" 

                Write-Output $indexExpiringUser"." "Sending email to: " $User.displayName

                if ($usersProperties.otherMails.count -eq 2){

                    $first_email = $usersProperties.otherMails[0]
                    $second_email = $usersProperties.otherMails[1]
                    # sending email to user
                    Send-MailMessage -SmtpServer <YOUR_SMTP_SERVER> -Credential $credential -Subject $subject -BodyAsHtml  -Body $body -From "YOUR_EMAIL <YOUR_EMAIL_SENDER>" -To $first_email
                    Send-MailMessage -SmtpServer <YOUR_SMTP_SERVER> -Credential $credential -Subject $subject -BodyAsHtml  -Body $body -From "YOUR_EMAIL <YOUR_EMAIL_SENDER>" -To $second_email
    
                } elseif ($usersProperties.otherMails.count -eq 1){

                    $first_email = $usersProperties.otherMails[0]
                    # sending email to user
                    Send-MailMessage -SmtpServer <YOUR_SMTP_SERVER> -Credential $credential -Subject $subject -BodyAsHtml  -Body $body -From "YOUR_EMAIL <YOUR_EMAIL@eon.com>" -To $first_email
                }

            }

            if ($Daystoexpire -le 5) {

                #$User |Select-Object DisplayName,UserPrincipalName | export-csv -Append $OutFileName -NoTypeInformation

                # Index how many users have expiring password
                $indexExpiringUser = $indexExpiringUser+1

                $subject = "Your Azure password will expire in " + $Daystoexpire + " day(s)"

                $body = $Null
                $body += "Dear " + $User.GivenName + "," + $newline + $newline
                $body += " The password for your Azure account '<font color=blue>" + $UPN + "</font>' is due to expire in " + $Daystoexpire + " day(s)." 
                $body += " Please remember to change your password before <u><font color=blue>" + $Expireson.date.tostring('dd/MM/yyyy') + "</font></u>."
                $body += $newline + $newline
                $body += "<b>How do I change my password? Just follow this simple step/s!</b>"
                $body += $newline + $newline
                $body += "<li>Open Incognito/InPrivate window to and login to <a href=https://mysignins.microsoft.com/security-info/password/change>this site</a> with your $Domain.Id.split(".")[0] + "</font>' Credentials.</li>"
                $body += $newline + $newline
                $body += "If you have forgotten your password, you can use <a href=https://passwordreset.microsoftonline.com>this site</a> to reset your password or email YOUR_EMAIL at YOUR_EMAIL@eon.com should you require further assistance."
                $body += $newline + $newline + $newline
                $body += "Thank You," + $newline
                $body += "Your IT" + $newline
                $body += "Email: YOUR_EMAIL_SENDER"
                $body += $newline + $newline
                $body += "<h5>[Message Timestamp: $CETTIME]</h5>"
                $body += "</font>" 

                Write-Output $indexExpiringUser"." "Sending email to: " $User.displayName

                if ($usersProperties.otherMails.count -eq 2){

                    $first_email = $usersProperties.otherMails[0]
                    $second_email = $usersProperties.otherMails[1]
                    # sending email to user
                    Send-MailMessage -SmtpServer <YOUR_SMTP_SERVER> -Credential $credential -Subject $subject -BodyAsHtml  -Body $body -From "YOUR_EMAIL <YOUR_EMAIL_SENDER>" -To $first_email
                    Send-MailMessage -SmtpServer <YOUR_SMTP_SERVER> -Credential $credential -Subject $subject -BodyAsHtml  -Body $body -From "YOUR_EMAIL <YOUR_EMAIL_SENDER>" -To $second_email
            
                } elseif ($usersProperties.otherMails.count -eq 1){

                    $first_email = $usersProperties.otherMails[0]
                    # sending email to user
                    Send-MailMessage -SmtpServer <YOUR_SMTP_SERVER> -Credential $credential -Subject $subject -BodyAsHtml  -Body $body -From "YOUR_EMAIL <YOUR_EMAIL_SENDER>" -To $first_email
           }

           }

        }
    }

}

