import BSON
import MongoDB
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc.DB
{
    @frozen public
    struct CompleteBuilds
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.CompleteBuilds
{
    /// It’s really unlikely that we’ll have duplicate timestamps, especially for the same
    /// package, but it’s not impossible.
    public static
    let indexFinished:Mongo.CollectionIndex = .init("Finished")
    {
        $0[Unidoc.CompleteBuild[.finished]] = (-)
    }

    public static
    let indexFinishedByPackage:Mongo.CollectionIndex = .init("FinishedByPackage")
    {
        $0[Unidoc.CompleteBuild[.package]] = (+)
        $0[Unidoc.CompleteBuild[.finished]] = (-)
    }
}
extension Unidoc.DB.CompleteBuilds:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.CompleteBuild

    @inlinable public static
    var name:Mongo.Collection { "CompleteBuilds" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexFinished,
            Self.indexFinishedByPackage
        ]
    }
}
