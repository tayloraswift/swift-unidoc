import System

extension Swiftinit.Options
{
    struct Secrets
    {
        let github:FilePath?

        init(github:FilePath?)
        {
            self.github = github
        }
    }
}
