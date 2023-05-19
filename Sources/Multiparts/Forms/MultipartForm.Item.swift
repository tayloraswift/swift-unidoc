import Grammar
import Media

extension MultipartForm
{
    @frozen public
    struct Item
    {
        public
        let header:Header
        public
        let value:ArraySlice<UInt8>

        init(header:Header, value:ArraySlice<UInt8>)
        {
            self.header = header
            self.value = value
        }
    }
}
extension MultipartForm.Item
{
    @inlinable public
    var filename:String?
    {
        self.header.filename
    }
    @inlinable public
    var name:String?
    {
        self.header.name
    }
    @inlinable public
    var type:MediaType?
    {
        self.header.type
    }
}
extension MultipartForm.Item
{
    init?(parsing component:ArraySlice<UInt8>)
    {
        var input:ParsingInput<NoDiagnostics<ArraySlice<UInt8>>> = .init(component)

        switch input.parse(as: MultipartHeaderRule?.self)
        {
        case (.formData(filename: let filename, name: let name)?, let type)?:
            self.init(header: .init(filename: filename, name: name, type: type?.media),
                value: component.suffix(from: input.index))

        case _:
            return nil
        }
    }
}
extension MultipartForm.Item:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.header)\(String.init(decoding: self.value, as: Unicode.UTF8.self))"
    }
}
