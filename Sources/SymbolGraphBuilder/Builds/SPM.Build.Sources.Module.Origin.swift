import System

extension SPM.Build.Sources.Module
{
    enum Origin
    {
        case sources(FilePath)
        case toolchain
    }
}
