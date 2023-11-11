import UnidocDiagnostics

extension StaticLinker
{
    struct RouteCollision:Equatable
    {
        let colliding:Int32

        init(colliding:Int32)
        {
            self.colliding = colliding
        }
    }
}
extension StaticLinker.RouteCollision:DiagnosticNote
{
    typealias Symbolicator = StaticSymbolicator

    static func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        output[.note] = """
        symbol (\(output.symbolicator[self.colliding])) \
        does not have a unique URL
        """
    }
}
