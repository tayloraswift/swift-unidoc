import System

extension Server.Options
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
