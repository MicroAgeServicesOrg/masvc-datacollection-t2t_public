## Get CLI for Microsoft 365 here: https://pnp.github.io/cli-microsoft365/
## Script inspired from https://veronicageek.com/powershell/powershell-for-m365/get-teams-channels-tabs-and-privacy-settings-using-teams-pnp-powershell/2020/07/
## Author: Patrick Lamber (https://www.nubo.eu)

$fileExportPath = "c:\path\to\export\teamstabs.csv"

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$results = @()
$allTeams = m365 teams team list -o json | ConvertFrom-Json
$teamCount = $allTeams.Count
Write-Host "Processing $teamCount teams..."
#Loop through each Team
$counter = 0
foreach($team in $allTeams){
    $counter++
    Write-Host "Processing $($team.id)... ($counter/$teamCount)"
    $allChannels = m365 teams channel list --teamId $team.id -o json | ConvertFrom-Json
    
    #Loop through each Channel
    foreach($channel in $allChannels){
        $allTabs = m365 teams tab list --teamId $team.id --channelId $channel.id -o json | ConvertFrom-Json
        
        #Loop through each Tab + get the info!
        foreach($tab in $allTabs){
            $results += [pscustomobject][ordered]@{
                TeamId = $team.id
                TeamDisplayName = $team.displayName
                TeamIsArchived = $team.isArchived
                TeamVisibility = $team.visibility
                ChannelId = $channel.id
                ChannelDisplayName = $channel.DisplayName
                ChannelMemberShipType = $channel.membershipType
                TabId = $tab.id
                TabNameDisplayName = $tab.DisplayName
                TeamsAppTabId = $tab.teamsAppTabId
            }
        }
    }
}
Write-Host "Exporting file to $fileExportPath.."
$results | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."