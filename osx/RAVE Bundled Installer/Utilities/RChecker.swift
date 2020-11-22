//
//  Playground.swift
//  RAVE OSX Utilities
//
//  Created by beauchamplab on 11/21/20.
//

import Foundation


enum OptionType: String {
    case passcode = "p"
    case skipXcode = "sx"
    case skipR = "sr"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "p": self = .passcode
        case "sx": self = .skipXcode
        case "sr": self = .skipR
        case "h": self = .help
        default: self = .unknown
        }
    }
}

class RChecker {

    let consoleIO = ConsoleIO()
    let shell = Shell("let me guess your password")
    let downloader : Downloader
    
    init() throws {
        downloader = try Downloader("rave-installer")
    }
    
    func getOption(_ option: String) -> (option:OptionType, value: String) {
        return (OptionType(value: option), option)
    }
    

    func staticMode() {
        _ = shell.validate_sudo()
        // install_xcode()
        /*do {
            try install_r()
        } catch {
            print("Error: \(error)")
        }
        
        do {
            try install_rave()
        } catch {
            print("Error: \(error)")
            exit(3)
        }*/
        
        install_rstudio()
        
    }
    
    
    func interactiveMode() {
        // Hello message
        consoleIO.writeMessage("This program installs RAVE. To start, please enter administrator password: ")
        
        do {
            try _ = consoleIO.getPassword("To start, please enter administrator password:", shell)
        } catch {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
        install_rstudio()
        
        install_xcode()
        do {
            try install_r()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        do {
            try install_rave()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    func raise(exception : String) throws {
        // check what if under non-interactive mode
        throw ConsoleError.runtimeError(exception)
    }

    //  Install xcode command-line
    func install_xcode() {
        print("=======================================================")
        print("[RAVE]: Checking xcode command-line tools")
        _  = shell.exec_sudo("xcode-select", ["--install"])
        
        // handle messages
    }
    
    // Install R
    func install_r() throws {
        print("=======================================================")
        print("[RAVE]: Download and update to the latest R")
        let r_url = URL(string: "https://cran.r-project.org/bin/macosx/base/R-release.pkg")!
        let (target, suc) = downloader.download(r_url, "r-latest.pkg", overwrite: true)
        if !suc {
            try raise(exception: "Cannot find downloaded R package")
        }
        print("[RAVE]: R downloaded. Installing...")
        
        // installer -pkg "$INST_PATH/R-latest.pkg" -target "/usr/local/bin"
        let (out, err) = shell.exec_sudo("/usr/sbin/installer", [
            "-pkg", target.path, "-target", "/usr/local/bin"
        ])
        print(out ?? "")
        print(err ?? "")
    }
    
    // Install RStudio
    func install_rstudio() {
        print("=======================================================")
        print("[RAVE]: Download RStudio (optional installation)")
        var r_url = URL(string: "https://rstudio.com/products/rstudio/download/#download")!
        var (target, suc) = downloader.download(r_url, "rstudio.html", overwrite: true)
        if !suc {
            print("Cannot find to RStudio website")
            return
        }
        let (url, _) = shell.exec(
            "/usr/bin/grep",
            ["-o", "--max-count=1",
             "https://download1.rstudio.org/desktop/macos/RStudio-[[:digit:].]\\+.dmg",
             target.path
            ])
        
        guard let rsURL = url else {
            print("Cannot find to RStudio website")
            return
        }
        print(rsURL.trimmingCharacters(in: [" ", "\n"]))
        r_url = URL(string: rsURL.trimmingCharacters(in: [" ", "\n"]))!
        (target, suc) = downloader.download(r_url, "rstudio.dmg", overwrite: true)
        if !suc {
            print("Error while downloading RStudio")
            return
        }
        
        print("[RAVE]: Please drag RStudio into your /Application folder.")
        _ = shell.exec("/usr/bin/open", [ target.path ])
    }
    
    // Install RAVE
    func install_rave() throws {
        print("=======================================================")
        print("[RAVE]: Installing RAVE and its dependencies")
        var (out, err) = shell.exec_r("cat(normalizePath(Sys.getenv('R_LIBS_USER'), mustWork=FALSE))")
        
        let lib_path : String = out ?? ""
        if lib_path == "" {
            try raise(exception: "The user library path cannot be found!")
        }
        
        // create one if missing
        if !FileManager.default.fileExists(atPath: lib_path) {
            // Create user library with 777 permission
            try FileManager.default.createDirectory(
                atPath: lib_path,
                withIntermediateDirectories: true,
                attributes: [FileAttributeKey.posixPermissions : 0o777])
        }
        
        // Remove all 00LOCK* within lib_path
        _ = shell.exec("/bin/rm", [lib_path + "/00LOCK*"])
        
        // install packages
        shell.install_cran(cran_package: "Rcpp", into: lib_path, true)
        shell.install_cran(cran_package: "stringr", into: lib_path, true)
        shell.install_cran(cran_package: "devtools", into: lib_path, true)
        shell.install_cran(cran_package: "reticulate", into: lib_path, true)
        shell.install_cran(cran_package: "fftwtools", into: lib_path, true)
        shell.install_cran(cran_package: "hdf5r", into: lib_path, true)
        shell.install_cran(cran_package: "threeBrain", into: lib_path, false)
        shell.install_cran(cran_package: "raveio", into: lib_path, false)
        shell.install_cran(cran_package: "lazyarray", into: lib_path, true)
        shell.install_cran(cran_package: "docopt", into: lib_path, false)
        
        
        // install github packages
        shell.install_github(github_package: "dipterix/dipsaus", into: lib_path, true)
        shell.install_github(github_package: "beauchamplab/raveio", into: lib_path, false)
        shell.install_github(github_package: "beauchamplab/rave", into: lib_path, false)
        shell.install_github(github_package: "dipterix/rutabaga@develop", into: lib_path, false)
        shell.install_github(github_package: "beauchamplab/ravebuiltins@migrate2", into: lib_path, false)
        shell.install_github(github_package: "dipterix/threeBrain", into: lib_path, false)
        
        // Finalize installation: arrange modules and paths
        (out, err) = shell.exec_r("require(rave); rave::arrange_modules(refresh = TRUE, reset = FALSE)")
        
        print(out ?? "")
        print(err ?? "")
        
        (out, err) = shell.exec_r("rave::arrange_data_dir(TRUE, FALSE)")
        
        print(out ?? "")
        print(err ?? "")
        
        
        print("RAVE (main app) installation finished. Downloading utility scripts...")
        
        install_rave_scripts()
    }
    
    func install_rave_scripts() {
        var (cmdScript, suc) = downloader.download(
            URL(string: "https://raw.githubusercontent.com/beauchamplab/ravecmd/main/download-command.R")!,
            "rave-download-cmd.R", overwrite: true)
        
        if suc {
            // use R installed to run script
            _ = shell.exec_r(cmdScript.path, is_from_file: true, as_sudo: true, print_level : 2)
        } else {
            print("Error while downloading commands. No internet access? If you are sure you have the access to http://github.com/beauchamplab/ravecmd/ please file an issue.")
        }
        
        // Add to path
        (cmdScript, suc) = downloader.download(
            URL(string: "https://raw.githubusercontent.com/beauchamplab/ravecmd/main/osx/register-path.R")!,
            "rave-register-path.R", overwrite: true)
        
        if(suc) {
            _ = shell.exec_r(cmdScript.path, is_from_file: true, as_sudo: false, print_level : 2)
        }
        
    }
    
    
    func verify_r() -> Bool {
        
        let (out, err) = shell.exec("/usr/local/bin/Rscript", ["--version"])
        
        if err != nil && err != "" {
            print(String(format: "Error: %@", err ?? "An unknown error"))
            return false
        }
        print(out!)
        return true
    }
    
    func enable_sudo(exit_if_fails : Bool = true) {
        if !self.shell.enable_sudo( self.consoleIO ) {
            if exit_if_fails {
                print("Aborted.")
                exit(1)
            } else {
                print("Cannot run as Administrator...")
            }
        }
    }
    
    func ensure_r() {
        if !self.verify_r() {
            print("Cannot detect R installed at /usr/local/bin/ (Do you want to install it?)")
            print("Type \"YES\" to install: ")
            let ans = self.consoleIO.getInput()
            if ans.lowercased() != "yes" {
                print("Answer is not a \"YES\" not \"yes\"... aborted.")
                exit(1)
            }
            
            // Get Root
            
            self.enable_sudo()
            
            // Install R
            do {
                try self.install_r()
            } catch {
                print("Error: \(error.localizedDescription)")
                exit(2)
            }
        }
    }
    
}

