import BSON
import GitHubAPI
import HTML

extension Unidoc
{
    struct UserBanner
    {
        private
        let user:User?
        private
        let name:String
        private
        let packages:Int

        init(user:User?, name:String, packages:Int)
        {
            self.user = user
            self.name = name
            self.packages = packages
        }
    }
}
extension Unidoc.UserBanner:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        if  let user:Unidoc.User = self.user
        {
            section[.p] = user.bio
        }
        else
        {
            section[.p]
            {
                $0[.span]
                {
                    $0.class = "placeholder"
                } = "This user has not verified her GitHub account!"
            }
        }


        section[.p, { $0.class = "chyron" }]
        {
            if  let profile:GitHub.User.Profile = self.user?.github
            {
                $0 += Unidoc.SourceLink.init(
                    target: "https://github.com/\(profile.login)",
                    icon: .github,
                    file: profile.login[...])
            }
            else
            {
                $0[.span] { $0.class = "placeholder" } = "Unverified"
            }

            $0[.span]
            {
                switch self.packages
                {
                case 0:         $0[.span] = "no packages"
                case 1:         $0[.span] = "one package"
                case let count: $0[.span] = "\(count) packages"
                }
            }
        }
    }
}
