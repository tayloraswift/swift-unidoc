import System

extension SPM.NominalSources
{
    enum Origin
    {
        case sources(FilePath)
        case toolchain
    }
}
