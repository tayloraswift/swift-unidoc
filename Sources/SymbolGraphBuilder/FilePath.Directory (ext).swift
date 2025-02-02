import SystemIO

extension FilePath.Directory
{
    func absolute() -> Self { .init(path: self.path.absolute()) }
}

