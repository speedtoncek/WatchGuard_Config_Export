# Default WatchGuard SSH port is 4118, but you can change it here if needed
# You need to log in first to accept SSH Key
$CurrentPort = 4118
$WatchGuardList = Get-Content -Path "C:\Users\chmelensky\OneDrive - Alternetivo, s.r.o\Plocha\WatchGuardList.txt"

foreach ($CurrentIP in $WatchGuardList) {
    
    # Skip empty lines in your txt file
    if ([string]::IsNullOrWhiteSpace($CurrentIP)) { continue }

    Write-Host "Processing $CurrentIP..."

    $wgCommand = "export config to console"

    # 1. Declare the simulated input OUTSIDE the plinkArgs array -> We need to press enter after the command to get the output, so we simulate that by creating a here-string that contains the command followed by an exit command. This way, when Plink runs, it will execute the command and then exit cleanly.
    $simulatedInput = @"
$wgCommand
exit
"@

    # 2. Define the Plink arguments array cleanly
    $plinkArgs = @(
        "$CurrentIP",
        "-ssh",
        "-P", $CurrentPort,
        "-l", "backupuser",
        "-pw", "",
        "-batch"
    )

    # 3. CRITICAL: Actually run Plink and capture the output into the variable!
    $rawOutput = $simulatedInput | & "C:\Program Files\PuTTY\plink.exe" $plinkArgs

    # 4. Join the array into a single string so we can search for the XML start and end tags. The `-join "`r`n"` ensures that each line of output is separated by a carriage return and newline, preserving the original formatting.
    $fullText = $rawOutput -join "`r`n"

    # 5. Find where the XML starts - index finds the exact position of the first occurrence of '<?xml' in the string. If it returns -1, that means it wasn't found.
    $startIndex = $fullText.IndexOf('<?xml')

    if ($startIndex -ge 0) {
        # Slice off the top SSH banners
        $cleanXml = $fullText.Substring($startIndex)
        
        # 6. Find where the XML ends
        $endTag = '</profile>'
        $endIndex = $cleanXml.IndexOf($endTag)
        
        if ($endIndex -ge 0) {
            # Slice off the trailing "exit" and CLI prompts
            # The +$endTag.Length ensures that we include the entire closing tag in the substring - we start at 0 and then include number of charachters which is index of the end tag + length of the end tag to include it in the substring.
            $cleanXml = $cleanXml.Substring(0, $endIndex + $endTag.Length)
        }

        # 7. Apply the Regex repair to expand self-closing tags
        $fixedXml = $cleanXml -replace '<([a-zA-Z0-9\-]+)\s*/>', '<$1></$1>'
        
        # 8. Write to file
        $outPath = "C:\Users\chmelensky\OneDrive - Alternetivo, s.r.o\Plocha\WG_Backup_XML2\$($CurrentIP)_config.xml"
        $fixedXml | Out-File -FilePath $outPath -Encoding utf8
        
        Write-Host "Success: Repaired XML saved for $CurrentIP" -ForegroundColor Green
    } else {
        Write-Host "Error: Could not find valid XML in the console output for $CurrentIP" -ForegroundColor Red
    }
}

#$FindOldFiles=get-childitem -recurse -File -Path "C:\Users\chmelensky\OneDrive - Alternetivo, s.r.o\Plocha\WG_Backup_XML2" -Filter "*.xml" #| Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
#remove-Item -Path $FindOldFiles.FullName -Force
