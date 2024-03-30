import System

extension SSGC.NominalSources
{
    enum Origin
    {
        case sources(FilePath)
        case toolchain
    }
}
