{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf getExe maintainers mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) str path bool int;
  cfg = config.services.contentapi;

  appsettingsJson = pkgs.writeText "appsettings.json" (builtins.toJSON {
	      Logging = {
	        LogLevel = {
	          Default = "Debug";
	          "Microsoft.AspNetCore" = "Warning";
	        };
	      };
	      AWS = {
	        Profile = "yourawsprofile(onlyifs3)";
	        Region = "your-s3-region";
	      };
	      RateLimitConfig = {
	        Rates = {
	          write = "5,5";
	          login = "3,10";
	          interact = "5,5";
	          file = "2,10";
	          module = "10,10";
	          uservariable = "30,10";
	        };
	      };
	      SecretKey = "PLEASEREPLACETHISWHENTESTINGORDEPLOYGIN!THISKEYISPUBLIC!";
	      StaticPath = "/api/run";
	      AllowedHosts = "*";
	      CacheCheckpointTrackerConfig = {
	        CacheIdIncrement = 10;
	      };
	      UserServiceConfig = {
	        UsernameRegex = "^[^\\s,|%*]+$";
	        MinUsernameLength = 2;
	        MaxUsernameLength = 20;
	        MinPasswordLength = 8;
	        MaxPasswordLength = 160;
	      };
	      QueryBuilderConfig = {
	        ExpensiveMax = 2;
	      };
	      ConnectionStrings = {
	        contentapi = "Data Source=content.db";
	        storage = "Data Source=valuestore.db";
	      };
	      GenericSearcherConfig = {
	        MaxIndividualResultSet = 1000;
	        LogSql = false;
	      };
	      EmailSender = "file";
              ImageManipulator = "direct";
	      FileServiceConfig = {
	        MainLocation = "uploads";
	        ThumbnailLocation = "thumbnails";
	        TempLocation = "tempfiles";
	        QuantizerProgram = null;
	        EnableUploads = true;
	        DefaultImageFallback = "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAIAAAACDbGyAAAAIklEQVQI12P8//8/AxJgYmBgYGRkRJBo8gzI/P///6PLAwAuoA79WVXllAAAAABJRU5ErkJggg==";
	      };
	      ImageManipulator_IMagickConfig = {
	        TempPath = "tempfiles";
	        IMagickPath = "/usr/bin/convert";
	      };
	      OcrCrawlConfig = {
	        Program = "none";
	        Interval = "00:01:00";
	        ProcessPerInterval = 10;
	        OcrValueKey = "ocr-crawl";
	        OcrFailKey = "ocr-fail";
	        PullOrder = "id_desc";
	        TempLocation = "tempfiles";
	      };
	      BlogGeneratorConfig = {
	        Interval = "00:00:00";
	        BlogsFolder = "blogs";
	        StaticFilesBase = "wwwroot";
	        ScriptIncludes = [
	          "markup/parse.js"
	          "markup/render.js"
	          "markup/langs.js"
	          "markup/legacy.js"
	          "markup/helpers.js"
	          "bloggen.js"
	        ];
	      };
	      UserControllerConfig = {
	        BackdoorRegistration = false;
	        BackdoorSuper = false;
	        AccountCreationEnabled = true;
	        ConfirmationType = "Instant";
	      };
	      LiveControllerConfig = {
	        AnonymousToken = "SOME_TOKEN_FOR_ANONYMOUS_WEBSOCKET_LISTEN";
	      };
	      EmailConfig = {
	        Host = "somewherelikegmail.smtp.etc";
	        Sender = "sender@email.com";
	        User = "youruseraccountname";
	        Password = "plaintextpasswordforemail";
	        Port = 1234;
	        SubjectFront = "Something to append to all subjects if desired";
	      };
	      FileEmailServiceConfig = {
	        Folder = "emails";
	      };
	      StatusControllerConfig = {
	        Repo = "https://github.com/randomouscrap98/contentapi";
	        BugReports = "https://github.com/randomouscrap98/contentapi/issues";
	        Contact = "smilebasicsource@gmail.com";
	      };
  });
  webrootSetupScript = pkgs.writeShellScript "contentapi-webrootsetup.sh" ''
    set -e

    if [ ! -d "$1/wwwroot" ]; then
      mkdir -p "$1/wwwroot"
      cp -r "$2/lib/wwwroot/"* "$1/wwwroot/"
      chown -R "$3:$3" "$1/wwwroot"
      chmod -R 0750 "$1/wwwroot"
    fi
  '';
in
{
  options = {
    services.contentapi = {
      enable = mkEnableOption "ContentAPI";

      package = mkPackageOption pkgs "contentapi" { };

      user = mkOption {
        type = str;
	default = "contentapi";
	description = "User account under which ContentAPI runs.";
      };

      group = mkOption {
        type = str;
	default = "contentapi";
	description = "Group under which ContentAPI runs.";
      };

      workingDir = mkOption {
        type = path;
	default = "/var/lib/contentapi";
	description = "Working directory for ContentAPI database and appsettings.json.";
      };

      port = mkOption {
        type = int;
	default = 5000;
	description = "Exposed port for ContentAPI.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.settings.contentapiDirs = {
        "${cfg.workingDir}"."d" = {
	  mode = "700";
	  inherit (cfg) user group;
	};
      };
      services.contentapi = {
        enable = true;
        description = "ContentAPI";

	after = [ "network-online.target" ];
	wants = [ "network-online.target" ];
	wantedBy = [ "multi-user.target" ];

	serviceConfig = {
	  AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          User = cfg.user;
	  Group = cfg.group;
	  WorkingDirectory = cfg.workingDir;
	  ExecStart = "${getExe cfg.package} --urls 'http://*:${toString cfg.port}'";
	  ExecStartPre = [
	    "${cfg.package}/bin/contentapi-migrate ${cfg.workingDir}/content.db ${cfg.workingDir}/content.db.bak"
	    "${pkgs.coreutils}/bin/rm ${cfg.workingDir}/appsettings.json"
	    "${pkgs.coreutils}/bin/cp ${appsettingsJson} ${cfg.workingDir}/appsettings.json"
	    "${webrootSetupScript} ${cfg.workingDir} ${cfg.package} ${cfg.user} ${cfg.group}"
	  ];
	};

	environment = {
	  WEBROOT = "${cfg.package}/lib/wwwroot";
	};
      };
    };

    users.users = mkIf (cfg.user == "contentapi") {
      contentapi = {
        inherit (cfg) group;
	isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "contentapi") {
      contentapi = {};
    };
  };
}
