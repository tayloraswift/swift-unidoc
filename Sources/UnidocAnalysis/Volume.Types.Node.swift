import Unidoc
import UnidocRecords

extension Volume.Types
{
    struct Node
    {
        let shoot:Volume.Shoot
        let scope:Unidoc.Scalar?

        init(shoot:Volume.Shoot, scope:Unidoc.Scalar? = nil)
        {
            self.shoot = shoot
            self.scope = scope
        }
    }
}
