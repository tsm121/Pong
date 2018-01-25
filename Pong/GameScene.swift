//
//  GameScene.swift
//  Pong
//
//  Created by Thomas Markussen on 24/01/2018.
//  Copyright © 2018 ThomasM. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let None:        UInt32 = 0      //  0
    static let Edge:        UInt32 = 0b1    //  1
    static let Paddle:      UInt32 = 0b10   //  2
    static let Ball:        UInt32 = 0b100  //  4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var paddle1: Paddle!
    private var paddle2: Paddle!
    private var ball: SKShapeNode!  
    private var height: Double!
    private var width: Double!
    private var score1: Int!
    private var score2: Int!
    private var label1 = SKLabelNode()
    private var label2 = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        

        self.setPaddles()
        self.setLabels()
        //self.createArea()
        
        self.createBall(num: 1)
        self.createArea()
        physicsWorld.contactDelegate = self
        self.startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        followBall(paddle: paddle2)
        
        // Wall bounce hardcode
        if ball.position.y < 20 || ball.position.y > self.frame.height - 20 {
            ball.physicsBody?.velocity.dy = -CGFloat((ball.physicsBody?.velocity.dy)!)
        }
        
        
        // Add scores
        if ball.position.x < paddle1.position.x {
            addScore(paddle: paddle2)
        } else if ball.position.x > paddle2.position.x {
            addScore(paddle: paddle1)
        }
    }
    
    func setLabels(){
        self.score1 = 0
        self.score2 = 0
        
        self.label1.position = CGPoint(x: self.frame.width/2 - 40,y: self.frame.height/2 + 170)
        self.label2.position = CGPoint(x: self.frame.width/2 + 20,y: self.frame.height/2 + 170)

        self.label1.zRotation = CGFloat(300)
        self.label2.zRotation = CGFloat(300)

        self.label1.fontName = "Chalkduster"
        self.label2.fontName = "Chalkduster"
        
        self.addChild(label1)
        self.addChild(label2)
    }
    
    func setPaddles(){
        self.height = 50
        self.width = 10
    
        paddle1 = Paddle(width: self.width, height: self.height, paddleNum: 1)
        paddle2 = Paddle(width: self.width, height: self.height, paddleNum: 2)
        
        paddle1.position = CGPoint(x: 30, y: self.size.height/2)
        paddle2.position = CGPoint(x: self.size.width-30, y: self.size.height/2)
        
        self.addChild(paddle1)
        self.addChild(paddle2)
        
    }
    
    func followBall(paddle: SKShapeNode) {
        
        let xPos = self.frame.width/2
        let maxSpeed: CGFloat = 3
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
            ball = SKShapeNode(circleOfRadius: 10)
            ball.fillColor = UIColor.green
            ball.position = CGPoint(x: self.size.width/2,y: self.size.height/2)
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.height/50)
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.mass = CGFloat(1)
            ball.physicsBody?.friction = CGFloat(0)
            ball.physicsBody?.restitution = CGFloat(1)
            ball.physicsBody?.linearDamping = CGFloat(0)
            ball.physicsBody?.angularDamping = CGFloat(0)
            ball.physicsBody!.categoryBitMask = PhysicsCategory.Ball
            ball.physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Paddle
            ball.physicsBody?.usesPreciseCollisionDetection = true
            ball.name = "ball"
            self.addChild(ball)
        }
    }
    
    func startGame() {
        label1.text = "\(score1!)"
        label2.text = "\(score2!)"
        ball.physicsBody?.applyImpulse(CGVector(dx:400, dy:self.getRandomNum(lowerValue: -45, upperValue: 45)))
    }
    
    //Create player area with bounderies, together with physics
    func createArea() {
        self.scene?.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundColor = UIColor.black
        self.scaleMode = .aspectFill
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)

        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.restitution = CGFloat(0)
        self.physicsBody?.angularDamping = CGFloat(0)
        self.physicsBody?.linearDamping = CGFloat(0)
        self.physicsBody!.categoryBitMask = 0
        self.physicsBody?.isDynamic = false

    }
    //Create random number
    func getRandomNum(lowerValue:Int, upperValue:Int) -> Int{
        return Int(arc4random_uniform(UInt32(upperValue - lowerValue + 1))) +   lowerValue
    }
    
    func addScore(paddle: Paddle) {
        ball.position = CGPoint(x: self.size.width/2,y: self.size.height/2)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        if paddle == paddle1 {
            self.score1 = self.score1 + 1
            ball.physicsBody?.applyImpulse(CGVector(dx: 400, dy: self.getRandomNum(lowerValue: -150, upperValue: 150)))

        }
        else if paddle == paddle2 {
            self.score2 = self.score2 + 1
            ball.physicsBody?.applyImpulse(CGVector(dx: -400, dy: self.getRandomNum(lowerValue: -180, upperValue: 180)))

        }
        
        label1.text = "\(score1!)"
        label2.text = "\(score2!)"
        
    }
    
    
    class Paddle: SKShapeNode{
        private var paddlePhysicsbody: SKTexture!
        init(width: Double, height: Double, paddleNum: Int) {
            super.init()
            if paddleNum == 1 {
                self.paddlePhysicsbody = SKTexture(imageNamed: "paddle_physicsbody2.png")
            } else{
                self.paddlePhysicsbody = SKTexture(imageNamed: "paddle_physicsbody.png")
            }
            let paddleNode = SKSpriteNode(texture: paddlePhysicsbody)
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width/2, y: -height/2), size: CGSize(width: width, height: height)), transform: nil)
            self.physicsBody = SKPhysicsBody(texture:paddlePhysicsbody,
                                             size: CGSize(width: paddleNode.size.width-10, height: paddleNode.size.height+20))
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.isDynamic = false
            self.physicsBody?.friction = CGFloat(0)
            self.physicsBody?.restitution = CGFloat(0)
            self.physicsBody?.angularDamping = CGFloat(0)
            self.physicsBody?.linearDamping = CGFloat(0)
            self.name = "paddle"
            self.fillColor = UIColor.white

        }
        

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            paddle1.run(SKAction.moveTo(y: touchLocation.y, duration: 0.1))
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let touchLocation = touch.location(in: self)
            
            paddle1.run(SKAction.moveTo(y: touchLocation.y, duration: 0.1))
            }
        }
    }

