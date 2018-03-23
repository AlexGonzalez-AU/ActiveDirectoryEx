Add-Type -TypeDefinition @"
public struct ActiveDirectoryAccessRuleEx
{
    public System.Boolean                                              __MarkForDeletion;
    public System.String                                               Parent_canonicalName;
    public System.String                                               Parent_distinguishedName;
    public System.String                                               Parent_objectClass;
    public System.Security.Principal.NTAccount                         IdentityReference;
    public System.DirectoryServices.ActiveDirectoryRights              ActiveDirectoryRights;
    public System.Security.AccessControl.AccessControlType             AccessControlType;
    public System.Guid                                                 ObjectType;
    public System.String                                               ObjectTypeName;
    public System.DirectoryServices.ActiveDirectorySecurityInheritance InheritanceType;
    public System.String                                               InheritedObjectTypeName;
    public System.Guid                                                 InheritedObjectType;
    public System.Boolean                                              IsInherited;
    public System.Security.AccessControl.ObjectAceFlags                ObjectFlags;
    public System.Security.AccessControl.InheritanceFlags              InheritanceFlags;
    public System.Security.AccessControl.PropagationFlags              PropagationFlags;
}
"@