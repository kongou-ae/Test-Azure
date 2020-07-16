Describe "Microsoft.Compute" {

    $result = $global:result.Tests | Where-Object { $_.Block.Name -eq "OS Disk Should be managed disk" }
    $TestCases = New-Object System.Collections.ArrayList

    $result | ForEach-Object {
        $tmp = @{
            "Name" = $_.ExpandedName
            "Result" = $_.Result
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "OS Disk Should be managed disk" {

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "gamehosttest" }){
            Param($Name,$Result)
            $Result | Should -Be "Passed"
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "ml-wu2c09083361eabetest" }){
            Param($Name,$Result)
            $Result | Should -Be "Passed"
        }
    }
}