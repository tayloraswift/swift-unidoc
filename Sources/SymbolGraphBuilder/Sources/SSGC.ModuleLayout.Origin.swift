import System

extension SSGC.ModuleLayout
{
    enum Origin
    {
        case sources(FilePath.Directory)
        case toolchain
    }
}
