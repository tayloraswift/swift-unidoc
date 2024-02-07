import System

struct ArtifactDirectory:SystemWorkspace
{
    let path:FilePath

    init(path:FilePath)
    {
        self.path = path
    }
}
