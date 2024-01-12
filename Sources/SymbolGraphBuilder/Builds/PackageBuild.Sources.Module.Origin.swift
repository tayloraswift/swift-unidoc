import System

extension PackageBuild.Sources.Module
{
    enum Origin
    {
        case sources(FilePath)
        case toolchain
    }
}
