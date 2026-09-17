$ErrorActionPreference = 'Continue'
Get-ChildItem 'C:\Users\L E O N\student_preparation_app\assets\data\*questions*.json' | ForEach-Object {
    $data = Get-Content $_.FullName -Raw | ConvertFrom-Json
    $outOfRange = 0
    $missingKeys = 0
    $count = 0
    foreach ($q in $data) {
        $count++
        $opts = @($q.options)
        $cidx = [int]$q.correctAnswerIndex
        if ($cidx -lt 0 -or $cidx -ge $opts.Count) {
            $outOfRange++
            Write-Output ("  OUT-OF-RANGE  {0} Q'{1}' correctAnswerIndex={2} options={3}" -f $_.Name, $q.id, $q.correctAnswerIndex, $opts.Count)
        }
        if ($null -eq $q.id -or $null -eq $q.question -or $null -eq $q.options -or $null -eq $q.correctAnswerIndex) {
            $missingKeys++
            Write-Output ("  MISSING-KEY   {0} Q'{1}'" -f $_.Name, $q.id)
        }
    }
    Write-Output ("{0}: {1} questions, out-of-range answers: {2}" -f $_.Name, $count, $outOfRange)
}