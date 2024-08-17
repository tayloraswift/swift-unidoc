import System

extension SSGC
{
    /// An SPM build directory. It is usually, but not always, named `.build`.
    struct PackageBuildDirectory
    {
        let configuration:PackageBuildConfiguration
        let location:FilePath.Directory

        init(configuration:PackageBuildConfiguration, location:FilePath.Directory)
        {
            guard location.path.isAbsolute
            else
            {
                fatalError("""
                    Package build directory must be an absolute path,
                    for IndexStoreDB compatibility!
                    """)
            }

            self.configuration = configuration
            self.location = location
        }
    }
}
extension SSGC.PackageBuildDirectory
{
    var include:FilePath.Directory { self.location / "\(self.configuration)" }
}
