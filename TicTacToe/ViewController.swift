//
//  ViewController.swift
//  TicTacToe
//
//  Created by mg on 4/27/17.
//  Copyright © 2017 mg. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var plist: NSDictionary?
    
    @IBAction func onePlayer(_ sender: UIButton) {
        defaults.set("singlePlayer", forKey: "mode")
    }
    
    @IBAction func twoPlayer(_ sender: UIButton) {
        print("twoPlayer")
        defaults.set("twoPlayer", forKey: "mode")
        playerMatchRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkMatchRequestStatus), name: Notification.Name("matchStatus"), object: nil)
        readPlist()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkMatchRequestStatus()  {
        let status = defaults.dictionary(forKey: "matchStatus");
        print("Match status \(status!)")
    
    }
    
    private func playerMatchRequest()  {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "deviceToken") {
            
            let apnsHost = plist!["ApnsProvider"]! as! String
            print("APNS \(apnsHost)")
            
            var url = URLComponents()
            url.scheme = "https"
            url.host = apnsHost
            url.path = "/requestplayermatch"
            
            var request = URLRequest(url: url.url!)
            
            let params: [String: Any] = [
                "device_token": token,
                "game": "TicTacToe"
            ]
            
            let body = try! JSONSerialization.data(withJSONObject: params)
            request.httpBody = body
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let error = error    {
                    print("APNS Provider error!, \(error)")
                    
                    // To do REVERT to 1-player
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("STATUS \(httpResponse.statusCode)")
                    switch httpResponse.statusCode {
                    case 200:
                        print("playerMatchRequest success")
                    default:
                        print("manageDeviceToken Request failed", httpResponse.statusCode)
                    }
                }
            })
            task.resume()
        }
    }
    
    private func readPlist()     {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            plist = NSDictionary(contentsOfFile: path)
        }
        else{
            print("Unable to get contents of plist")
        }
    }


}

