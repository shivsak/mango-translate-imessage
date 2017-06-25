//
//  TranslateApi.swift
//  translateApp
//
//  Created by Shiv Sakhuja on 6/24/17.
//  Copyright © 2017 Shiv Sakhuja. All rights reserved.
//

import Foundation

class TranslateApi {
    
    let ROOT_URL = "https://quiet-woodland-92550.herokuapp.com"
    
    func translate(string:String, targetLanguage:String, onSuccess:@escaping ((String) -> Void), onFailure: @escaping ((Error) -> Void)) {
        print("Translate \(string) to \(targetLanguage)")
        
        let url = URL(string: "\(ROOT_URL)/translate/\(targetLanguage)")
        print("\n\n \(url!)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let payloadString: String = "{\"text\": \"\(string)\"}"
        let payloadData : Data = payloadString.data(using: .utf8)!
        request.httpBody = payloadData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let queue:OperationQueue = OperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) {
            response, data, error in
            
            if data == nil {
                print("sendAsynchronousRequest error: \(String(describing: error))")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if statusCode != 200 {
                    print("sendAsynchronousRequest status code = \(statusCode); response = \(response.debugDescription))")
                }
            }
            print(NSString(data: data!, encoding: UInt.init(8)) ?? "Unable to get a response from the translate API.")
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let status = json["status"] as? String {
                        if status == "success" {
                            if let result = json["result"] as? String {
                                onSuccess(result)
                            }
                        } else {
                            if let error = json["error"] as? Error {
                                onFailure(error)
                            }
                        }
                    }
            } catch {
                print("Error deserializing JSON: \(error)")
                onFailure(error)
                return
            }
            
            
            
        }
        
    }
    
    
}
