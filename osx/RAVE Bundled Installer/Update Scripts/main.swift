//
//  main.swift
//  Update Scripts
//
//  Created by beauchamplab on 11/22/20.
//

import Foundation


let rchecker = try RChecker()

rchecker.ensure_r()

if !rchecker.shell.validate_sudo() {
    // ask for sudo
    rchecker.enable_sudo()
}

// download scripts
rchecker.install_rave_scripts()


_ = rchecker.shell.exec("/usr/bin/open", ["/Applications/RAVE/bin"])




