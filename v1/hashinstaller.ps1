param ($zip, $psscript)
$md5 = CertUtil -hashfile $psscript MD5
$sha256 = CertUtil -hashfile $psscript SHA256
$sha512 = CertUtil -hashfile $psscript SHA512

$md5 = $md5.Replace("MD5 hash of ${$psscript}:", "")
$sha256 = $sha256.Replace("SHA256 hash of ${$psscript}:", "")
$sha512 = $sha512.Replace("SHA512 hash of ${$psscript}:", "")
$md5 = $md5.Replace("CertUtil: -hashfile command completed successfully.", "")
$sha256 = $sha256.Replace("CertUtil: -hashfile command completed successfully.", "")
$sha512 = $sha512.Replace("CertUtil: -hashfile command completed successfully.", "")

$zipmd5 = CertUtil -hashfile $zip MD5
$zipsha256 = CertUtil -hashfile $zip SHA256
$zipsha512 = CertUtil -hashfile $zip SHA512

$zipmd5 = $zipmd5.Replace("MD5 hash of ${$zip}:", "")
$zipsha256 = $zipsha256.Replace("SHA256 hash of ${$zip}:", "")
$zipsha512 = $zipsha512.Replace("SHA512 hash of ${$zip}:", "")
$zipmd5 = $zipmd5.Replace("CertUtil: -hashfile command completed successfully.", "")
$zipsha256 = $zipsha256.Replace("CertUtil: -hashfile command completed successfully.", "")
$zipsha512 = $zipsha512.Replace("CertUtil: -hashfile command completed successfully.", "")


Write-Host $md5
Write-Host $sha256
Write-Host $sha512
Write-Host ""
Write-Host ""
Write-Host $zipmd5
Write-Host $zipsha256
Write-Host $zipsha512
#New-Item -Path "${$PSScriptRoot}/output/file.hash" -ItemType File -Force
#Set-Content -Path  "${$PSScriptRoot}/output/file.hash" -Value $output -Force
