#----------------------------------------------------------------------------
#
# Copyright (c) 2019 polar
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
#----------------------------------------------------------------------------


param (
    [Parameter(Mandatory=$true)][string]$Domain_Controller,
    [Parameter()][string]$O
)

Import-Module ActiveDirectory


# Host Processing
#----------------------------------------------------------------------------

function Proc_OS($obj) {
    # Processes OS value for validation
    if ([string]$obj.operatingsystem -eq "") {
        $Properties.operatingsystem = "***UNKNOWN***"
    } 
}


# Host Enumeration
#----------------------------------------------------------------------------
function Sort_Hosts($Host_List) {
    # Sort host list
    [array]$Sorted_List = @()
    
    foreach ($pc in $Host_List) {  
        [object]$Properties = $pc | Select-Object `
            name, `
            dnshostname, `
            operatingsystem, `
            lastlogondate
        
        Proc_OS $pc
        
        $Sorted_List += $Properties
    }
    return $Sorted_List
}

function Get_Hosts() {
    return Get-ADComputer -properties * -filter {enabled -eq $true} -Server $Domain_Controller
}


# Output
#----------------------------------------------------------------------------

function Print_Host_List($Host_List) {
    # Print host list
    foreach ($A in $Host_List) {
        Write-Host $A
    }
}

function Mk_CSV($Host_List) {
    $Host_List | Export-Csv -Path $O -NoTypeInformation
}


# Main
#----------------------------------------------------------------------------
function main() {

    [array]$Network_List = Get_Hosts
    
    [array]$Sorted_List = Sort_Hosts $Network_List

    Print_Host_List $Sorted_List

    if($O) {
        Mk_CSV $Sorted_List
    }

}


main
