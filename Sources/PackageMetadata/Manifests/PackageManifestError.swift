public
enum PackageManifestError:Error, Equatable, Sendable
{
    /// At least one dependency cycle exists among the targets listed in the
    /// relevant manifest.
    case dependencyCycle
}
