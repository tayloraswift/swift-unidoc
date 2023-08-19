import Unidoc
import UnidocRecords

extension Records.Types
{
    struct Node
    {
        let shoot:Record.Shoot
        let scope:Unidoc.Scalar?

        init(shoot:Record.Shoot, scope:Unidoc.Scalar? = nil)
        {
            self.shoot = shoot
            self.scope = scope
        }
    }
}
