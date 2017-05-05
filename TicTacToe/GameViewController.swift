//
//  GameViewController.swift
//  TicTacToe
//
//  Created by mg on 4/27/17.
//  Copyright © 2017 mg. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var activePlayer = 1
    var playerNum = 1
    var gameActive: Bool! = false
    var gameId: String!
    var gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var combos = [(Set<Int>, ((Double, Double), (Double, Double)))]()
    let defaults = UserDefaults.standard
    
    let diagRight = (CGPoint(x: 0, y: 0), CGPoint(x: 375, y: 375))

    @IBAction func action(_ sender: AnyObject) {
        
        if playerNum == activePlayer   {
            print("It's your turn!")
            if (gameState[sender.tag-1] == 0)  {
                processMove(player: playerNum, tag: sender.tag)
            }
            else    {
                return
            }
        }
        else    {
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(processMoveNotification), name: Notification.Name("move"), object: nil)
        
        let mode = defaults.string(forKey: "mode")!
        print("Player Number \(playerNum)")
        
        combos = [
         (Set([0, 4, 8]), ((0, 0), (375, 375))), // diagRight
         (Set([2, 4, 6]), ((375, 0), (0, 375))), // diagLeft
         (Set([0, 3, 6]), ((62.5, 0), (62.5, 375))), //vertLeft
         (Set([1, 4, 7]), ((187.5, 0), (187.5, 375))), // vertCenter
         (Set([2, 5, 8]), ((312.5, 0), (312.5, 375))), // vertRight
         (Set([0, 1, 2]), ((0, 62.5), (375, 62.5))), // horizTop
         (Set([3, 4, 5]), ((0, 187.5), (375, 187.5))), // horizCenter
         (Set([6, 7, 8]), ((0, 312.5), (375, 312.5))) // horizBottom
        ]
        gameActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func processMoveNotification()  {
        let move = defaults.dictionary(forKey: "notification")!
        print("processMoveNotification \(move)")
        let player = Int(move["playerNum"] as! String)!
        let tag = Int("\(move["tag"]!)")!
        
        processMove(player: player, tag: tag)
    }
    
    private func processMove(player: Int, tag: Int)  {
        
        let button = self.view.viewWithTag(tag) as! UIButton
        if (player == 1)    {
            button.setImage(UIImage(named: "TicTacToe_X.png"), for :UIControlState())
        }
        else    {
            button.setImage(UIImage(named: "tic-tac-toe-O.png"), for :UIControlState())
        }
        gameState[tag-1] = player
        notifyOfMove(player: player, tag: tag)
        
        if let (status, combo) = checkForWinner()    {
            
            var msg: String!
            var subMsg = ""
            
            if (status == "Draw")  {
                msg = "DRAW!"
            }
            else    {
                print("\(status) wins! Combo \(combo.0)")
                msg = "Player \(activePlayer) wins! (\(status.uppercased()))"
                
                let imageView = self.view.subviews.first as! UIImageView
                UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
                imageView.image?.draw(in: imageView.bounds)
                
                let context = UIGraphicsGetCurrentContext()
                context?.move(to: CGPoint(x: combo.1.0.0, y: combo.1.0.1))
                context?.addLine(to: CGPoint(x: combo.1.1.0, y: combo.1.1.1))
                context?.setLineWidth(20.0)
                
                if activePlayer == 1    {
                    context?.setStrokeColor(UIColor.blue.cgColor)
                }
                else    {
                    context?.setStrokeColor(UIColor.red.cgColor)
                }
                
                context?.setBlendMode(CGBlendMode.normal)
                context?.strokePath()
                
                imageView.image = UIGraphicsGetImageFromCurrentImageContext()
                imageView.alpha = 1.0
                UIGraphicsEndImageContext()
            }
            let gameStatus = UIAlertController(title: msg, message: subMsg, preferredStyle: .actionSheet)
            
            gameStatus.addAction(UIAlertAction(title: "Ok", style: .default)    { _ in
                self.gameActive = false
                self.gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            })
            
            self.present(gameStatus, animated: true)
        }
        if gameActive   {
            if (activePlayer == 1)  {
                activePlayer = 2
            }
            else    {
                activePlayer = 1
            }
        }
    }
    
    
    func deviceDidRotate()  {
        print("Rotation! \(UIDevice.current.orientation.isLandscape)")

    }
    
    func checkForWinner() -> (String, (Set<Int>, ((Double, Double), (Double, Double))))?  {
        var o = Set<Int>()
        var x = Set<Int>()
        
        for (index, value) in gameState.enumerated()    {
            if value == 1   {
                x.insert(index)
            }
            else if value == 2  {
                o.insert(index)
            }
        }        
        if (x.count < 3 && o.count < 3) {
            return nil
        }
        for combo in combos   {
            if x.intersection(combo.0).count == 3  {
                return("X", combo)
            }
            if o.intersection(combo.0).count == 3   {
                return("O", combo)
            }
        }
        if (x.count + o.count == 9) {
            return("Draw", ((Set<Int>(), ((0,0), (0,0)))))
        }
        return nil
    }
    
    private func notifyOfMove(player: Int, tag: Int)  {
        
        if let token = defaults.string(forKey: "deviceToken") {
            
            var url = URLComponents()
            url.scheme = "https"
            url.host = defaults.string(forKey: "apnsHost")!
            url.path = "/tictactoemove"
            
            var request = URLRequest(url: url.url!)
            
            let params: [String: Any] = [
                "player": token,
                "tag": tag,
                "gameId": gameId
            ]
            
            let body = try! JSONSerialization.data(withJSONObject: params)
            request.httpBody = body
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let error = error    {
                    print("APNS Provider error!, \(error)")
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("STATUS \(httpResponse.statusCode)")
                    switch httpResponse.statusCode {
                    case 200:
                        print("notifyOfMove success")
                    default:
                        print("notifyOfMove failed", httpResponse.statusCode)
                    }
                }
            })
            task.resume()
        }
    }

}
