import BSON

extension Unidoc
{
    @frozen public
    enum BuildStage:Int32, BSONDecodable, BSONEncodable, Equatable, Sendable
    {
        /// The server is waiting for the builder to acknowledge the build request.
        case initializing = 0
        /// The server is cloning the package's git repository.
        case cloningRepository = 1
        /// The server is resolving package dependencies.
        case resolvingDependencies = 2
        /// The server is compiling the package's source code.
        case compilingCode = 3
    }
}
