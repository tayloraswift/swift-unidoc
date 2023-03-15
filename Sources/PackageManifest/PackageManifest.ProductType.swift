import JSONDecoding

extension PackageManifest
{
    @frozen public
    enum ProductType:Hashable, Equatable, Sendable
    {
        case executable
        case library(LibraryType)
        case macro
        case plugin
        case snippet
        case test
    }
}
extension PackageManifest.ProductType:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case executable
        case library
        case macro
        case plugin
        case snippet
        case test
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let json:JSON.ExplicitField<CodingKeys> = try json.single()
        switch json.key
        {
        case .library:      self = .library(try json.decode(as: JSON.Array.self)
            {
                try $0.shape.expect(count: 1)
                return try $0[0].decode()
            })
            return
        
        case .executable:   self = .executable
        case .macro:        self = .macro
        case .plugin:       self = .plugin
        case .snippet:      self = .snippet
        case .test:         self = .test
        }

        let _:Never? = try json.decode()
    }
}
