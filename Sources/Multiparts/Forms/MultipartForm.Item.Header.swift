import Media

extension MultipartForm.Item
{
    @frozen public
    struct Header
    {
        public
        let filename:String?
        public
        let name:String
        public
        let type:MediaType?

        @inlinable public
        init(filename:String?, name:String, type:MediaType?)
        {
            self.filename = filename
            self.name = name
            self.type = type
        }
    }
}
extension MultipartForm.Item.Header
{
    var disposition:ContentDisposition
    {
        .formData(filename: self.filename, name: self.name)
    }
}
extension MultipartForm.Item.Header:CustomStringConvertible
{
    public
    var description:String
    {
        let disposition:String = "Content-Disposition: \(self.disposition)\r\n"
        if  let content:MediaType = self.type
        {
            return disposition + "Content-Type: \(content)\r\n\r\n"
        }
        else
        {
            return disposition + "\r\n"
        }
    }
}
