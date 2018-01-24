//
//  GameScene.swift
//  Pong
//
//  Created by Thomas Markussen on 24/01/2018.
//  Copyright © 2018 ThomasM. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var paddle1: Paddle!
    private var paddle2: Paddle!
    private var ball: SKShapeNode!
    private var height: Double!
    private var width: Double!
    
    override func didMove(to view: SKView) {
        
        self.height = 50
        self.width = 10
        
        self.createArea()
        
        paddle1 = Paddle(width: self.width, height: self.height)
        paddle2 = Paddle(width: self.width, height: self.height)
        paddle1.position = CGPoint(x: 30, y: self.size.height/2)
        paddle2.position = CGPoint(x: self.size.width-30, y: self.size.height/2)
        




        self.addChild(paddle1)
        self.addChild(paddle2)
        self.createBall(num: 1)
        self.startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        followBall(paddle: paddle2)
    }
    
    func followBall(paddle: SKShapeNode) {
        
        let xPos = self.frame.width/2
        let maxSpeed: CGFloat = 10
        let delta = ball.position.y - paddle.position.y
        if ball.position.x > xPos {
            
            if delta > 0{
                paddle2.position.y += min(maxSpeed, delta)

            } else if delta < 0 {
                paddle2.position.y += max(-maxSpeed, delta)
            }

        }
    }
    
    func createBall(num:Int){
        for _ in 1...num {
            ball = SKShapeNode(circleOfRadius: 5)
            ball.fillColor = UIColor.white
            ball.position = CGPoint(x: self.size.width/2,y: self.size.height/2)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.height/2)
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.friction = 0
            ball.physicsBody?.restitution = 1
            ball.physicsBody?.linearDamping = 0
            ball.physicsBody?.angularDamping = 0
            ball.name = "ball"
            self.addChild(ball)
        }
    }
    
    func startGame() {
        ball.physicsBody?.velocity = CGVector(dx:350, dy:self.getRandomNum(lowerValue: -45, upperValue: 45))
    }
    
    //Create player area with bounderies, together with physics
    func createArea() {
        self.scene?.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundColor = UIColor.black
        self.scaleMode = .aspectFill
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.angularDamping = 1
        self.physicsBody?.linearDamping = 0

    }
    //Create random number
    func getRandomNum(lowerValue:Int, upperValue:Int) -> Int{
        return Int(arc4random_uniform(UInt32(upperValue - lowerValue + 1))) +   lowerValue
    }
    
    
    class Paddle: SKShapeNode{
        init(width: Double, height: Double) {
            super.init()
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width/2, y: -height/2), size: CGSize(width: width, height: height)), transform: nil)
            self.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(max(width/2.15, height/2.15)))
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.friction = 0
            self.physicsBody?.restitution = 0
            self.physicsBody?.angularDamping = 0
            self.physicsBody?.linearDamping = 0
            self.physicsBody?.isDynamic = false
            self.name = "paddle"
            self.fillColor = UIColor.white

        }
        

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            var touchLocation = touch.location(in: self)
            let targetNode = atPoint(touchLocation) as? SKShapeNode
            
            if targetNode == nil{
                return
            } else if targetNode?.name != "ball"{
                targetNode?.physicsBody?.velocity = CGVector(dx: 0, dy:0)
                touchLocation = touch.location(in: self)
                targetNode?.position.y = (touchLocation.y)
            }
        }
    }
}
