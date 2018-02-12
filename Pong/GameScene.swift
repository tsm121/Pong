//
//  Pong 9000^69
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let None:        UInt32 = 0      //  0
    static let Edge:        UInt32 = 0b1    //  1
    static let Paddle:      UInt32 = 0b10   //  2
    static let Ball:        UInt32 = 0b100  //  4
}

enum paddlePosition {
    case top
    case bottom
}

enum ballType {
    case smallCircle
    case bigCircle
    case square
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var paddle1: Paddle!
    private var paddle2: Paddle!
    private var ball: SKShapeNode!  
    private var height: Double!
    private var width: Double!
    private var winnerLabel = SKLabelNode()
    private let goal = 21
    private var winner: Paddle!
    private var labels: singletonLabel!
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        //Init game elements
        self.setPaddles()
        self.createArea()
        
        //Starting game
        ball = ShapeFactory(view: self, shape: .smallCircle).makeShape()
        self.addChild(ball)
        
        singletonLabel.labels.setLabels(view: self)
        singletonLabel.labels.startGame(ball: self.ball)
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        //Winner/Loser lables
        singletonLabel.labels.hasWinner(paddle1: self.paddle1, paddle2: self.paddle2, ball: self.ball, view: self)
        
        // Called before each frame is rendered
        //Init enemy ball
        if !self.paddle1.player {
            self.paddle1.followBall(ball: self.ball, view: self)
        }
        if !self.paddle2.player{
            self.paddle2.followBall(ball: self.ball, view: self)
        }
        
