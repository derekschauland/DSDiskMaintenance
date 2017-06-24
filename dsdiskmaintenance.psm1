<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.140
	 Created on:   	6/24/2017 1:45 PM
	 Created by:   	derek
	 Organization: 	
	 Filename:     	dsdiskmaintenance.psm1
	-------------------------------------------------------------------------
	 Module Name: dsdiskmaintenance
	===========================================================================
#>



function clean-oldfiles
{
    <#
        .EXTERNALHELP .\en-us\dsdiskmaintenance.psm1-Help.xml
    #>
    [cmdletbinding()]
    param ($days = "90",
        [string]$path,
        [switch]$clean)
    
    #$path = "D:\shares\profiles"
    $logpath = "C:\logs\"
    $logname = "clean-oldfiles-deleted-$(get-date -f "MM-dd-yyyy_hh-mm-ss").log"
    $fulllog = $logpath + $logname
    $whatiflogfile = "clean-oldfiles-listing-$(get-date -f "MM-dd-yyyy_hh-mm-ss").log"
    $whatiflog = $logpath + $whatiflogfile
    
    $folders = get-childitem -path $path
    
    if ($clean)
    {
        start-log -LogPath $logpath -logname $logname -ScriptVersion 1.0
        
    }
    else
    {
        start-log -LogPath $logpath -logname $whatiflogfile -ScriptVersion 1.0
        
    }
    
    foreach ($folder in $folers)
    {
        
        if (!(test-path -Path "$path\$folder"))
        {
            if ($clean)
            {
                write-loginfo -LogPath $($whatiflog) -Message "Folder not found - skipped"
                continue
            }
            else
            {
                write-loginfo -LogPath $($fulllog) -Message "Folder not found - skipped"
                continue
            }
        }
        else
        {
            
            
            $files = get-childitem "$path\$folder" -ErrorAction SilentlyContinue | where { $_.lastwritetime -lt (get-date).adddays(- $days) }
            
            if ($clean)
            {
                write-loginfo -LogPath $fulllog -message "Checking files in $($folder):"
                write-loginfo -LogPath $fulllog -Message "Files will be cleaned up that are older than $days"
                foreach ($file in $files)
                {
                    $file | remove-item -force -Recurse
                    write-loginfo -LogPath $fulllog -message "$file was removed."
                }
                
                
                
            }
            else
            {
                write-loginfo -LogPath $whatiflog -message "Checking files in $($folder):"
                write-loginfo -LogPath $whatiflog -message "The following files are older than $days days:"
                foreach ($file in $files)
                {
                    Write-LogInfo -LogPath $whatiflog -message "$file"
                }
                
                
            }
            
            
            
        }
        
    }
    
    # Getting alternate Data streams error when writing logs - need to research before first RUN Thurs @ 7pm
    
    Stop-Log -LogPath $fulllog
    Stop-Log -LogPath $whatiflog
}

Export-ModuleMember -Function clean-oldfiles



