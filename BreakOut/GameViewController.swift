//
//  GameViewController.swift
//  BreakOut
//
//  Created by Edward LU on 7/28/16.
//  Copyright © 2016 Edward Lu. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var dynamicAnimator = UIDynamicAnimator()
    var pushBehavior = UIPushBehavior()
    var collisionBehavior = UICollisionBehavior()
    var paddle = UIView()
    var ball = UIView()
    var lives = 5
    var allObjects = [UIDynamicItem]()
    var bricks = [Brick]()
    var brickColors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetButton.isHidden = true
        
        // Ball
        ball = UIView(frame: CGRect(x: view.center.x, y: view.center.y, width: 20, height: 20))
        ball.backgroundColor = UIColor.brown
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        view.addSubview(ball)
        
        // Paddle
        paddle = UIView(frame: CGRect(x: view.center.x, y: view.center.y * 1.7, width: 80, height: 20))
        paddle.backgroundColor = UIColor.black
        view.addSubview(paddle)
        
        createStartingBricks()
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // Ball dynamics
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        // Paddle dynamics
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        //Brick dynamics
        let brickDynamicBehavior = UIDynamicItemBehavior(items: bricks)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        for brick in bricks {
            allObjects.append(brick)
        }
        
        // Push ball
        pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0.2, dy: 1.0)
        pushBehavior.magnitude = 0.35
        dynamicAnimator.addBehavior(pushBehavior)
        
        allObjects.append(paddle)
        allObjects.append(ball)
        
        // Collision behaviors
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        livesLabel.text = "Lives: \(lives)"
    }
    
    func createRowOfAdjacentBricks(_ height: CGFloat, yValue: CGFloat, amount: Int, color: UIColor, startIndexForLoop: Int, brickMargin: CGFloat) {
        let width = (view.frame.width - CGFloat(amount + 1) * brickMargin ) / CGFloat(amount)
        var xValue = CGFloat(0.0) + brickMargin
        for brickNumber in startIndexForLoop..<amount + startIndexForLoop {
            bricks.append(Brick(frame: CGRect(x: xValue, y: yValue, width: width, height: height), originalColor: color))
            bricks[brickNumber].backgroundColor = color
            view.addSubview(bricks[brickNumber])
            xValue += (width + brickMargin)
        }
    }
    
    func createStartingBricks() {
        var yValue = CGFloat(50)
        var prevAmount = 0
        for color in brickColors {
            let amount = 8
            let height = CGFloat(20)
            createRowOfAdjacentBricks(height, yValue: yValue, amount: amount, color: color, startIndexForLoop: prevAmount, brickMargin: 5)
            prevAmount += amount
            yValue += (height + CGFloat(drand48() + 0.1) * 5.0)
        }

        
    }
    
    func checkForWin() -> Bool {
        for brick in bricks {
            if brick.isHidden == false {
                return false
            }
        }
        return true
    }
    

    func reset() {
        UIApplication.shared.keyWindow?.rootViewController = storyboard!.instantiateViewController(withIdentifier: "GameView")
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if item.isEqual(ball) && p.y > paddle.center.y {
            lives -= 1
            if lives > 0 {
                livesLabel.text = "Lives: \(lives)"
                ball.center = view.center
                dynamicAnimator.updateItem(usingCurrentState: ball)
            } else {
                livesLabel.text = "You lose"
                ball.removeFromSuperview()
                collisionBehavior.removeItem(ball)
                dynamicAnimator.updateItem(usingCurrentState: ball)
                resetButton.isHidden = false
            }
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        for brick in bricks {
            if (item1.isEqual(ball) && item2.isEqual(brick)) || (item2.isEqual(ball) && item1.isEqual(brick)) {
                if brick.backgroundColor != UIColor.purple {
                    brick.backgroundColor = brickColors[brickColors.index(of: brick.backgroundColor!)! + 1]
                } else {
                    brick.isHidden = true
                    brick.removeFromSuperview()
                    collisionBehavior.removeItem(brick)
                    dynamicAnimator.updateItem(usingCurrentState: brick)
                }
            }
        }
        if checkForWin() {
            ball.removeFromSuperview()
            collisionBehavior.removeItem(ball)
            dynamicAnimator.updateItem(usingCurrentState: ball)
            livesLabel.text = "You win!"
            resetButton.isHidden = false
        }
    }
    
    @IBAction func dragPaddle(_ sender: UIPanGestureRecognizer) {
        let panGesture = sender.location(in: view)
        paddle.center.x = panGesture.x
        dynamicAnimator.updateItem(usingCurrentState: paddle)
    }
    
    @IBAction func onTappedResetButton(_ sender: UIButton) {
        reset()
        resetButton.isHidden = true
    }
}
