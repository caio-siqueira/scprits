######################################################################################################
# Script para exportar em CSV informaçoes dos Resultados das Actions Bigfix que contenham Nomes xxx  #
# Criado por Caio Siqueira                                                                           #
# Versão 1.0                                                                                         #
######################################################################################################

## Ignorar SSL Invoke-RestMethod
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12

## Usuario e senha com permissao no BIGFIX
$usuario = "xxxx"
$encrypted = "580f736e3deb899e714000000a81c6ca30afaed9ffbcd21561951a4615fc8b1f7"
$pass = ConvertTo-SecureString -string $encrypted
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $usuario, $pass

## Get na API do Bigfix para buscar os IDs das Actions com nomes que possuem Teste
$uri = "https://bigfix:52311"
$apiquery = "/api/query"
$queryactionids = "?relevance=(ids%20of%20it)%20of%20bes%20actions%20whose%20(name%20of%20it%20contains%20%22Teste%22)"
$besqueryids = $uri + $apiquery + $queryactionids
$xmlqueryids = Invoke-RestMethod -Method GET -Credential $cred -Uri $besqueryids
$actionids = $xmlqueryids.BESAPI.Query.Result.Answer."#text" | %{ $_.Split('.')[0]; }

## Get na API do Bigfix para buscar os resultados das Actions
$api = "/api/action/"
$actionstatus = "/status"

foreach ($actionid in $actionids)
{
    $querybesactions = $uri + $api + $actionid + $actionstatus
    $xmlaction = Invoke-RestMethod -Method GET -Credential $cred -Uri $querybesactions
    $actionidresult = $xmlaction.BESAPI.ActionResults.ActionID
    $actiondetails = $xmlaction.BESAPI.ActionResults.Computer 
    $actiondetails | select @{l="ActionID";e={$actionidresult}}, Name, Status, EndTime | Export-Csv -Path .\besactions.csv -NoTypeInformation -Append
}
