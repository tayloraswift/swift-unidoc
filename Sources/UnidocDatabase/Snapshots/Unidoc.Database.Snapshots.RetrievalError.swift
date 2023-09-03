import Unidoc

extension Unidoc.Database.Snapshots
{
    public
    struct RetrievalError:Error, Equatable, Sendable
    {
        public
        let zone:Unidoc.Zone

        public
        init(zone:Unidoc.Zone)
        {
            self.zone = zone
        }
    }
}
