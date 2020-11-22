//
//  main.swift
//  RAVE Bundled Installer
//
//  Created by beauchamplab on 11/21/20.
//

import Foundation


let rchecker = try RChecker()

rchecker.consoleIO.writeMessage(
    "This program installs RAVE.")

do {
    try _ = rchecker.consoleIO.getPassword("To start, please enter administrator password:", rchecker.shell)
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
rchecker.install_rstudio()

rchecker.install_xcode()

do {
    try rchecker.install_r()
} catch {
    print("Error: \(error.localizedDescription)")
}

do {
    try rchecker.install_rave()
} catch {
    print("Error: \(error.localizedDescription)")
}

print("[RAVE]: Installation finished. There might be some programs still running, but you are good to go!")







