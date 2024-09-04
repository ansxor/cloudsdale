{
  fetchFromGitHub,
  dotnetCorePackages,
  buildDotnetModule,
  sqlite,
  lib
}:

buildDotnetModule rec {
  name = "contentapi";

  src = fetchFromGitHub {
    owner = "randomouscrap98";
    repo = "contentapi";
    rev = "7d5dbce89face1addea4da75cf7457c53b6a47f9";
    hash = "sha256-oQ2xQL8UlrOvEJwXOBtAKuZyUtuFjk7D2G0npT+t2WQ=";
  };

  runtimeDeps = [ sqlite ];

  projectFile = "contentapi/contentapi.csproj";

  nugetDeps = ./deps/contentapi.nix;

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_6_0;

  meta = with lib; {
    description = "ContentAPI";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
