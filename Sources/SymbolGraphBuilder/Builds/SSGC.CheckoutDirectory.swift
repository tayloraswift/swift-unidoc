import System

extension SSGC
{
    /// A checkout directory. It contains a single child directory, which is a git repository.
    struct CheckoutDirectory:SystemWorkspace
    {
        let path:FilePath
    }
}
