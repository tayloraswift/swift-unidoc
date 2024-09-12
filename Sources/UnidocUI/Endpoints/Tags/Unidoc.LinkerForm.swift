import URI

extension Unidoc
{
    @frozen public
    struct LinkerForm
    {
        public
        let edition:Edition
        public
        let back:String
        public
        let next:URI.Path?

        @inlinable public
        init(edition:Edition, back:String, next:URI.Path? = nil)
        {
            self.edition = edition
            self.back = back
            self.next = next
        }
    }
}
extension Unidoc.LinkerForm
{
    static var package:String { "package" }
    static var version:String { "version" }
    static var back:String { "back" }
    static var next:String { "next" }

    public
    init?(parameters:borrowing [String: String])
    {
        guard
        let package:String = parameters[Self.package],
        let version:String = parameters[Self.version],
        let back:String = parameters[Self.back],
        let package:Unidoc.Package = .init(package),
        let version:Unidoc.Version = .init(version)
        else
        {
            return nil
        }

        self.init(edition: .init(package: package, version: version),
            back: back,
            next: parameters[Self.next].map(URI.Path.init(_:)) ?? nil)
    }
}
