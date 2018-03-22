function Get-ADObjectWellKnownRid {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=0,ParameterSetName="ParameterSet1")]
        [int]$Rid,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=1,ParameterSetName="ParameterSet2")]
        [string]$Name,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=2,ParameterSetName="ParameterSet3")]
        [switch]$All,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=3,ParameterSetName="ParameterSet4")]
        [switch]$Protected
    )

    begin { 
        $hash = @{  

        # https://msdn.microsoft.com/en-us/library/cc223144.aspx
            DOMAIN_USER_RID_ADMIN                  = 0x000001F4
            DOMAIN_USER_RID_GUEST                  = 0x000001F5
            DOMAIN_USER_RID_KRBTGT                 = 0x000001F6
            DOMAIN_GROUP_RID_ADMINS                = 0x00000200
            DOMAIN_GROUP_RID_USERS                 = 0x00000201
            DOMAIN_GROUP_RID_COMPUTERS             = 0x00000203
            DOMAIN_GROUP_RID_CONTROLLERS           = 0x00000204
            DOMAIN_GROUP_RID_CERT_PUBLISHERS       = 0x00000205
            DOMAIN_GROUP_RID_SCHEMA_ADMINS         = 0x00000206
            DOMAIN_GROUP_RID_ENTERPRISE_ADMINS     = 0x00000207
            DOMAIN_GROUP_RID_POLICY_CREATOR_OWNERS = 0x00000208
            DOMAIN_GROUP_RID_READONLY_CONTROLLERS  = 0x00000209

        # https://msdn.microsoft.com/en-us/library/windows/desktop/aa379649(v=vs.85).aspx
            DOMAIN_ALIAS_RID_ADMINS                         = 0x00000220 # A local group used for administration of the domain.    
            DOMAIN_ALIAS_RID_USERS                          = 0x00000221 # A local group that represents all users in the domain.
            DOMAIN_ALIAS_RID_GUESTS                         = 0x00000222 # A local group that represents guests of the domain.
            DOMAIN_ALIAS_RID_POWER_USERS                    = 0x00000223 # A local group used to represent a user or set of users who expect to treat a system as if it were their personal computer rather than as a workstation for multiple users.
            DOMAIN_ALIAS_RID_ACCOUNT_OPS                    = 0x00000224 # A local group that exists only on systems running server operating systems. This local group permits control over nonadministrator accounts.
            DOMAIN_ALIAS_RID_SYSTEM_OPS                     = 0x00000225 # A local group that exists only on systems running server operating systems. This local group performs system administrative functions, not including security functions. It establishes network shares, controls printers, unlocks workstations, and performs other operations.
            DOMAIN_ALIAS_RID_PRINT_OPS                      = 0x00000226 # A local group that exists only on systems running server operating systems. This local group controls printers and print queues.
            DOMAIN_ALIAS_RID_BACKUP_OPS                     = 0x00000227 # A local group used for controlling assignment of file backup-and-restore privileges.
            DOMAIN_ALIAS_RID_REPLICATOR                     = 0x00000228 # A local group responsible for copying security databases from the primary domain controller to the backup domain controllers. These accounts are used only by the system.
            DOMAIN_ALIAS_RID_RAS_SERVERS                    = 0x00000229 # A local group that represents RAS and IAS servers. This group permits access to various attributes of user objects.
            DOMAIN_ALIAS_RID_PREW2KCOMPACCESS               = 0x0000022A # A local group that exists only on systems running Windows 2000 Server. For more information, see Allowing Anonymous Access.
            DOMAIN_ALIAS_RID_REMOTE_DESKTOP_USERS           = 0x0000022B # A local group that represents all remote desktop users.
            DOMAIN_ALIAS_RID_NETWORK_CONFIGURATION_OPS      = 0x0000022C # A local group that represents the network configuration. 
            DOMAIN_ALIAS_RID_INCOMING_FOREST_TRUST_BUILDERS = 0x0000022D # A local group that represents any forest trust users.
            DOMAIN_ALIAS_RID_MONITORING_USERS               = 0x0000022E # A local group that represents all users being monitored.
            DOMAIN_ALIAS_RID_LOGGING_USERS                  = 0x0000022F # A local group responsible for logging users.
            DOMAIN_ALIAS_RID_AUTHORIZATIONACCESS            = 0x00000230 # A local group that represents all authorized access.
            DOMAIN_ALIAS_RID_TS_LICENSE_SERVERS             = 0x00000231 # A local group that exists only on systems running server operating systems that allow for terminal services and remote access.
            DOMAIN_ALIAS_RID_DCOM_USERS                     = 0x00000232 # A local group that represents users who can use Distributed Component Object Model (DCOM).
            DOMAIN_ALIAS_RID_IUSERS                         = 0X00000238 # A local group that represents Internet users.
            DOMAIN_ALIAS_RID_CRYPTO_OPERATORS               = 0x00000239 # A local group that represents access to cryptography operators.
            DOMAIN_ALIAS_RID_CACHEABLE_PRINCIPALS_GROUP     = 0x0000023B # A local group that represents principals that can be cached.
            DOMAIN_ALIAS_RID_NON_CACHEABLE_PRINCIPALS_GROUP = 0x0000023C # A local group that represents principals that cannot be cached.
            DOMAIN_ALIAS_RID_EVENT_LOG_READERS_GROUP        = 0x0000023D # A local group that represents event log readers.
            DOMAIN_ALIAS_RID_CERTSVC_DCOM_ACCESS_GROUP      = 0x0000023E # The local group of users who can connect to certification authorities using Distributed Component Object Model (DCOM).
        }     
    }
    process {
        $hash.GetEnumerator() | 
            Where-Object {
                $_.Value -eq $Rid
            }

        $hash.GetEnumerator() | 
            Where-Object {
                $_.Name -eq $Name
            }

        if ($All) {
            $hash
        }

        if ($Protected) {
            # https://technet.microsoft.com/en-us/library/2009.09.sdadminholder.aspx
            "DOMAIN_ALIAS_RID_ACCOUNT_OPS",
            "DOMAIN_USER_RID_ADMIN",
            "DOMAIN_ALIAS_RID_ADMINS",
            "DOMAIN_ALIAS_RID_BACKUP_OPS",
            "DOMAIN_GROUP_RID_ADMINS",
            "DOMAIN_GROUP_RID_CONTROLLERS",
            "DOMAIN_GROUP_RID_ENTERPRISE_ADMINS",
            "DOMAIN_USER_RID_KRBTGT",
            "DOMAIN_ALIAS_RID_PRINT_OPS",
            "DOMAIN_GROUP_RID_READONLY_CONTROLLERS",
            "DOMAIN_ALIAS_RID_REPLICATOR",
            "DOMAIN_GROUP_RID_SCHEMA_ADMINS",
            "DOMAIN_ALIAS_RID_SYSTEM_OPS" |
                Get-ADObjectWellKnownRid
        }
    }
    end {
    }
}