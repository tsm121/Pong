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
    private var winnerLabel = SKLabelNode()
    private let goal = 5
    private var winner: Paddle!
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        //Init game elements
        self.setPaddles()
        self.setLabels()
        self.createArea()
        
        //Starting game
        self.createBall(num: 1)
        self.startGame()
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        if self.score1 == self.goal {
            self.winner = self.paddle1
            self.winnerLabel.text = "You WON!"
            self.winnerLabel.isHidden = false
            self.stopGame()
        } else if score2 == self.goal {
            self.winner = self.paddle2
            self.winnerLabel.text = "Phone won..."
            self.winnerLabel.isHidden = false
            self.stopGame()
        }
        
        if self.score1 == 1 || self.score2 == 1 {
            self.winnerLabel.isHidden = true
        }
        
        // Called before each frame is rendered
        //Init enemy ball
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
    

    //Init score labels
    func setLabels(){
        self.score1 = 0
        self.score2 = 0
        
        self.label1.position = CGPoint(x: self.frame.width/2 - 40,y: self.frame.height/2 + 170)
        self.label2.position = CGPoint(x: self.frame.width/2 + 20,y: self.frame.height/2 + 170)
        self.winnerLabel.position = CGPoint(x: self.frame.width/2 + 20,y: self.frame.height/2)

        self.label1.zRotation = CGFloat(300)
        self.label2.zRotation = CGFloat(300)
        self.winnerLabel.zRotation = CGFloat(300)
        
        self.label1.fontName = "Chalkduster"
        self.label2.fontName = "Chalkduster"
        self.winnerLabel.fontName = "Chalkduster"
        
        self.addChild(label1)
        self.addChild(label2)
        self.addChild(winnerLabel)
        self.winnerLabel.isHidden = true
    }
    
    //Init game paddles
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
    
    //Enemy AI for hitting the ball
    func followBall(paddle: SKShapeNode) {
        
        //Calculating delta between ball and paddle.
        //Moves paddle with a given speed to match y-position to ball
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
    
    //Init ball
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
    
    //Start game with ball speed and set score labels
    func startGame() {
        label1.text = "\(score1!)"
        label2.text = "\(score2!)"
        print("start game")
        ball.physicsBody?.applyImpulse(CGVector(dx:300, dy:self.getRandomNum(lowerValue: -45, upperValue: 45)))
    }
    
    func stopGame() {
        self.score1 = 0
        self.score2 = 0
        label1.text = "\(score1!)"
        label2.text = "\(score2!)"
        self.winner = nil
        ball.position = CGPoint(x: self.size.width/2,y: self.size.height/2)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
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
    //Create random number between a given range
    func getRandomNum(lowerValue:Int, upperValue:Int) -> Int{
        return Int(arc4random_uniform(UInt32(upperValue - lowerValue + 1))) +   lowerValue
    }
    
    //Add score to winning paddle. Set score lable
    func addScore(paddle: Paddle) {
        print("added score")
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
    
    //Ball paddle class
    class Paddle: SKShapeNode{

        private var paddlePhysicsbody: SKTexture!
        
        init(width: Double, height: Double, paddleNum: Int) {
            super.init()
            
            //Give each paddle a different physicsbody based on texture
            if paddleNum == 1 {
                self.paddlePhysicsbody = SKTexture(imageNamed: "paddle_physicsbody2.png")
            } else{
                self.paddlePhysicsbody = SKTexture(imageNamed: "paddle_physicsbody.png")
            }
            //Set physicsbody
            let paddleNode = SKSpriteNode(texture: paddlePhysicsbody)
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width/2, y: -height/2), size: CGSize(width: width, height: height)), transform: nil)
            self.physicsBody = SKPhysicsBody(texture:paddlePhysicsbody,size: CGSize(width: paddleNode.size.width-10, height: paddleNode.size.height+20))

            //Physics settings                                             
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.isDynamic = false
            self.physicsBody?.friction = CGFloat(0)
            self.physicsBody?.restitution = CGFloat(0)
            self.physicsBody?.angularDamping = CGFloat(0)
            self.physicsBody?.linearDamping = CGFloat(0)
            
            self.name = "paddle\(paddleNum)"
            self.fillColor = UIColor.white
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    //Listener for when touch began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Moves paddle to touch position
        for touch in touches {
            let touchLocation = touch.location(in: self)
            paddle1.run(SKAction.moveTo(y: touchLocation.y, duration: 0.1))
        }
    }
    
    //Listener for when touch in progress
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Moves paddle to touch position
        for touch in touches{
            let touchLocation = touch.location(in: self)
            paddle1.run(SKAction.moveTo(y: touchLocation.y, duration: 0.1))
            }
        }
    }
