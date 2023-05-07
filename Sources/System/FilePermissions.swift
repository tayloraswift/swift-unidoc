@_exported import struct SystemPackage.FilePermissions

extension FilePermissions
{
    @inlinable internal
    init(_ permissions:
        (
            owner:FilePermissions.Component?,
            group:FilePermissions.Component?,
            other:FilePermissions.Component?
        ))
    {
        self.init(rawValue:
            (permissions.owner?.rawValue ?? 0) << 6 |
            (permissions.group?.rawValue ?? 0) << 3 |
            (permissions.other?.rawValue ?? 0))
    }
}
