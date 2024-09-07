import UnidocRecords
import UnixCalendar
import UnixTime

extension Unidoc
{
    @frozen public
    struct BuildLogPath
    {
        public
        let id:BuildIdentifier
        public
        let type:BuildLogType

        @inlinable public
        init(id:BuildIdentifier, type:BuildLogType)
        {
            self.id = id
            self.type = type
        }
    }
}
extension Unidoc.BuildLogPath
{
    /// Same as ``description``, but with no leading slash.
    @inlinable public
    var prefix:String
    {
        //  As this is public-facing, we want it to be at least somewhat human-readable.
        """
        logs/\
        \(self.id.run.timestamp?.date.description ?? "0000-00-00")/\
        \(self.id.edition.package)/\
        \(self.id.edition.version).\(self.type.name).log
        """
    }
}
extension Unidoc.BuildLogPath:CustomStringConvertible
{
    @inlinable public
    var description:String { "/\(self.prefix)" }
}
