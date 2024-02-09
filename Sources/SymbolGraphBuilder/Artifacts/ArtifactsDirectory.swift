import System

struct ArtifactsDirectory:SystemWorkspace
{
    let path:FilePath

    init(path:FilePath)
    {
        self.path = path
    }
}
