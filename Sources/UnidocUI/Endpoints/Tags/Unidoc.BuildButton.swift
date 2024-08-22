import HTML
import Symbols
import UnidocRecords

extension Unidoc
{
    struct BuildButton
    {
        let symbols:Symbol.PackageAtRef
        let package:Package
        let version:Version?
        let cancel:Bool
        let area:Bool

        private
        init(symbols:Symbol.PackageAtRef,
            package:Package,
            version:Version?,
            cancel:Bool,
            area:Bool)
        {
            self.symbols = symbols
            self.package = package
            self.version = version
            self.cancel = cancel
            self.area = area
        }
    }
}
extension Unidoc.BuildButton
{
    static
    func edition(id:Unidoc.Edition, package:Symbol.Package, ref:String) -> Self
    {
        .init(symbols: .init(package: package, ref: ref[...]),
            package: id.package,
            version: id.version,
            cancel: false,
            area: false)
    }

    static
    func latest(of package:Unidoc.PackageMetadata, cancel:Bool = false) -> Self
    {
        .init(symbols: .init(package: package.symbol, ref: nil),
            package: package.id,
            version: nil,
            cancel: cancel,
            area: true)
    }
}
extension Unidoc.BuildButton:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.input]
        {
            $0.type = "hidden"
            $0.name = "selector"
            $0.value = "\(self.symbols)"
        }

        form[.input]
        {
            $0.type = "hidden"
            $0.name = "build"
            $0.value = self.cancel ? "cancel" : "request"
        }

        form[.input]
        {
            $0.type = "hidden"
            $0.name = "package"
            $0.value = "\(self.package)"
        }

        if  let version:Unidoc.Version = self.version
        {
            form[.input]
            {
                $0.type = "hidden"
                $0.name = "version"
                $0.value = "\(version)"
            }
        }

        form[.button]
        {
            $0.class = self.area ? "area" : "text"
            $0.type = "submit"
        } = self.cancel ? "Cancel build" : "Request build"
    }
}
