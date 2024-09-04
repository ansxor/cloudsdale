{
  pkgs,
  fetchFromGitHub,
  dotnetCorePackages,
  buildDotnetModule,
  sqlite,
}:

buildDotnetModule rec {
  pname = "contentapi";

  src = fetchFromGitHub {
    owner = "randomouscrap98";
    repo = "contentapi";
    sha256 = "7d5dbce89face1addea4da75cf7457c53b6a47f9";
  };

  propagatedBuildInputs = [ sqlite ];

  projectFile = "contentapi/contentapi.csproj";

  outputBin = "publish";
  framework = "net6.0";

  meta = with pkgs.lib; {
    description = "ContentAPI";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
