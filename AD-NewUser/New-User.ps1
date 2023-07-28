# TODO:
# Get list of all accepted domains in pre-requisites part (Get-AcceptedDomain)
# Add a combobox to select the domain
# Populate user email with domain selected

# Global enviroment variables
$FieldsExpected = 6
$ConfigFilePath = ".\config.ini"
$LogoFilePath = ".\logo.png"
$CriticalError = $False
$CriticalErrorMessage = ""

# Global display variables
$Column1 = 1
$Column2 = 80
$Column3 = 220
$Column4 = 300
$Column5 = 350
$RowMarker = 0
$RowPadding = 10

# Global elements
$FormElements = @()


# Get configuration
If (Test-Path -Path $ConfigFilePath -PathType Leaf) {
    Foreach ($i in $(Get-Content $ConfigFilePath)){
        Set-Variable -Name "config_$($i.split("=")[0])" -Value $i.split("=",2)[1]
    }
} Else {
    Write-Host "Config file not found, create new one"
    New-Item -Path $ConfigFilePath -ItemType File | Out-Null
    Set-Content -Path $ConfigFilePath -Value "lang=en`ndisplay_logo=no`nou_base`n" | Out-Null
}


############# Validate prerequisites ################
If (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    $CriticalError = $True
    $CriticalErrorMessage += "ActiveDirectory module not found`n"
}

# Get list of OU names
Try {
    $OUsNames = Get-ADOrganizationalUnit -Filter * -SearchBase $Config_ou_base -SearchScope Subtree | Select Name
    } Catch {
    $CriticalError = $True
    $CriticalErrorMessage += "Error getting list of OUs of '$config_ou_base'`n"
}

Write-Host "OUsNames = $OUsNames"

# if Critical Error, create error form

if ($CriticalError) {
    Add-Type -assembly System.Windows.Forms
    $ErrorForm = New-Object System.Windows.Forms.Form
    $ErrorForm.Text ='Error'
    $ErrorForm.Width = 500
    $ErrorForm.Height = 200

    $CriticalErrorLog = New-Object System.Windows.Forms.RichTextBox
    $CriticalErrorLog.Text = $CriticalErrorMessage
    $CriticalErrorLog.Location  = New-Object System.Drawing.Point(10,10)
    $CriticalErrorLog.Size = New-Object System.Drawing.Size(480,200)
    $CriticalErrorLog.ForeColor = "Red"
    $CriticalErrorLog.Font = 'Microsoft Sa ns Serif,10'
    $CriticalErrorLog.ReadOnly = $true

    $ErrorForm.Controls.Add($CriticalErrorLog)
    $ErrorForm.ShowDialog()
    Exit
}


# Define main form
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Create AD User'
$main_form.Width = 600
$main_form.Height = 500

################  Functions ################

Function Row-Append($amount) {
    $global:RowMarker = $global:RowMarker + ($RowPadding * $amount)
}

Function New-Label ($Title, $Column, $size) {
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Title
    $Label.Location  = New-Object System.Drawing.Point($Column,$global:RowMarker)
    $Label.AutoSize = $true

    If ($size -ne $null) {
        $Label.Size = New-Object System.Drawing.Size([int]$size,20)
    }

    return $Label
}

Function New-TextBox ($Column, $size) {
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Location = New-Object System.Drawing.Point($Column,$global:RowMarker)
    $TextBox.AutoSize = $true

    If ($size -ne $null) {
        #$TextBox.Size = New-Object System.Drawing.Size(100,[int]$size)
        $TextBox.Size = New-Object System.Drawing.Size([int]$size,20)
    } Else {
        $TextBox.Size = New-Object System.Drawing.Size(130,20)
    }

    Return $TextBox
}

