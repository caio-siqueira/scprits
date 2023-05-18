####################################################################################
# Script para corrigir Vulnerabilidade .NET Core SEoL                              #
# Criado por Caio Siqueira                                                         #
# Versão 1.0 - ASP.NETCore Runtime x64                                             #
####################################################################################

# Variáveis
$URL = "https://github.com/dotnet/cli-lab/releases/download/1.6.0/dotnet-core-uninstall-1.6.0.msi"
$Path= "C:\temp\dotnet-core-uninstall-1.6.0.msi"
$PathNet = "C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App"

# Download da ferramenta de remoção do .NETCore
Invoke-WebRequest -URI $URL -OutFile $Path

# Instalação da ferramenta de remoção do .NETCore
msiexec.exe /I $Path /quiet 
Start-Sleep -Seconds 30

# Captura as versões existentes na pasta e realiza a remoção via ferramenta
$versions = Get-Childitem -Path $PathNet | where-object {($_.Name -ilike "1.*" -or $_.Name -ilike "2.*" -or $_.Name -ilike "3.*" -or $_.Name -ilike "5.*")} | select -ExpandProperty Name

cd "C:\Program Files (x86)\dotnet-core-uninstall"

foreach ($version in $versions)
{
    .\dotnet-core-uninstall remove $version --x64 --aspnet-runtime --force --yes
	.\dotnet-core-uninstall remove $version --hosting-bundle --force --yes
}

# Captura as versões existentes na pasta e realiza a remoção das pastas no diretório
Get-Childitem -Path $PathNet | where-object {($_.Name -ilike "1.*" -or $_.Name -ilike "2.*" -or $_.Name -ilike "3.*" -or $_.Name -ilike "5.*")} | Remove-Item -Force -Recurse
