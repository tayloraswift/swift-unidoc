import Symbols

extension Unidoc.PackageMedia
{
    func link(media file:Symbol.File) -> String?
    {
        //  Files that lack a valid extension will not carry the correct `Content-Type`
        //  header, and won’t display correctly in the browser. There is no simple way to
        //  override this behavior, so files will just need to have the correct extension.
        guard
        let type:Substring = file.type
        else
        {
            return nil
        }

        let prefix:String?
        switch type
        {
        case "gif":     prefix = self.gif
        case "jpg":     prefix = self.jpg
        case "jpeg":    prefix = self.jpg
        case "png":     prefix = self.png
        case "svg":     prefix = self.svg
        case "webp":    prefix = self.webp
        default:        return nil
        }

        return "\(prefix ?? self.prefix)/\(file)"
    }
}
