import SourceDiagnostics

extension SSGC
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
extension SSGC.RouteCollision:DiagnosticNote
{
    typealias Symbolicator = SSGC.Symbolicator

    static func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        output[.note] = """
        symbol (\(output.symbolicator[self.colliding])) \
        does not have a unique URL
        """
    }
}
