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
  migrationScript = writeShellScript "run-migrations.sh" ''
    set -e

    DB=''${1:-content.db}
    BACKUP=''${2:-content.db.bak}
    DBMIGRATIONS=''${3:-dbmigrations}

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
    mkdir -p $out/bin
    cp ${migrationScript} $out/bin/run-migrations.sh
    chmod +x $out/bin/run-migrations.sh

    # Run the migrations
    DB_LOCATION=$out/share/contentapi
    mkdir -p $DB_LOCATION
    ${bash}/bin/bash $out/bin/run-migrations.sh \
      $DB_LOCATION/content.db \
      $DB_LOCATION/content.db.bak \
      $src/Deploy/dbmigrations

    # Update the appsettings.json file with the new database location
    sed -i "s|\"Data Source=content.db\"|\"Data Source=$out/share/contentapi/content.db\"|" $out/lib/appsettings.json
    sed -i "s|\"Data Source=valuestore.db\"|\"Data Source=$out/share/contentapi/valuestore.db\"|" $out/lib/appsettings.json
  '';
}