        // Wall bounce hardcode
        if ball.position.y < 20 || ball.position.y > self.frame.height - 20 {
            ball.physicsBody?.velocity.dy = -CGFloat((ball.physicsBody?.velocity.dy)!)
        }
        
        
        // Add scores
        if ball.position.x < paddle1.position.x {
            singletonLabel.labels.addScore(scoringPaddle: paddle2, ball: self.ball, view: self)
        } else if ball.position.x > paddle2.position.x {
            singletonLabel.labels.addScore(scoringPaddle: paddle1, ball: self.ball, view: self)
        }
    }
    

    
    
    //Init game paddles
    func setPaddles(){
        self.height = 50
        self.width = 10
    
        paddle1 = Paddle(width: self.width, height: self.height, player: true, paddlePosition: .bottom, view: self)
        paddle2 = Paddle(width: self.width, height: self.height, player: false, paddlePosition: .top, view: self)
        
        self.addChild(paddle1)
        self.addChild(paddle2)
    }
    
    
    //Start game with ball speed and set score labels

    
    
    
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
    
    
    class singletonLabel {
        private var score1: Int!
        private var score2: Int!
        private var label1 = SKLabelNode()
        private var label2 = SKLabelNode()
        private var winnerLabel = SKLabelNode()
        private let goal = 21
        public static let labels = singletonLabel()

        
        private init() {}
        
        func setLabels(view: SKScene){
            self.score1 = 0
            self.score2 = 0
            
            self.label1.position = CGPoint(x: view.frame.width/2 - 40,y: view.frame.height/2 + 170)
            self.label2.position = CGPoint(x: view.frame.width/2 + 20,y: view.frame.height/2 + 170)
            self.winnerLabel.position = CGPoint(x: view.frame.width/2 + 20,y: view.frame.height/2)
            
            self.label1.zRotation = CGFloat(300)
            self.label2.zRotation = CGFloat(300)
            self.winnerLabel.zRotation = CGFloat(300)
            
            self.label1.fontName = "Chalkduster"
            self.label2.fontName = "Chalkduster"
            self.winnerLabel.fontName = "Chalkduster"
            
            view.addChild(label1)
            view.addChild(label2)
            view.addChild(winnerLabel)
            self.winnerLabel.isHidden = true
        }
        
        func startGame(ball: SKShapeNode) {
            self.label1.text = "\(score1!)"
            self.label2.text = "\(score2!)"
            ball.physicsBody?.applyImpulse(CGVector(dx:400, dy:self.getRandomNum(lowerValue: -45, upperValue: 45)))
        }
        
        func addScore(scoringPaddle: Paddle, ball: SKShapeNode, view: SKScene) {
            ball.position = CGPoint(x: view.size.width/2,y: view.size.height/2)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            if scoringPaddle.pp == .bottom {
                self.score1 = self.score1 + 1
                ball.physicsBody?.applyImpulse(CGVector(dx: 400, dy: self.getRandomNum(lowerValue: -150, upperValue: 150)))
                
            }
            else if scoringPaddle.pp == .top {
                self.score2 = self.score2 + 1
                ball.physicsBody?.applyImpulse(CGVector(dx: -400, dy: self.getRandomNum(lowerValue: -180, upperValue: 180)))
            }
            
            label1.text = "\(score1!)"
            label2.text = "\(score2!)"
        }
        
        func hasWinner (paddle1: SKShapeNode, paddle2: SKShapeNode, ball: SKShapeNode, view: SKScene){
            if self.score1 == self.goal {
                self.winnerLabel.text = "You WON!"
                self.winnerLabel.isHidden = false
                self.stopGame(winner: paddle1, ball: ball, view: view)
            } else if score2 == self.goal {
                self.winnerLabel.text = "Phone won..."
                self.winnerLabel.isHidden = false
                self.stopGame(winner: paddle2, ball: ball, view: view)
            }
            
            if self.score1 == 1 || self.score2 == 1 {
                self.winnerLabel.isHidden = true
            }
        }
        
        func stopGame(winner: SKShapeNode, ball: SKShapeNode, view: SKScene) {
            self.score1 = 0
            self.score2 = 0
            label1.text = "\(score1!)"
            label2.text = "\(score2!)"
            //winner = nil
            ball.position = CGPoint(x: view.size.width/2,y: view.size.height/2)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ball.physicsBody?.applyImpulse(CGVector(dx:400, dy:self.getRandomNum(lowerValue: -45, upperValue: 45)))
        }
        
        //Create random number between a given range
        func getRandomNum(lowerValue:Int, upperValue:Int) -> Int{
            return Int(arc4random_uniform(UInt32(upperValue - lowerValue + 1))) +   lowerValue
        }

    }
    
    class ShapeFactory {
        
        private let ball: SKShapeNode
        
        init(view: SKScene, shape: ballType) {
            
            switch shape {
            case .smallCircle:
                self.ball = SmallCircle(view: view).smallCircle
            case .bigCircle:
                self.ball = BigCircle(view: view).bigCircle
            case .square:
                self.ball = Square(view: view).square
            }
            self.ball.physicsBody?.affectedByGravity = false
            self.ball.physicsBody?.mass = CGFloat(1)
            self.ball.physicsBody?.friction = CGFloat(0)
            self.ball.physicsBody?.restitution = CGFloat(1.025)
            self.ball.physicsBody?.linearDamping = CGFloat(0)
            self.ball.physicsBody?.angularDamping = CGFloat(0)
            self.ball.physicsBody!.categoryBitMask = PhysicsCategory.Ball
            self.ball.physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Paddle
            self.ball.physicsBody?.usesPreciseCollisionDetection = true
            
            self.ball.position = CGPoint(x: view.size.width/2,y: view.size.height/2)
        }
        
        func makeShape() -> SKShapeNode {
            return self.ball
        }
        
        class SmallCircle: SKShapeNode {
            
            public var smallCircle: SKShapeNode
            
            init(view: SKScene) {
                smallCircle = SKShapeNode(circleOfRadius: 10)
                smallCircle.fillColor = UIColor.green
                smallCircle.physicsBody = SKPhysicsBody(circleOfRadius: smallCircle.frame.height/50)
                smallCircle.name = "Smallball"
                super.init()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        class BigCircle: SKShapeNode {
            
            public var bigCircle: SKShapeNode
            
            init(view: SKScene) {
                bigCircle = SKShapeNode(circleOfRadius: 40)
                bigCircle.fillColor = UIColor.blue
                bigCircle.physicsBody = SKPhysicsBody(circleOfRadius: bigCircle.frame.height/5)
                bigCircle.name = "Bigball"
                super.init()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        class Square: SKShapeNode {
            
            public var square: SKShapeNode
            
            init(view: SKScene) {
                square = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
                square.fillColor = UIColor.yellow
                square.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 35, height: 35))
                square.name = "Square"
                super.init()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        
    }
    
    class Paddle: SKShapeNode {
        
        private var paddlePhysicsbody: SKTexture!
        public var pp: paddlePosition
        public var player: Bool

        init(width: Double, height: Double, player: Bool, paddlePosition: paddlePosition, view: SKScene) {
            self.pp = paddlePosition
            self.player = player
            super.init()
            self.setPaddleBody(width: width, height: height, view: view)
            self.setPaddleSettings()
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setPaddleBody(width: Double, height: Double, view:SKScene){
            switch self.pp {
            case .bottom:
                self.paddlePhysicsbody = SKTexture(imageNamed: "paddle_physicsbody2.png")
                self.position = CGPoint(x: 30, y: view.size.height/2)
            case .top:
                self.paddlePhysicsbody = SKTexture(imageNamed: "paddle_physicsbody.png")
                self.position = CGPoint(x: view.size.width-30, y: view.size.height/2)
            }
            
            //Set physicsbody
            let paddleNode = SKSpriteNode(texture: paddlePhysicsbody)
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width/2, y: -height/2), size: CGSize(width: width, height: height)), transform: nil)
            self.physicsBody = SKPhysicsBody(texture:paddlePhysicsbody,size: CGSize(width: paddleNode.size.width-10, height: paddleNode.size.height+20))
        }
        
        func setPaddleSettings(){
            //Physics settings
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.isDynamic = false
            self.physicsBody?.friction = CGFloat(0)
            self.physicsBody?.restitution = CGFloat(0)
            self.physicsBody?.angularDamping = CGFloat(0)
            self.physicsBody?.linearDamping = CGFloat(0)
            
            switch player {
            case true:
                self.fillColor = UIColor.white
            case false:
                self.fillColor = UIColor.red
            }
        }
        
        //Enemy AI for hitting the ball
        func followBall(ball: SKShapeNode, view:SKScene) {
            
            //Calculating delta between ball and paddle.
            //Moves paddle with a given speed to match y-position to ball
            let xPos = view.frame.width/2
            let maxSpeed: CGFloat = 2.5
            let delta = ball.position.y - self.position.y
            
            if ball.position.x > xPos {
                if delta > 0{
                    self.position.y += min(maxSpeed, delta)
                    
                } else if delta < 0 {
                    self.position.y += max(-maxSpeed, delta)
                }
            }
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
