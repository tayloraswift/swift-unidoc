import Unidoc
import UnidocLinker
import UnidocRecords

@available(*, deprecated, renamed: "UnidocDatabase.Uploaded")
public
typealias SnapshotReceipt = UnidocDatabase.Uploaded

extension UnidocDatabase
{
    @frozen public
    struct Uploaded:Equatable, Sendable
    {
        public
        let edition:Unidoc.Edition
        /// Indicates if the uploaded snapshot replaced an existing snapshot.
        public
        let updated:Bool

        @inlinable public
        init(edition:Unidoc.Edition, updated:Bool)
        {
            self.edition = edition
            self.updated = updated
        }
    }
}
extension UnidocDatabase.Uploaded
{
    @inlinable public
    var package:Unidoc.Package { self.edition.package }

    @inlinable public
    var version:Unidoc.Version { self.edition.version }
}
