//
//  FileManagerExt.swift
//  RAVE OSX Utilities
//
//  Created by beauchamplab on 11/21/20.
//

import Foundation


public extension FileManager {

    func temporaryFileURL(subPath: String = UUID().uuidString, _ create : Bool = false) -> URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(subPath)
    }
}


class Downloader {
    
    var objCTRUE: ObjCBool = true
    var objCFALSE: ObjCBool = false
    var lastSucceed = false
    var rootURL : URL
    var lastURL : URL?
    
    init (_ root : String = UUID().uuidString, _ intermediate : Bool = true) throws {
        rootURL = FileManager.default.temporaryFileURL(subPath: root)!
        
        if !FileManager.default.fileExists(atPath: rootURL.path,
                                           isDirectory: &self.objCTRUE) {
            // create the path
            try FileManager.default.createDirectory(
                atPath: rootURL.path, withIntermediateDirectories: intermediate,
                attributes: nil)
        }
        
    }
    
    func download (_ url : URL, _ fileName : String, overwrite :
                    Bool = false ) -> (URL, Bool) {
        
        
        self.lastURL = self.rootURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(
            atPath: self.lastURL!.path, isDirectory: &self.objCFALSE) {
            if overwrite {
                do {
                    try FileManager.default.removeItem(at: self.lastURL!)
                } catch {
                    // do nothing
                }
            } else {
                print ("File error: file exists.")
                self.lastSucceed = false
                return (self.lastURL!, false)
            }
        }
        
        self.lastSucceed = false
        
        
        let task = URLSession.shared.downloadTask(
            with: url, completionHandler: { (urlOrNil, responseOrNil, errorOrNil) in
                if let fileURL = urlOrNil {
                    do {
                        if FileManager.default.fileExists(
                            atPath: self.lastURL!.path, isDirectory: &self.objCFALSE) {
                            try FileManager.default.removeItem(at: self.lastURL!)
                        }
                        try FileManager.default.moveItem(at: fileURL, to: self.lastURL!)
                    } catch {
                        print ("File error: \(error.localizedDescription)")
                    }
                    self.lastSucceed = true
                }
        })
        task.resume()
        
        var fractionCompleted = task.progress.fractionCompleted
        
        while !self.lastSucceed {
            // still in progress
            if fractionCompleted < task.progress.fractionCompleted {
                fractionCompleted = task.progress.fractionCompleted
                print(String(format: "\rFinished (%.0f%%)", fractionCompleted * 100.0),
                      terminator : "     ")
            }
            
            usleep(500000)
        }
        print("Downloaded.")
        
        if FileManager.default.fileExists(
            atPath: self.lastURL!.path, isDirectory: &self.objCFALSE) {
            self.lastSucceed = true
        } else {
            self.lastSucceed = false
        }
        
        return (self.lastURL!, self.lastSucceed)
    }
    
    
}
