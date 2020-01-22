Function New-ProxyCommand {
<#
.SYNOPSIS
    Generate the sourcecode for a ProxyCommand to call a base Cmdlet adding or removing functionality (parameters).

.DESCRIPTION
    Generate the sourcecode for a ProxyCommand to call a base Cmdlet adding or removing functionality (parameters).
    
    This command generates a command which calls another command (a ProxyCommand).
    In doing so, it can add new parameters or remove existing parameters from the original command.
    Even you can add functionality or change the behavior of the command. 
    If you ADD a parameter, you'll have
    to implement the semantics of that parameter in the code that gets generated.

    There are bits of background knowledge you need for proxy functions.

    1. Command Precedence (See: Get-Help about_Command_Precedence)
         If you do not specify a path, Windows PowerShell uses the following
         precedence order when it runs commands:
            1. Alias
            2. Function
            3. Cmdlet 
            4. Native Windows commands
        Aliases beat Functions, Functions beat Cmdlets. Cmdlets beat external scripts and programs.
        A function named "Get-ChildItem" will be called instead of a cmdlet named "Get-ChildItem" – meaning a
        function can replace a cmdlet simply by giving it the same name. That is the starting point for a Proxy function.

    2. Steppable Pipeline
        A pipeline (Functions and Cmdlets) can have a 3 internal Named Scriptblocks with the keywords Begin{}, Process{} and End{}.
        The Begin{} block runs once and initialisize the command (it is recomended that the Begin{} block should not do any output!)
        The Begin{} block is intended to open needed rescources (databases), or to initialisize Variables inner nested functions.
        The Process{} block runs for each item passed via the pipeline (it is best to do command output here) 
        The End{} block runs after the last item has passed through Process[} block (the End{} block can do output (eg. on a sort process))
        The End{} block schould do the cleanup work to close rescources (databases) or to do tidy up work.
        Given a script block that contains a single pipeline, the GetSteppablePipeline()
        method returns a SteppablePipeline object that gives you control over the Begin, Process, and End
        stages of the pipeline.
    3. Argument Splatting.
        Given a hashtable of names and values, PowerShell lets you pass the entire
        hashtable to a command. If you use the @ symbol to identify the hashtable variable name (rather
        than the $ symbol), PowerShell then treats each element of the hashtable as though it were a
        parameter to the command.

    4. .NET classes to create a ProxyCommand
        
        1. We expose the metadata.  You can do a New-Object on System.Management.Automation.CommandMetaData passing it cmdletInfo and get it's metadata.
        Try this to create Metadate from the cmdlet "Get-Process":
        PS> New-Object System.Management.Automation.CommandMetaData (Get-Command Get-Process)

        2. We make the metadata programmable.  You can add/remove parameters, change the parameters, change the name, etc.
        
        3. We use metadata to emit a script Cmdlet.
        PS> $metaData = New-Object System.Management.Automation.CommandMetaData (Get-Command Get-Process)
        PS> [System.Management.Automation.ProxyCommand]::create($MetaData)

    5. A command can be invoked as moduleName\CommandName.
        If you have created a ProxyCommand to shadow a Cmdlet, the original Cmdlet can be called by use of the Cmdlet-Module path!
        If you have done a ProxyCommand to shadow the Cmdlet "Get-ChildItem", you can call the original Cmdlet like so:
        Microsoft.PowerShell.Management\Get-ChildItem
          
        
    See Link:  Extending and/or Modifing Commands with Proxies
        http://blogs.msdn.com/b/powershell/archive/2009/01/04/extending-and-or-modifing-commands-with-proxies.aspx

    See Link: Customizing PowerShell, Proxy functions and a better Select-String 
        http://jamesone111.wordpress.com/2012/02/04/customizing-powershell-proxy-functions-and-a-better-select-string/
         
        
.PARAMETER Name 
    Name of the Cmdlet to proxy.
    You can Proxy cmdlets or functions
    The name of the command can be an module path like: Microsoft.Powershell.Management\Get-ChildItem

.PARAMETER NewName
    Provide a new command name if you like to create a new function that is similar to an existing command.
    The command from the -Name parameter is taken as template for the command with this new name.
    This new name is used as function name and the old name from the -Name parameter is replaced by this new name in the sourcecode text.

.PARAMETER Path
    Specifies the path to output the resulting sourcecode as a textfile.
    Note: If this function runs inside the PowerShell ISE, the resulting sourcecode is inserted in a new Editor-Tab by default. 
      
.PARAMETER CommandType 
    Type of Command we are proxying.  In general you dont' need to specify this but
    it becomes necessary if there is both a cmdlet and a function with the same 
    name
    Valid arguments are 'Cmdlet' or 'function' the default is 'cmdlet' 

.PARAMETER AddParameter
    List of Parameters as type of 'System.Management.Automation.ParameterMetadata' you would like to add
    You can even simpy provide an list of Names as type of Strings 
    NOTE:
        you have to edit the resultant code to implement the semantics of these parameters.
        ALSO - you need to remove them from $PSBoundParameters on a call of the origin command!
    
    You can use the New-Parameter Function to create a new ParameterMetadata Object 
     
.PARAMETER RemoveParameter
    List of Parameters as type of 'System.String' you would like to remove from the origin command.

.PARAMETER ExcludeHelp
    Provide this Parameter if you do not want to add the helptext (comment based help) of the original command

.PARAMETER NoIseInsert
    Provide this Parameter if you do not want to insert the sourcecode produced by this function into the PowerShell ISE.
    If this function runs inside the PowerShell ISE, the resulting sourcecode is inserted in a new Editor-Tab by default.

.EXAMPLE
    New-ProxyCommand Get-Alias -AddParameter 'SortBy'
    
    Create an proxy function from the 'Get-Alias' cmdlet and add a new Parameter with Name 'SortBy' 

.EXAMPLE
    New-ProxyCommand -Name Get-Alias -AddParameter 'SortBy' -Path E:\temp\test\Get-MyAliasISE.ps1

    Create an proxy function from the 'Get-Alias' cmdlet, add a new Parameter with Name 'SortBy' and
    save the resulting sourcecode into the file 'E:\temp\test\Get-MyAliasISE.ps1' 

.EXAMPLE
    New-ProxyCommand -Name Get-Alias -AddParameter 'SortBy' -Path E:\temp\test\Get-MyAlias.ps1 -NoIseInsert

    Create an proxy function from the 'Get-Alias' cmdlet, add a new Parameter with Name 'SortBy', 
    save the resulting sourcecode into the file 'E:\temp\test\Get-MyAliasISE.ps1', and prevent outpot to the PowerShell ISE
    
.OUTPUTS
    System.String
    The sourcecode of the command to proxy as System.String

.NOTES

 #Requires PowerShell -Version 2.0
 
 NAME:      New-ProxyCommand
 AUTHOR:    NTDEV\jsnover
 ToDo:      Need to modify script to emit template help for the proxy command.
            Probably should add a -AsFunction switch
 LASTEDIT:  1/4/2009 8:53:35 AM
 See Link:  Extending and/or Modifing Commands with Proxies
            http://blogs.msdn.com/b/powershell/archive/2009/01/04/extending-and-or-modifing-commands-with-proxies.aspx
            
 Edited by: Peter Kriegel
 Initial release: 18.June.2014
 Version:   2.0.0
 LASTEDIT:  22.June.2014

         History:
         Switcht from use of here Strings to Stringbuilder
         removed inner function
         added parameter -Newname and functionality to use a new command name
         added ability to extract the help from origin command
         added parameter ExcludeHelp and functionality
 
#>
    [CmdletBinding(
        SupportsShouldProcess=$False,
        SupportsTransactions=$False, 
        ConfirmImpact="None",
        DefaultParameterSetName="")]
    param(
        [Parameter(Position=0, Mandatory=$True)]
        [String]$Name,

        [String]$NewName,

        [String]$Path,

        [Alias("Type")]
        [ValidateSet('Cmdlet','Function')]
        [System.Management.Automation.CommandTypes]$CommandType='Cmdlet',

        [System.Management.Automation.ParameterMetadata[]]$AddParameter,

        [String[]]$RemoveParameter,

        [Switch]$ExcludeHelp,

        [Switch]$NoIseInsert
    )


    # create a StringBuilder to glue the sourcecode
    # with StringBuilder we have better control over newline
    $stringBuilder = New-Object System.Text.StringBuilder

    # The name of the command can be an module path like: Microsoft.Powershell.Management\Get-ChildItem
    # so we split out only the leaf namen
    $OriginCommandName = Split-Path $Name -Leaf

    # If the original command is modified, or the original hcommant help is included,
    # we remove all links to the original command
    # create a flag for this
    $NoForwardHelp = $False
    If((-not [String]::IsNullOrEmpty($NewName)) -or
        (-not [String]::IsNullOrEmpty($RemoveParameter)) -or
        ($AddParameter.count -gt 0) -or
        (-Not $ExcludeHelp.IsPresent)
        )
        {
        $NoForwardHelp = $True
    }

            
    # try to get the metadata from the command
    Try {
        $Cmd = Get-Command -Name $Name -CommandType $CommandType -ErrorAction stop
    } catch {
        Throw $_
        # exit function
        Return
    }

    # if the command exist more then once throw an Error and exit function
    if (@($cmd).Count -ne 1) {
        Throw "Command exist more then once!`nAmbiguous reference [$Name : $CommandType]`n$($Cmd | Out-String)"
        # exit function
        Return
    }

    ## If a function already exists with this name (perhaps it's already been
    ## wrapped,) output a warning message
    if(Test-Path function:\$OriginCommandName) {
        Write-Warning "A Function with the Name: '$OriginCommandName'  already exist!"
    }

    # get metadata from the command
    $MetaData = New-Object System.Management.Automation.CommandMetaData $cmd
            
            
    if ($RemoveParameter)
    {
        foreach ($ParameterName in @($RemoveParameter))
        {
            # Remove Parameters by Name from the command metadata
            [Void]$MetaData.Parameters.Remove($ParameterName)   
        }
    }


    # Add comment to the Output Text
    If([String]::IsNullOrEmpty($NewName)) {
        [void]$stringBuilder.AppendLine("# Begin of ProxyCommand for command: $OriginCommandName")
    }

    # Add the head of the function
    If([String]::IsNullOrEmpty($NewName)) {
        [void]$stringBuilder.AppendLine("Function $OriginCommandName {")
    } else {
        [void]$stringBuilder.AppendLine("Function $NewName {")
    }
    # Add Comment based help
    If(-Not $ExcludeHelp.IsPresent) {
        # create comment based helptext and reformat it line by line
        $IsCommendHelpKeyword = $False
        ("<#$([System.Management.Automation.ProxyCommand]::GetHelpComments((Get-Help $Name)))#>") -split "`n" | ForEach-Object {
                
                $Line = ([String]$_).Trim()
                If(-not [String]::IsNullOrEmpty($NewName)) {
                    $Line = $Line -replace 'Get-ChildItem','Get-Popel'
                }

                If($Line -eq '') {
                  $EmptyLineCounter++  
                } Else {
                    $EmptyLineCounter = 0
                }
                                
                If($Line -like '.*' -or ($Line -eq '<#') -or ($Line -eq '#>')){                                     
                    # return line without a tab in front
                    # if it is a comment based help keyword or a comment indicator
                    $IsCommendHelpKeyword = $True
                    [void]$stringBuilder.AppendLine($Line)
                }Else{
                    # return line with a tab in front
                    
                    # do not return the empty line if they folow directly after a comment based help keyword    
                    If(-not ($IsCommendHelpKeyword -and ($Line -eq ''))) {
                        # return line with a tab in front
                        # if it is not a comment based help keyword
                        If($EmptyLineCounter -lt 2) { # supress more than 1 empty lines 
                            [void]$stringBuilder.AppendLine("`t$Line")
                        }
                    }
                    $IsCommendHelpKeyword = $False
                }
            }
        # append comment based help text
        [void]$stringBuilder.AppendLine($CommentHelpText)
    }

    If ($AddParameter) {
        [void]$stringBuilder.AppendLine('<#')
        [void]$stringBuilder.AppendLine('You are responsible for implementing the logic for added parameters.  These ')
        [void]$stringBuilder.AppendLine('parameters are bound to $PSBoundParameters so if you pass them on the the ')
        [void]$stringBuilder.AppendLine('command you are proxying, it will almost certainly cause an error.  This logic')
        [void]$stringBuilder.AppendLine('should be added to your BEGIN statement to remove any specified parameters ')
        [void]$stringBuilder.AppendLine('from $PSBoundParameters.')
        [void]$stringBuilder.AppendLine('')
        [void]$stringBuilder.AppendLine('In general, the way you are going to implement additional parameters is by')
        [void]$stringBuilder.AppendLine('modifying the way you generate the $scriptCmd variable.  Here is an example')
        [void]$stringBuilder.AppendLine('of how you would add a -SORTBY parameter to a cmdlet:')
        [void]$stringBuilder.AppendLine('')
        [void]$stringBuilder.AppendLine('        if ($SortBy)')
        [void]$stringBuilder.AppendLine('        {')
        [void]$stringBuilder.AppendLine('            [Void]$PSBoundParameters.Remove("SortBy")')
        [void]$stringBuilder.AppendLine('            $scriptCmd = {& $wrappedCmd @PSBoundParameters |Sort-Object -Property $SortBy}')
        [void]$stringBuilder.AppendLine('        }else')
        [void]$stringBuilder.AppendLine('        {')
        [void]$stringBuilder.AppendLine('            $scriptCmd = {& $wrappedCmd @PSBoundParameters }')
        [void]$stringBuilder.AppendLine('        }')
        [void]$stringBuilder.AppendLine('')
        [void]$stringBuilder.AppendLine('################################################################################        ')
        [void]$stringBuilder.AppendLine('New ATTRIBUTES:')

        foreach ($ParameterMetadata in @($AddParameter))
        {        
            [Void]$MetaData.Parameters.Add($ParameterMetadata.Name, $ParameterMetadata) 

            [void]$stringBuilder.AppendLine("        if (`$$($ParameterMetadata.Name))")
            [void]$stringBuilder.AppendLine("        {")
            [void]$stringBuilder.AppendLine("            [Void]`$PSBoundParameters.Remove($($ParameterMetadata.Name))")
            [void]$stringBuilder.AppendLine("        }")
            
        }

        [void]$stringBuilder.AppendLine('################################################################################')
        [void]$stringBuilder.AppendLine('#>')

    } # end If($AddParameter)
             
    [void]$stringBuilder.AppendLine()    

    # create the command sourcecode from metadata
    $CommandText = [System.Management.Automation.ProxyCommand]::create($MetaData)

    If($NoForwardHelp) {
        # Regex to remove the help forwarding to the origin command
        $regex = New-Object Text.RegularExpressions.Regex "\<\#.*\.ForwardHelpTargetName.*\.ForwardHelpCategory.*\#\>", ('singleline','multiline','IgnoreCase')
        $CommandText = $regex.Replace($CommandText,'')
        # Regex to replace the HelpUri
        $CommandText = $CommandText -Replace ", HelpUri='http://.*?'", ''
    }
    # Add a Tab in front of each Line
    $CommandText = $CommandText -split "`n" | ForEach-Object { "`t$_`n" }
    [void]$stringBuilder.AppendLine($CommandText)
    #[void]$stringBuilder.AppendLine(([System.Management.Automation.ProxyCommand]::create($MetaData)))
    If([String]::IsNullOrEmpty($NewName)) {
        [void]$stringBuilder.AppendLine("} # End ProxyFunction for command: $OriginCommandName")
    }Else{
        [void]$stringBuilder.AppendLine("} # End of function: $NewName")
    }
 
    $OutputText =  $stringBuilder.ToString()
   
    # if we are in the PowerShell ISE we create a new File-Tab and
    # insert the sourcecode of the ProxyCommand in the Editor of the new created File-Tab
    If($psise -and (-not $NoIseInsert.IsPresent)) {

            
        # Create File to open in ISE if Filepath was given
        If(-not [String]::IsNullOrEmpty($Path)) {
            '' | Out-File -FilePath $Path
            # create a new File Tab in the ISE
            $File = $psise.PowerShellTabs.SelectedPowerShellTab.Files.Add($Path)
        } Else {
            # No filepath was given, open File without filepath
            # create a new File Tab in the ISE
                $File = $psise.PowerShellTabs.SelectedPowerShellTab.Files.Add()
        }
                             
        # call Internal Function to set the Text of the ISE Editor Text in new File Tab
        $File.Editor.Text = $OutputText
        # scroll to first char
        $File.Editor.Select(1,1,1,1)
    }

    If(-not [String]::IsNullOrEmpty($Path)) {
        If($psise -and (-not $NoIseInsert.IsPresent)) {
        $File.SaveAs($Path)
        } Else {
        $OutputText | Out-File -FilePath $Path
        }  
    }

    # allways return the Text of the ProxyCommand
    $OutputText

         
}# end function internal

New-ProxyCommand -Name 'Get-ChildItem' -CommandType Cmdlet -NewName Get-Popel