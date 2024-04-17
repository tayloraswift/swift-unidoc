import HTML

extension Unidoc
{
    protocol CollectionEvent:HTML.OutputStreamable, Sendable
    {
        static
        func caught(_ error:any Error) -> Self
    }
}
