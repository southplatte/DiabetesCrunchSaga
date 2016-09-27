//
//  Extensions.swift
//  DiabetesCrunchSaga
//
//  Created by Billy Nab on 9/2/15.
//  Copyright (c) 2015 Sucker Punch Ltd. All rights reserved.
//
import Foundation

extension Dictionary {
    static func loadJSONFromBundle(_ filename: String) -> Dictionary<String, AnyObject>? {
        if let path = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: "Levels") {
            
            let error: NSError?
            
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions())
                if let data = data as Data?{
                    
                    let dictionary: Any? = try JSONSerialization.jsonObject(with: data,
                        options: JSONSerialization.ReadingOptions())
                    if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                        return dictionary
                    } else {
                        print("Level file '\(filename)' is not valid JSON: \(error!)")
                        return nil
                    }
                } else {
                    print("Could not load level file:  (filename), error:  (error!)")
                    return nil
                }
            }
            catch{
                print("Error reading file")
                return nil
            }
            
            
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
        
    }
}
