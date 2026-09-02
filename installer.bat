@echo off
setlocal

set "GH_USER=Yuvald12321"

powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command ^
    "Add-Type -AssemblyName System.Windows.Forms;" ^
    "Add-Type -AssemblyName System.Drawing;" ^
    "$user = '%GH_USER%';" ^
    "$downloadFolder = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads');" ^
    "if (-not (Test-Path $downloadFolder)) {" ^
    "    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog;" ^
    "    $fbd.Description = 'Select the downloads folder';" ^
    "    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {" ^
    "        $downloadFolder = $fbd.SelectedPath;" ^
    "    }" ^
    "};" ^
    "$programs = @{};" ^
    "try {" ^
    "    $headers = @{ 'User-Agent' = 'Batch-Installer' };" ^
    "    $reposUrl = \"https://api.github.com/users/$user/repos\";" ^
    "    $repos = Invoke-RestMethod -Uri $reposUrl -Headers $headers -Method Get;" ^
    "    foreach ($repo in $repos) {" ^
    "        $distUrl = \"https://api.github.com/repos/$user/$($repo.name)/contents/dist\";" ^
    "        try {" ^
    "            $contents = Invoke-RestMethod -Uri $distUrl -Headers $headers -Method Get;" ^
    "            foreach ($item in $contents) {" ^
    "                if ($item.name -like '*.exe') {" ^
    "                    $programs[$item.name] = $item.download_url;" ^
    "                }" ^
    "            }" ^
    "        } catch {}" ^
    "    }" ^
    "} catch {" ^
    "    [System.Windows.Forms.MessageBox]::Show('Error fetching repositories: ' + $_.Exception.Message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error);" ^
    "};" ^
    "$form = New-Object System.Windows.Forms.Form;" ^
    "$form.Text = 'Installer';" ^
    "$form.Size = New-Object System.Drawing.Size(320, 220);" ^
    "$form.StartPosition = 'CenterScreen';" ^
    "$form.FormBorderStyle = 'FixedDialog';" ^
    "$form.MaximizeBox = $false;" ^
    "$label = New-Object System.Windows.Forms.Label;" ^
    "$label.Text = 'Select a program to install:';" ^
    "$label.Location = New-Object System.Drawing.Point(30, 20);" ^
    "$label.AutoSize = $true;" ^
    "$form.Controls.Add($label);" ^
    "$comboBox = New-Object System.Windows.Forms.ComboBox;" ^
    "$comboBox.Location = New-Object System.Drawing.Point(30, 50);" ^
    "$comboBox.Size = New-Object System.Drawing.Size(240);" ^
    "$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList;" ^
    "$comboBox.Items.Add('Select Program');" ^
    "foreach ($key in $programs.Keys) { [void]$comboBox.Items.Add($key); };" ^
    "$comboBox.SelectedIndex = 0;" ^
    "$form.Controls.Add($comboBox);" ^
    "$button = New-Object System.Windows.Forms.Button;" ^
    "$button.Text = 'Install';" ^
    "$button.Location = New-Object System.Drawing.Point(30, 100);" ^
    "$button.Size = New-Object System.Drawing.Size(240, 35);" ^
    "$button.Add_Click({" ^
    "    $selected = $comboBox.SelectedItem.ToString();" ^
    "    if ($selected -ne 'Select Program' -and $programs.ContainsKey($selected)) {" ^
    "        $url = $programs[$selected];" ^
    "        $targetPath = [System.IO.Path]::Combine($downloadFolder, $selected);" ^
    "        try {" ^
    "            Invoke-WebRequest -Uri $url -OutFile $targetPath -Headers @{ 'User-Agent' = 'Batch-Installer' };" ^
    "            [System.Windows.Forms.MessageBox]::Show(\"Successfully downloaded $selected to $downloadFolder\", 'Success', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information);" ^
    "        } catch {" ^
    "            [System.Windows.Forms.MessageBox]::Show(\"Error downloading $selected : \" + $_.Exception.Message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error);" ^
    "        }" ^
    "    } else {" ^
    "        [System.Windows.Forms.MessageBox]::Show('Please select a valid program.', 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning);" ^
    "    }" ^
    "});" ^
    "$form.Controls.Add($button);" ^
    "[void]$form.ShowDialog();"

endlocal