Function New-RichTextBox ($Column, $size) {
    $RichTextBox = New-Object System.Windows.Forms.RichTextBox
    $RichTextBox.Location = New-Object System.Drawing.Point($Column,$global:RowMarker)
    $RichTextBox.AutoSize = $true

    If ($size -ne $null) {
        $RichTextBox.Size = New-Object System.Drawing.Size([int]$size,20)
    }

    Return $RichTextBox
}

Function New-ComboBox ($Column, $Content) {
    $ComboBox = New-Object system.Windows.Forms.ComboBox
    $ComboBox.width = 170
    $ComboBox.autosize = $true
    
    # Add OU to list
    $Content | ForEach-Object {[void] $ComboBox.Items.Add($_)}
    
    # Select the default value
    $ComboBox.SelectedIndex = 0
    $ComboBox.location = New-Object System.Drawing.Point($Column,$global:RowMarker)
    $ComboBox.Font = ‘Microsoft Sans Serif,10’

    return $ComboBox
}

Function New-Button($Column, $Text) {
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Size($Column,$global:RowMarker)
    $Button.Size = New-Object System.Drawing.Size(120,23)
    $Button.Text = $Text

    Return $Button
}

Function Add-Logo () {
    If ($config_display_logo -eq "yes") {

        if (Test-Path -Path $LogoFilePath -PathType Leaf) {
            $file = (get-item $LogoFilePath)
            [reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
            $img = [System.Drawing.Image]::Fromfile($file);
            [System.Windows.Forms.Application]::EnableVisualStyles();
            $pictureBox = new-object Windows.Forms.PictureBox
            $pictureBox.Location = New-Object System.Drawing.Size(300,100)
            $pictureBox.Size = New-Object System.Drawing.Size($img.Width,$img.Height)
            $pictureBox.Image = $img
            $main_form.controls.add($pictureBox)
        } else {
            Log-Error "logo File not found at $LogoFilePath"
        }
    }
}


Function Fill-UserLogon() {
    $FirstName = $FirstNameInput.Text
    $LastName = $LastNameInput.Text
    $LogonName = $FirstName.ToLower() + "." + $LastName.ToLower()
    $LogonNameInput.Text = $LogonName
}

Function Load-RawData() {

    $ClipboardContent = Get-Clipboard
    Write-Host "Got from clipboard: $ClipboardContent"
    $RawDataArr = $ClipboardContent.Trim().Split(";")

    If ($RawDataArr.Count -lt $FieldsExpected) {
        Log-Error "Raw data field count of $($RawDataArr.Count) is not uqual to expected $FieldsExpected"
        return
    }
    $FirstNameInput.Text = $RawDataArr[0]
    $LastNameInput.Text = $RawDataArr[1]
    $DisplayNameInput.Text = $RawDataArr[2]
    $JobTitleInput.Text = $RawDataArr[3]
    $OfficeInput.Text = $RawDataArr[4]
    $LogonNameInput.Text = $RawDataArr[5]

    Log-Info "Raw data loaded"
}

Function Log-Error($Message) {

    Write-Host $Message
    $MessageLog.Text = $Message
    $MessageLog.ForeColor = "Red"

}

Function Log-Info($Message) {

    Write-Host $Message
    $MessageLog.Text = $Message
    $MessageLog.ForeColor = "Black"

}

Function Create-NewUser($Attributes) {

    $Attributes = @{
        Enabled = $true
        ChangePasswordAtLogon = $true
        UserPrincipalNAme = $LogonNameInput.Text
        DisplayName = $DisplayNameInput.Text
        EmailAddress = "$($LogonNameInput.text)@kavim-t.co.il"
        GivenName = $FirstNameInput.Text
        SamAccountName = $LogonNameInput.Text
        Surname = $LastNameInput.Text
        AccountPassword = $("Aa1234" | ConvertTo-SecureString -AsPlainText -Force)
        Path = $OUList.SelectedItem
        Confirm = $True
    }


    Try {
        New-ADUser @Attributes -ErrorAction Stop
    } Catch {Log-Error $_.Exception.Message}
    if ($Error) {
        Log-Info "User $($Attributes.Name) created"
    }
}

########### Flow #########

# Raw Data
$RawDataLoad = New-Button $Column5 "Load from Clipboard"
$FormElements+=$RawDataLoad

# First Name
$FirstNameLabel = New-Label "First Name" $Column1
$FirstNameInput = New-TextBox $Column2
$FormElements+=$FirstNameLabel
$FormElements+=$FirstNameInput
Row-Append 2

# Last Name
$LastNameLabel = New-Label "Last Name" $Column1
$LastNameInput = New-TextBox $Column2
$FormElements+=$LastNameLabel
$FormElements+=$LastNameInput
Row-Append 2

# Display Name
$DisplayNameLabel = New-Label "Display Name" $Column1
$DisplayNameInput = New-TextBox $Column2
$FormElements+=$DisplayNameLabel
$FormElements+=$DisplayNameInput
Row-Append 2

# Job Title
$JobTitleLabel = New-Label "Job Title" $Column1
$JobTitleInput = New-TextBox $Column2
$FormElements+=$JobTitleLabel
$FormElements+=$JobTitleInput
Row-Append 2

# Office
$OfficeLabel = New-Label "Office" $Column1
$OfficeInput = New-TextBox $Column2
$FormElements+=$OfficeLabel
$FormElements+=$OfficeInput
Row-Append 2

# Login Name
$LogonNameLabel = New-Label "Logon Name" $Column1
$LogonNameInput = New-TextBox $Column2
$FormElements+=$LogonNameLabel
$FormElements+=$LogonNameInput
Row-Append 2

# OU Choice

 # Create a group that will contain your radio buttons
    $OUSourceChoice = New-Object System.Windows.Forms.GroupBox
    $OUSourceChoice.Location = New-Object System.Drawing.Point($Column1,$RowMarker)
    $OUSourceChoice.size = '10,10'
    $OUSourceChoice.text = "Select OU"
    $FormElements+=$OUSourceChoice

    Row-Append 1
    
    # Create the collection of radio buttons
    $OuCopy = New-Object System.Windows.Forms.RadioButton
    $OuCopy.location = New-Object System.Drawing.Point($Column1,$RowMarker)
    $OuCopy.size = '350,20'
    $OuCopy.Checked = $true 
    $OuCopy.Text = "Copy From"
    $FormElements+=$OuCopy

    Row-Append 1
 
    $OuSelect = New-Object System.Windows.Forms.RadioButton
    $OuSelect.location = New-Object System.Drawing.Point($Column1,$RowMarker)
    $OuSelect.size = '350,20'
    $OuSelect.Checked = $false
    $OuSelect.Text = "Select"
    $FormElements+=$OuSelect

    Row-Append 1

    # Add all the GroupBox controls on one line
    $OUSourceChoice.Controls.AddRange(@($OuCopy,$OuSelect))

Row-Append 2

# OU
$OULabel = New-Label "OU" $Column1
$OUList = New-ComboBox $Column2 $OUsNames
$FormElements+=$OULabel
$FormElements+=$OUList
Row-Append 2

# Submit Button
$CreateButton = New-Button $Column1 "Run"
$FormElements+=$CreateButton
Row-Append 2

# Message Log
$MessageLog = New-RichTextBox $Column1
$MessageLog.Size = New-Object System.Drawing.Size(400,100)
$MessageLog.ReadOnly=$True
$MessageLog.MultiLine = $True 
$FormElements+=$MessageLog
Row-Append

# Logo
Add-Logo


########### Events ############

$CreateButton.Add_Click({Create-NewUser})


$RawDataLoad.Add_Click({Load-RawData})
$FirstNameInput.Add_TextChanged({Fill-UserLogon})
$LastNameInput.Add_TextChanged({Fill-UserLogon})

########### Finalize Form ############

# Load elements into Form
$FormElements | ForEach-Object { $main_form.Controls.Add($_) }

# Show form
$main_form.ShowDialog()


