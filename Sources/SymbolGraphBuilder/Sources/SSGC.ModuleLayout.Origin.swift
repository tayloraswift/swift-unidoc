import SystemIO

extension SSGC.ModuleLayout
{
    enum Origin
    {
        case sources(FilePath.Directory)
        case toolchain
    }
}
