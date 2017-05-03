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
    var gameActive: Bool! = false
    var gameState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var combos = [(Set<Int>, ((Double, Double), (Double, Double)))]()
    
    let diagRight = (CGPoint(x: 0, y: 0), CGPoint(x: 375, y: 375))

    @IBAction func action(_ sender: AnyObject) {
        
        if (gameState[sender.tag-1] == 0)  {
            
            gameState[sender.tag-1] = activePlayer
            if (activePlayer == 1)  {
                sender.setImage(UIImage(named: "TicTacToe_X.png"), for :UIControlState())
            }
            else    {
                sender.setImage(UIImage(named: "tic-tac-toe-O.png"), for :UIControlState())
            }
        }
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}
