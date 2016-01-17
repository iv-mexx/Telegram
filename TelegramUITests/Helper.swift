//
//  Helper.swift
//  Telegraph
//
//  Created by Markus Chmelar on 17/01/16.
//
//

import Foundation

/// Helper to communicate with the Telegram CLI Client via the Telegram UI-Test Request Server
/// See https://github.com/iv-mexx/TelegramUITestRequestServer
class TelegraphHelper {
    /// URL of the Telegram UI-Test Request Server
    static let TelegramServerURL = "http://0.0.0.0:3000"
    /// Timeout in Seconds
    static let Timeout = 60
    
    ///  Serializes an NSData containing JSON data into an NSDictionary
    ///
    ///  - parameter data: A data object containing JSON data.
    ///
    ///  - returns: An NSDictionary with the contents of the JSON data
    static func deserialize(data: NSData?) -> NSDictionary? {
        guard let data = data else {
            return nil
        }
        
        var dictionary: NSDictionary?
        do {
           dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
        } catch {
            
        }
        return dictionary
    }
    
    ///  Perform a NSURLRequest synchronously and return the JSON response as NSDictionary
    ///
    ///  - parameter request: A NSURLRequest
    ///
    ///  - returns: an NSDictionary containing the JSON response of the request
    static func performRequestSync(request: NSURLRequest) -> NSDictionary? {
        let sem = dispatch_semaphore_create(0)
        var dictionary: NSDictionary?
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            dictionary = deserialize(data)
            dispatch_semaphore_signal(sem)
        }
        task.resume()
        
        dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, Int64(TelegraphHelper.Timeout) * Int64(NSEC_PER_SEC)))
        
        return dictionary

    }
    
    ///  Synchronously GETs Data from the Telegram UI-Test Request Server and returns the response
    ///
    ///  - parameter path: The path that should be requested
    ///
    ///  - returns: NSDictionary with the response
    static func GETDataSync(path: String) -> NSDictionary? {
        let url = NSURL(string: "\(TelegraphHelper.TelegramServerURL)/\(path)")!
        let request = NSURLRequest(URL: url)
        return performRequestSync(request)
    }
    
    ///  Synchronously POSTs Data to the Telegram UI-Test Request Server  and returns the response
    ///
    ///  - parameter path: The path to post to
    ///  - parameter data: The data to post
    ///
    ///  - returns: NSDictionary with the response
    static func POSTDataSync(path: String, data: NSDictionary) -> NSDictionary? {
        let url = NSURL(string: "\(TelegraphHelper.TelegramServerURL)/\(path)")!
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions())
        } catch {
            return nil
        }
        
        return performRequestSync(request)
    }
    
    ///  Request the telegram confirmation code
    ///
    ///  - returns: The confirmation code
    static func getConfirmationCode() -> String? {
        return GETDataSync("confirmationCode")?["code"] as? String
    }
    
    ///  Request the last received message
    ///  To configure from which contact, see the Telegram node server
    ///
    ///  - returns: The last received message
    static func getLastMessage() -> String? {
        return GETDataSync("lastMessage")?["message"] as? String
    }
    
    ///  Request to send a message
    ///  To configure to which contact, see the Telegram node server
    ///
    ///  - parameter message: The message that should be sent
    ///
    ///  - returns: TRUE on success, FALSE on failure
    static func sendMessage(message: String) -> Bool {
        return POSTDataSync("message", data: ["message": message])?["message"] != nil
    }
}
