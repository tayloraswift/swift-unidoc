import Unidoc

extension UnidocDatabase.Graphs
{
    public
    struct RetrievalError:Error, Equatable, Sendable
    {
        public
        let zone:Unidoc.Edition

        public
        init(zone:Unidoc.Edition)
        {
            self.zone = zone
        }
    }
}
