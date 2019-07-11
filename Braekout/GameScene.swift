//
//  GameScene.swift
//  Braekout
//
//  Created by SESP Walkup on 7/11/19.
//  Copyright © 2019 Alexander Yu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var brick = SKSpriteNode()
    var loseZone = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        createBackground()
        makeBall()
        makePaddle()
        makeBricks()
        makeLoseZone()
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) // add ball object to the view
    }
    
    func makePaddle() {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick(x: Int, y: Int, color: UIColor, index: Int) {
        brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y)
        brick.name = "brick\(index)"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.color = color
        addChild(brick)
    }
    
    func makeBricks() {
        for i in 0..<7 {
            makeBrick(x: 55 * (i) + Int(frame.minX) + 40, y: Int(frame.maxY) - 50, color: UIColor.green, index: i)
            bricks.append(brick)
        }
        for i in 0..<7 {
            makeBrick(x: 55 * (i) + Int(frame.minX) + 40, y: Int(frame.maxY) - 100, color: UIColor.green, index: i + 7)
            bricks.append(brick)
        }
        for i in 0..<7 {
            makeBrick(x: 55 * (i) + Int(frame.minX) + 40, y: Int(frame.maxY) - 150, color: UIColor.green, index: i + 14)
            bricks.append(brick)
        }
        print(bricks)
    }
    
    func makeLoseZone() {
        loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    override func update(_ currentTime: TimeInterval) {
        var xSpeed = ball.physicsBody!.velocity.dx
        xSpeed = sqrt(xSpeed * xSpeed)
        if xSpeed < 10 {
            ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 0))
        }
        var ySpeed = ball.physicsBody!.velocity.dy
        ySpeed = sqrt(ySpeed * ySpeed)
        if ySpeed < 10 {
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: Int.random(in: -3...3)))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        for i in 0..<21 {
            if contact.bodyA.node?.name == "brick\(i)" ||
                contact.bodyB.node?.name == "brick\(i)" {
                if bricks[i].color == (UIColor.green) {
                    bricks[i].color = .blue
                }
                else if bricks[i].color == .blue {
                    bricks[i].color = UIColor.red
                }
                else if bricks[i].color == .red {
                    bricks[i].removeFromParent()
                }
            }
            if contact.bodyA.node?.name == "loseZone" ||
                contact.bodyB.node?.name == "loseZone" {
                ball.removeFromParent()
            }
        }
        
    }
    
}
