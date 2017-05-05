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
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        readPlist()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkMatchRequestStatus()  {
        let matchStatus = defaults.dictionary(forKey: "notification")!;
        let msgType = matchStatus["msgType"] as! String
        let msg = matchStatus["msg"] as! String
        print("Match status \(msgType)")
        
        switch msgType  {
            case "pending match":
                activityIndicator(msg)
            case "player assignment":
                if let activity = self.view.subviews.first(where: { $0 is UIVisualEffectView }) {
                    activity.removeFromSuperview()
                }
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
                self.navigationController?.pushViewController(vc, animated:true)
                vc.playerNum = Int(msg)!
                vc.gameId = "\(matchStatus["gameId"]!)"
            default:
                print("We shouldn't be here")
        }
    }
    
    private func playerMatchRequest()  {
        
        if let token = defaults.string(forKey: "deviceToken") {
            
            defaults.set(plist!["ApnsProvider"]! as! String, forKey: "apnsHost")
            
            var url = URLComponents()
            url.scheme = "https"
            url.host = defaults.string(forKey: "apnsHost")!
            url.path = "/requestplayermatch"
            
            var request = URLRequest(url: url.url!)
            
            let params: [String: Any] = [
                "device_token": token,
                "app": "TicTacToe"
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
    
    private func activityIndicator(_ msg: String)  {
        DispatchQueue.main.async    {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            
            let label = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 46))
            label.text = msg
            label.font = UIFont.systemFont(ofSize:11, weight: UIFontWeightMedium)
            label.textColor = UIColor.white
            
            effectView.frame = CGRect(x: self.view.frame.midX - label.frame.width/2, y: self.view.frame.midY - label.frame.height/2, width: 200, height: 46)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()
            
            effectView.addSubview(activityIndicator)
            effectView.addSubview(label)
            
            self.view.addSubview(effectView)
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

