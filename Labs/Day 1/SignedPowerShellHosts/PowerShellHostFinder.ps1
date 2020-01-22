# There's more than one way to do this. This was my (Matt G.) naive approach to the problem.
ls C:\* -Recurse -Include '*.exe', '*.dll' -ErrorAction SilentlyContinue | % {
    try {
        $Assembly = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom($_.FullName)

        if ($Assembly.GetReferencedAssemblies().Name -contains 'System.Management.Automation') {
            $_.FullName
        }
    } catch {}
}