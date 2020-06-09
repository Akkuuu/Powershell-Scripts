Import-Module NTFSSecurity
$dt=get-date -Format "MM-dd-yyyy"
Start-Transcript -Path "Path\HR-Log-$dt.txt" # Transcript Path

### Check time ###
#Elapsed Time
#$StartTime = $(get-date)
#$elapsedTime = $(get-date) - $StartTime
#$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)

###Mail Notification###
#$SMTPConnection = @{
    #Use Office365, Gmail, Other or OnPremise SMTP Relay FQDN
    #SmtpServer = 'outlook.office365.com'

    #OnPrem SMTP Relay usually uses port 25 without SSL
    #Other Public SMTP Relays usually use SSL with a specific port such as 587 or 443
    #Port = 587 
    #UseSsl = $true    
    #Credential = Get-Credential -Message 'Enter SMTP Login' -UserName "test@test.com"
#}

#Exclusion list
#$ExcludedcDirectory = "Test"

    
Function Remove-ACL {    
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [String[]]$Folder,
        [Switch]$Recurse
    )

    Process {

        foreach ($f in $Folder) {

            if ($Recurse) {$Folders = $(Get-ChildItem $f -Recurse -Directory).FullName} else {$Folders = $f}

            if ($Folders -ne $null) {

                $Folders | ForEach-Object {

                    # Remove inheritance
                    $acl = Get-Acl $_
                    $acl.SetAccessRuleProtection($true,$true)
                    Set-Acl $_ $acl

                    # Remove ACL
                    $acl = Get-Acl $_ 
                    $acl.Access | %{$acl.RemoveAccessRule($_)} | Out-Null

                    # Add local admin
                    $DomainMain = 'BUILTIN\Administrators'
                    $permission  = $domainmain, "FullControl", "ContainerInherit,ObjectInherit","None","Allow"
                    $permission2  = $DomainAdmins, "FullControl", "ContainerInherit,ObjectInherit","None","Allow"


                    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
                    $acl.SetAccessRule($rule)
                    Try{
                    Set-Acl $_ $acl
                    }
                    Catch
                    { write-host 'Permission denied'
                    }
                    Write-Verbose "Remove-HCacl: Inheritance disabled and permissions removed from $_"
                }
            }
            else {
                Write-Verbose "Remove-HCacl: No subfolders found for $f"
            }
        }
    }
}

        $ExampleGroup = 'DOMAIN.LOCAL\TEST'

        Try  {

        $Folder1 = Get-ChildItem2 -path 'B:\Data\FOLDER1' -Directory -Recurse -Filter *.jpg -file -Name | sort Name -Descending | select -First 1  foreach-object { ApplyWorkflow($_) } -ErrorAction SilentlyContinue
        $Folder2 = Get-ChildItem2 -path 'B:\Data\FOLDER2' -Directory -Recurse -Filter *.jpg -file -Name | sort Name -Descending | select -First 1  foreach-object { ApplyWorkflow($_) } -ErrorAction SilentlyContinue
        # Specific Folders -> $Folder3 = Get-ChildItem2 -path 'B:\Data\FOLDER3' -Directory -Recurse -Filter *.jpg -file -Name | sort Name -Descending | select -First 1  foreach-object { ApplyWorkflow($_) } -ErrorAction SilentlyContinue | where Name -NotMatch $ExcludedcDirectory
        # Specific Folders -> $Folder4 = Get-ChildItem2 "B:\Data\FOLDER4" -Directory -Recurse -Filter *.jpg -file -Name | sort Name -Descending | select -First 1  foreach-object { ApplyWorkflow($_) } -ErrorAction SilentlyContinue | where Name -NotMatch $ExcludedcDirectory 

        } 
        Catch
        {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-host "Permission Denied, continuing"
        } 

        #Try{
        
        #Remove-ACL $TestTest -verbose -recurse -ErrorAction SilentlyContinue #By default, a non-terminating error will not trigger your catch handling. So, if you want to force powershell to catch the error no matter what type it is, you can append -ErrorAction Stop
        #}   
        #Catch
        #{
        #Write-host "Permission Denied, continuing"
        #} 
        foreach ($Item in $TestTest) { 
        Disable-NTFSAccessInheritance -PassThru
        Add-NTFSAccess -Path $Item -Account $GROUPNAMEHERE -AccessRights ReadAndExecute, Write, Modify #####CHANGE PERMISSION INSTEAD OF DELETING IT.
        $ExtraFolder = (Get-childitem2 $Item -erroraction SilentlyContinue | Measure-Object).Count;
        write-host $ExtraFolder 'Folders Found for' $Item
        write-host -$item  "---Permissions Removed for the folder and readded" -ForegroundColor Green 
    }
    

        Start-Sleep -s 2
        #write-host $totalTime
        Stop-Transcript
		Start-sleep -s 5
		#Send-MailMessage @SMTPConnection -From 'User01 <TEST@TEST.COM>' -To 'User02 <TEST2@TEST2.COM>' -Subject 'HR Script Report' -Body "HR Script Report. Success. Stored in 'C:\Users\TEST\HR-Log-$dt' " -Attachments "C:\Users\TEST\HR-Log-$dt.txt" -Priority High -DeliveryNotificationOption OnSuccess, OnFailure