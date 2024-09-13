import System

extension FilePath
{
    func absolute() -> Self
    {
        if  self.isAbsolute
        {
            return self
        }
        else if
            let current:FilePath.Directory = .current()
        {
            return current.path.appending(self.components).lexicallyNormalized()
        }
        else
        {
            fatalError("Couldn’t determine the current working directory!")
        }
    }
}
