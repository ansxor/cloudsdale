{
  fetchFromGitHub,
  dotnetCorePackages,
  buildDotnetModule,
  sqlite,
  lib,
  writeShellScript,
  bash,
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
  nativeBuildInputs = [ sqlite ];

  projectFile = "contentapi/contentapi.csproj";

  nugetDeps = ./deps/contentapi.nix;

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_6_0;

  meta = with lib; {
    description = "ContentAPI";
    license = licenses.mit;
    platforms = platforms.linux;
  };

  
  # Add the migration script
  migrationScript = writeShellScript "contentapi-migrate" ''
    set -e

    DB=''${1:-content.db}
    BACKUP=''${2:-content.db.bak}

    DB_DIR=$(dirname $DB)

    # Make a backup of the current db, if it exists
    if [ -e "$DB" ]
    then 
       rm -f "$BACKUP"
       echo "Backing up db to $BACKUP"
       sqlite3 "$DB" ".backup $BACKUP"
    fi

    for f in $DBMIGRATIONS/*.sql
    do
       df="''${DB_DIR}/$(basename "$f").done"
       if [ -r $df ]
       then
          continue
       fi
       echo "Processing $f..."
       cat $f | sqlite3 "$DB"
       touch $df
    done
  '';

  # Add a postInstall phase to run the migrations
  postInstall = ''
    # Put the migrations somewhere where we can use them
    mkdir -p $out/share/${name}
    cp -r $src/Deploy/dbmigrations $out/share/${name}

    # make a script to handle migrations
    mkdir -p $out/bin
    cp ${migrationScript} $out/bin/contentapi-migrate
    chmod +x $out/bin/contentapi-migrate
    wrapProgram $out/bin/contentapi-migrate --prefix PATH : ${sqlite}/bin --set DBMIGRATIONS $out/share/${name}/dbmigrations

    # Put the default appsettings.json somewhere where it is easy to find
    # the appsettings.json must be put into the working directory of the program
    mkdir -p $out/share/doc/${name}
    cp $src/contentapi/appsettings.json $out/share/doc/${name}
  '';
}
