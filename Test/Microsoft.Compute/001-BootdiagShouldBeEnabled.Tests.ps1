Describe "Microsoft.Compute/virtualMachines" {

    $result = $global:result.Tests | Where-Object { $_.Block.Name -eq "Boot diag should be enabled" }
    $TestCases = New-Object System.Collections.ArrayList

    $result | ForEach-Object {
        $tmp = @{
            "Name" = $_.ExpandedName
            "Result" = $_.Result
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "Boot diag should be enabled" {

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "gamehosttest" }){
            Param($Name,$Result)
            $Result | Should -Be "Passed"
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "ml-wu2c09083361eabetest" }){
            Param($Name,$Result)
            $Result | Should -Be "Failed"
        }
    }
}