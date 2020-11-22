//
//  Shell.swift
//  RAVE OSX Utilities
//
//  Created by beauchamplab on 11/21/20.
//

import Foundation


class Shell {
    
    var pwd : String
    
    init(_ password : String?){
        
        if password != nil {
            pwd = password!;
        }
        else {
            pwd = "123"
        }
        
    }
    
    func enable_sudo(_ consoleIO : ConsoleIO, _ prompt : String? = nil) -> Bool {
        do {
            if prompt == nil {
                try _ = consoleIO.getPassword("Please enter your password: \n", self)
            } else {
                try _ = consoleIO.getPassword(prompt!, self)
            }
            return true
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return false
    }
    
    func validate_sudo() -> Bool {
        
        let (out, _) = exec_sudo("/bin/echo", ["123"])
        
        // check if passed
        if let s = out {
            if s == "123" || s == "123\n" {
                return true
            }
        }
        
        
        return false
    }
    
    func exec_sudo(_ command : String, _ args : Array<String> = []) -> (String?, String?) {
        let taskOne = Process()
        taskOne.launchPath = "/bin/echo"
        taskOne.arguments = [pwd]

        let taskTwo = Process()
        taskTwo.launchPath = "/usr/bin/sudo"
        taskTwo.arguments = ["-S", command] + args

        // Connect two pipes

        let pipeBetween:Pipe = Pipe()
        taskOne.standardOutput = pipeBetween
        taskTwo.standardInput = pipeBetween
        taskOne.launch()

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        taskTwo.standardOutput = outputPipe
        taskTwo.standardError = errorPipe

        // get results
        taskTwo.launch()
        taskTwo.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: String.Encoding.utf8)

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(data: errorData, encoding: String.Encoding.utf8)


        return (output, error)

    }
    
    
    func exec(_ command : String, _ args : Array<String> = []) -> (String?, String?) {
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: command)
        task.arguments = args

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        do {
            try task.run()
        } catch {
            return("", error.localizedDescription)
        }
        
        task.waitUntilExit()
        
        let dataOutput = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: dataOutput, encoding: String.Encoding.utf8)
        
        let errorOutput = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(data: errorOutput, encoding: String.Encoding.utf8)

        return (output, error)
        
    }
    
    func exec_r(_ command : String,
                _ binary : String = "/usr/local/bin/Rscript",
                _ args : Array<String> = ["--no-save", "--no-restore", "--no-site-file" , "--no-init-file"],
                is_from_file is_file : Bool = false,
                as_sudo : Bool = false,
                print_level : Int = 0
    ) -> (String?, String?) {
        
        var script_arg = args
        
        if is_file {
            script_arg += [command]
        } else {
            script_arg += ["-e", command]
        }
        let out : String?
        let err : String?
        if as_sudo {
            (out, err) = exec_sudo(binary, script_arg)
        } else {
            (out, err) = exec(binary, script_arg)
        }
        if print_level == 1{
            print(out ?? "")
        } else if print_level == 2 {
            print(out ?? "")
            print(err ?? "")
        }
        return (out, err)
        
    }
    
    func install_cran(cran_package pkg : String,
                      into lib : String,
                      _ binary : Bool = true) {
        print("[RAVE]: Installing R package \(pkg) from CRAN")
        let cmd = String(
            format: "utils::install.packages('%@',type='%@',repos='https://cloud.r-project.org',lib='%@')",
            pkg, binary ? "binary" : "source", lib)
        let (out, err) = exec_r(cmd)
        print(out ?? "")
        print(err ?? "")
    }
    
    func install_github(github_package pkg : String,
                        into lib : String,
                        _ binary : Bool = true) {
        print("[RAVE]: Installing R package \(pkg) from Github")
        let cmd = String(
            format: "remotes::install_github('%@',upgrade=FALSE,force=TRUE,type='%@',lib='%@')",
            pkg, binary ? "binary" : "source", lib)
        let (out, err) = exec_r(cmd)
        print(out ?? "")
        print(err ?? "")
    }
    
}



