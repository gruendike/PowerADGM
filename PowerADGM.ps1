$domains = ("domain1.com","domain2.com","...")
$groups = ("group1","group2","...")
$nested_symbol = "∟"

function Get-GroupMembers {
	Param ([hashtable]$h)
	foreach ($group in $h.'groups'){
		foreach ($domain in $h.'domains'){
			Get-QADGroupMember -Identity "$group" -Service "$domain" -OutVariable users | Out-Null
			foreach ($user in $users){
				if($user.Type -ne "foreignSecurityPrincipal"){
					if($user.Type -eq "Group"){
						$domain + "`t" + $h.level + $group + "`t" + $user.NTAccountName + "`t" + $user.displayname + "`t" + $user.Type + "`t" + $true
						$pc = [regex]::Replace($user.ParentContainer, "^([^/]+).*",'$1')
						Get-GroupMembers(@{"domains" = $pc; "groups" = $user.samaccountname; "nested" = $true; "level" = $h.level + $nested_symbol + " "})
					} else {
						$domain + "`t" + $h.level + $group + "`t" + $user.NTAccountName + "`t" + $user.displayname + "`t" + $user.Type + "`t" + $h.'nested'
			}}}
	}}
	Remove-Variable * -ErrorAction SilentlyContinue
}
Get-GroupMembers(@{"domains" = $domains; "groups" = $groups; "nested" = $false; "level" = ""})
