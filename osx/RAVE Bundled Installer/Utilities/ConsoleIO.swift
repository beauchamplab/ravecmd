//
//  ConsoleIO.swift
//  RAVE OSX Utilities
//
//  Created by Zhengjia Wang on 11/21/20.
//

import Foundation

enum OutputType {
  case error
  case standard
}

enum ConsoleError : Error {
    case runtimeError(String)
}


class ConsoleIO {
    
    static var interactive = false
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
      switch to {
      case .standard:
        print("\(message)")
      case .error:
        fputs("Error: \(message)\n", stderr)
      }
    }
    
    func printUsage() {

      let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
            
      writeMessage("usage:")
      writeMessage("\(executableName) -a string1 string2")
      writeMessage("or")
      writeMessage("\(executableName) -p string")
      writeMessage("or")
      writeMessage("\(executableName) -h to show usage information")
      writeMessage("Type \(executableName) without an option to enter interactive mode.")
    }
    
    func getInput() -> String {
      // 1
      let keyboard = FileHandle.standardInput
        
      // 2
      let inputData = keyboard.availableData
      // 3
      let strData = String(data: inputData, encoding: String.Encoding.utf8)!
      // 4
      return strData.trimmingCharacters(in: CharacterSet.newlines)
    }
    
    func getPassword(_ msg : String = "Please enter your password: \n", _ shell : Shell? ) throws -> String {
        
        var pass : String?
        var attempts = 0
        var passed = false
        
        while attempts < 3 {
            if attempts == 0 {
                writeMessage(msg)
                pass = String(validatingUTF8: UnsafePointer<CChar>(getpass("")))
            }
            else {
                pass = String(validatingUTF8: UnsafePointer<CChar>(getpass("Incorrect password. Please re-enter: ")))
            }
            if pass != nil {
                if shell == nil {
                    passed = true
                    break
                }
                else {
                    // check password
                    shell!.pwd = pass!
                    passed = shell!.validate_sudo()
                    if passed {
                        break
                    }
                }
            }
            attempts += 1
        }
        
        if !passed {
            throw ConsoleError.runtimeError("Password Invalid.")
        }
        
        
        return pass!
    }
    
}




