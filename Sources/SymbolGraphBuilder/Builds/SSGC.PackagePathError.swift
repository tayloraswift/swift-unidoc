import SystemIO

extension SSGC
{
    struct PackagePathError:Error
    {
        let computed:FilePath.Directory
        let manifest:FilePath.Directory
    }
}
extension SSGC.PackagePathError:CustomStringConvertible
{
    var description:String
    {
        """
        Attempting to build a package at '\(computed)' \
        but the nearest manifest is located in '\(manifest)'
        """
    }
}
