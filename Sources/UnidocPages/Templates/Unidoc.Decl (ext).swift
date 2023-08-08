import Unidoc

extension Unidoc.Decl
{
    func superformHeading(_ customization:Unidoc.Decl.Customization) -> String
    {
        switch (self, customization)
        {
        case    (.protocol, _):             return "Supertypes"
        case    (.class,    _):             return "Superclasses"
        case    (_, .unavailable),
                (_, .available):            return "Customization Points"
        case    (_, .required),
                (_, .requiredOptionally):   return "Restated Requirements"
        }
    }
}
