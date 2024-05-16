import System

extension SSGC
{
    /// An SPM build directory. It is usually, but not always, named `.build`.
    struct PackageBuildDirectory
    {
        let configuration:PackageBuildConfiguration
        let path:FilePath

        init(configuration:PackageBuildConfiguration, path:FilePath)
        {
            self.configuration = configuration
            self.path = path
        }
    }
}
extension SSGC.PackageBuildDirectory
{
    var include:FilePath { self.path / "\(self.configuration)" }
}
