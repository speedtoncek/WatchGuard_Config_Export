# This script is designed to sort XML backup files into corresponding folders based on a prefix in their filenames. It also appends a timestamp to the folder names and moves them to a backup destination.
# This is the folder where you want to sort the XML files
$OperationFolder = ""

# Folder needs to exist, otherwise the script will throw an error. You can create it manually or add a command to create it in the script.
# Format is Public_IP_<timestamp>

#Get only the XML files and folders
$XmlFiles = Get-ChildItem -Path $OperationFolder -Filter "*.xml"
$Folders = Get-ChildItem -Path $OperationFolder -Directory 

foreach ($xmlfile in $XmlFiles) {
    # 1. We get the prefix from the filename by splitting the name at the underscore and taking the first part. This assumes that the naming convention of the XML files is consistent and that the prefix is always before the first underscore.
    $xmlbasename = $xmlfile.Name.Split('_')[0]
    
    # 2. We find the folder that matches the prefix of the XML file. We use the Where-Object cmdlet to filter the list of folders, checking if the first part of each folder's name (split by underscore) matches the prefix we extracted from the XML file's name.
    # ($_.Name represents the name of the current folder being evaluated in the Where-Object cmdlet, and we split it by underscores to compare its first part with the prefix of the XML file.)
    # ($xmlbasename represents the prefix of the current XML file being evaluated)
    # By using Where-Object, we filter the folders to find the one whose name (split by underscores) has the first part matching the prefix of the XML file.
    $matchingFolder = $Folders | Where-Object { $_.Name.Split('_')[0] -eq $xmlbasename }

    # 3. Test if match is found, if yes, move the file to the matching folder. If no match is found, output an error message.
    if ($matchingFolder) {
        Write-Host "Shoda nalezena! Soubor '$($xmlfile.Name)' patří do složky '$($matchingFolder.Name)'" -ForegroundColor Green
        
        #Používáme xmlfile.FullName a matchingFolder.FullName, abychom zajistili, že se pracuje s úplnými cestami k souborům a složkám, což je důležité pro správné přesunutí souboru.
        #Nelze použít xmlbasename, protože to je jen název souboru bez cesty, a Move-Item potřebuje úplnou cestu k souboru a cílové složce.
        #Používáme .Fullname kvůli tomu, aby měl skrip absolutní cestu k souboru a složce, což je nezbytné pro správné fungování příkazu Move-Item, jinak by skript nefungoval, kdyby nebyl ve stejném adresáři jako soubor nebo složka, se kterou pracuje.
        Move-Item -Path $xmlfile.FullName -Destination $matchingFolder.FullName -Force
        
    } else {
        Write-Host "Error: For file '$($xmlfile.Name)' no matching folder found." -ForegroundColor Red
    }
}

# We define the date outside the loop to ensure that all folders will have the same timestamp in their names, which is important for backup consistency. If the date were defined inside the loop, each folder could have a different timestamp, which could lead to confusion when identifying backups, as the loop will run for some time, hence the timestamp will differ.
#Datum definujeme mimo cyklus, aby se zajistilo, že všechny složky budou mít stejný časový razítko v názvu, což je důležité pro konzistenci záloh. Pokud by se datum definovalo uvnitř cyklu, každá složka by mohla mít jiné časové razítko, což by mohlo vést k nejasnostem při identifikaci záloh, je to kvůli tomu, že cyklus nějakou dobu poběží, proto se bude lišit timestamp
$BackupDate=Get-Date -Format "dd-MM-yyyy-HH-mm-ss"
$BackupDestination=""

foreach($folder in $Folders) {
    $NewFolderName="$($folder.Name)_$BackupDate"

    # Creation of the new folder with the timestamp appended to its name. This ensures that each backup folder is unique and easily identifiable by the date and time of the backup.
    #Sestavení cílové cesty pro kopírování složky, která kombinuje základní cestu pro zálohy a nový název složky, který obsahuje původní název složky a aktuální datum a čas. Tímto způsobem se zajistí, že každá záloha bude mít unikátní název složky, což usnadní identifikaci a správu záloh.
    $DestinationPath = "$BackupDestination\$NewFolderName"
    move-Item -Path $folder.FullName -Destination $DestinationPath -Recurse -Force
}
