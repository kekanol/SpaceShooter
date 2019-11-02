//
//  GameScene.swift
//  kakashka strelyat
//
//  Created by Константин Емельянов on 01/10/2019.
//  Copyright © 2019 Константин Емельянов. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
      
      
      var starfield: SKEmitterNode!
      var player: SKSpriteNode!
      static var scorelabel: SKLabelNode!
      var pauseBtn: SKSpriteNode!
      var alienlayer: SKNode!
      var pauselayer: SKNode!
      var Music: SKAudioNode!
      var dificulty = 0.9
      
      public static var score: Int = 0 {
            didSet{
                  scorelabel.text = "Score: \(score)"
            }
      }
      
      var GameTimer: Timer!
      var Aliens = ["alien", "alien2", "alien3"] 
      
      let spaceshipcategory: UInt32 = 0x1 << 2 
      let aliencategory: UInt32 = 0x1 << 1
      let bulletcategory: UInt32 = 0x1 << 0
      let alienbulletcategory: UInt32 = 0x1 << 0
      
      let moutionManager = CMMotionManager()
      var xposition: CGFloat = 0
      var count = 0     
      var GameIsPaused: Bool = false
      
      var SoundSimbol: SKSpriteNode!
      var MusicSimbol: SKSpriteNode!
      var Rectangle: SKSpriteNode!
      
      
      override func didMove(to view: SKView) {
            startMusic()
            
            starfield = SKEmitterNode(fileNamed: "Starfield")
            starfield.position = CGPoint(x: 0, y: 1472)
            starfield.advanceSimulationTime(20)
            starfield.zPosition = -1
            self.addChild(starfield)
            
            
            player = SKSpriteNode(imageNamed: "shuttle")
            player.position = CGPoint(x: UIScreen.main.bounds.size.width/2, y: 110) 
            
            player.physicsBody = SKPhysicsBody.init(rectangleOf: player.size)      
            player.physicsBody?.categoryBitMask = spaceshipcategory 
            player.physicsBody?.contactTestBitMask = aliencategory
            player.physicsBody?.collisionBitMask = 0
            
            player.zPosition = 1
            
            self.addChild(player)
            prebuilt()
            prebuilt()
            prebuilt()
            
            self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            self.physicsWorld.contactDelegate = self
            
            GameScene.scorelabel = SKLabelNode(text: "Score: 0")
            GameScene.scorelabel.fontName = MAIN_MENU.levelLabelNode.fontName
            GameScene.scorelabel.fontSize = 43
            GameScene.scorelabel.fontColor = MAIN_MENU.levelLabelNode.fontColor
            GameScene.scorelabel.position = CGPoint(x: UIScreen.main.bounds.size.width - 100, y: UIScreen.main.bounds.height - 70)
            GameScene.score = 0
            GameScene.scorelabel.zPosition = 2
            
            
            self.addChild(GameScene.scorelabel)
            
            pauseBtn = SKSpriteNode(imageNamed: "pause")
            pauseBtn.size = CGSize(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
            pauseBtn.position = CGPoint(x: 50, y: GameScene.scorelabel.position.y + 20)
            pauseBtn.color = MAIN_MENU.levelLabelNode.fontColor!
            pauseBtn.zPosition = 3
            pauseBtn.name = "pause"
            
            self.addChild(pauseBtn)
            
            if UserDefaults.standard.bool(forKey: "hard") == true {
                  dificulty = 0.3
            }
            if UserDefaults.standard.bool(forKey: "medium") == true {
                  dificulty = 0.6
            }
            if UserDefaults.standard.bool(forKey: "easy") == true {
                  dificulty = 0.9
            }
            
            
            alienlayer = SKNode()
            alienlayer.zPosition = 1
            self.addChild(alienlayer)
            
            moutionManager.accelerometerUpdateInterval = 0.2
            moutionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in 
                  if  let acselldata = data {
                        let acseleration = acselldata.acceleration
                        self.xposition = CGFloat(CGFloat(acseleration.x * 0.75) + CGFloat(self.xposition * 0.25))
                        
                  } 
            }
            
            GameTimer = Timer.scheduledTimer(timeInterval: dificulty, target: self, selector: #selector(AddAlien), userInfo: nil, repeats: true)
            
      }
      
      
      override func didSimulatePhysics() {
            player.position.x += xposition * 50
            
            if player.position.x < 0 {
                  player.position = CGPoint(x: UIScreen.main.bounds.width, y: player.position.y)
                  
            }
            else if player.position.x > UIScreen.main.bounds.width {
                  player.position = CGPoint(x: 0, y: player.position.y)
            }
      }
      
      
      @objc func AddAlien(){
            if GameIsPaused == false {
                  Aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: Aliens) as! [String]
                  
                  let alien = SKSpriteNode(imageNamed: Aliens[0])
                  
                  let randompos = GKRandomDistribution(lowestValue:  Int(alien.size.width), highestValue: Int(UIScreen.main.bounds.width - alien.size.width))
                  let randomposit = CGFloat(randompos.nextInt())
                  alien.position = CGPoint(x: randomposit, y: CGFloat(UIScreen.main.bounds.height + alien.size.height + 20))
                  
                  alien.physicsBody = SKPhysicsBody.init(rectangleOf: alien.size)
                  alien.physicsBody?.isDynamic = true
                  
                  alien.physicsBody?.categoryBitMask = aliencategory
                  alien.physicsBody?.contactTestBitMask = spaceshipcategory
                  alien.physicsBody?.collisionBitMask = 0
                  alien.physicsBody?.usesPreciseCollisionDetection = true                  
                  
                  alienlayer.addChild(alien)
                  
                  actinons(alien: alien)
            }
      }
      
      
      func actinons(alien: SKSpriteNode) {
            let randompos = GKRandomDistribution(lowestValue:  Int(UIScreen.main.bounds.height/2), highestValue: Int(UIScreen.main.bounds.height * 0.8))
            
            let split = CGFloat(randompos.nextInt())
            
            let speed = Double(Double(UIScreen.main.bounds.height + alien.size.height - player.position.y + 5) / 7.5)
            
            let firstAnimationDuration:TimeInterval = Double(UIScreen.main.bounds.height + alien.size.height - split) / speed
            let secondAnimationDuration: TimeInterval = Double(split - player.position.y + 5) / speed 
            
            let firsmoveAction = SKAction.move(to: CGPoint(x: alien.position.x, y: split), duration: firstAnimationDuration)
            let secondmoveAction = SKAction.move(to: CGPoint(x: alien.position.x, y: CGFloat(player.position.y - 5)), duration: secondAnimationDuration) 
            let endGame = endAction(alien: alien)
            let shot = shootingAction(alien: alien)
            
            var actions = [SKAction]()
            actions.append(firsmoveAction)
            actions.append(shot)
            actions.append(secondmoveAction)
            actions.append(endGame)
            
            
            alien.run(SKAction.sequence(actions))
            
      }
      
      
      func shootingAction( alien: SKSpriteNode) -> SKAction {
            return SKAction.run {
                  if alien.size == SKSpriteNode(imageNamed: "alien2").size {
                        self.alienShooting(alien: alien)
                  }
                  
            }
      }
      
      
      func endAction(alien: SKSpriteNode) -> SKAction {
            
            return SKAction.run { 
                  
                  if alien.position.y == self.player.position.y - 5 {
                        var rectangle: SKSpriteNode!
                        rectangle = SKSpriteNode(imageNamed: "rectangle2")
                        rectangle.size = CGSize(width: UIScreen.main.bounds.width, height: 5)
                        rectangle.position = CGPoint(x: UIScreen.main.bounds.width/2, y: alien.position.y - 15)
                        rectangle.zPosition = 5
                        rectangle.alpha = 1
                        self.addChild(rectangle)
                        self.alienlayer.isPaused = true
                        self.starfield.isPaused = true
                        self.physicsWorld.speed = 0
                        SKAction.wait(forDuration: 1)
                        self.endGame()
                  }
            }
            
      }
      
      
      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            let touch = touches.first
            if let location =  touch?.location(in: self){
                  let nodesArr = self.nodes(at: location)
                  
                  if nodesArr.first?.name == "pause"{
                        if GameIsPaused == false {
                              PauseTheGame()
                        } 
                  }
                  
            }
            if GameIsPaused == false {
                  Shooting()
            }
      }
      
      
      func Shooting() {
 
            if UserDefaults.standard.bool(forKey: "soundN") == true {
                  self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
                  self.run(SKAction.changeMass(to: Float(0.3), duration: 0))
            }
            let bullet = SKSpriteNode(imageNamed: "torpedo")
            bullet.position = player.position
            bullet.position.y = bullet.position.y + 5
            
            bullet.physicsBody = SKPhysicsBody.init(circleOfRadius: bullet.size.width/2)
            bullet.physicsBody?.isDynamic = true
            
            bullet.physicsBody?.categoryBitMask = bulletcategory 
            bullet.physicsBody?.contactTestBitMask = aliencategory
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            
            alienlayer.addChild(bullet)
            
            let animationDuration:TimeInterval = 0.5
            
            var actions = [SKAction]()
            actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: CGFloat(UIScreen.main.bounds.height + bullet.size.height + 20) ), duration: animationDuration))
            actions.append(SKAction.removeFromParent())
            bullet.run(SKAction.sequence(actions))
            
      }
      
      
      func alienShooting(alien: SKSpriteNode) {
            let alienBullet = SKSpriteNode(imageNamed: "torpedo")
            alienBullet.position = alien.position
            
            alienBullet.physicsBody = SKPhysicsBody.init(circleOfRadius: alienBullet.size.width/2)
            alienBullet.physicsBody?.isDynamic = true
            
            alienBullet.physicsBody?.categoryBitMask = alienbulletcategory 
            alienBullet.physicsBody?.contactTestBitMask = spaceshipcategory
            alienBullet.physicsBody?.collisionBitMask = 0
            alienBullet.physicsBody?.usesPreciseCollisionDetection = true
            
            alienlayer.addChild(alienBullet)
            
            let animationDuration:TimeInterval = Double(alien.position.y / (UIScreen.main.bounds.height / 3.4))
            
            var actions = [SKAction]()
            actions.append(SKAction.move(to: CGPoint(x: alien.position.x, y: CGFloat(0 - alienBullet.size.height)), duration: animationDuration))
            actions.append(SKAction.removeFromParent())
            alienBullet.run(SKAction.sequence(actions))
      }
      
      
      func didBegin(_ contact: SKPhysicsContact) {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                  
                  secondBody = contact.bodyA
                  firstBody = contact.bodyB
                  
            }
            else {
                  secondBody = contact.bodyB
                  firstBody = contact.bodyA
            }
            //                  
            //            print(firstBody.node)
            //            print(secondBody.node)
            
            if (firstBody.categoryBitMask & aliencategory) != 0 &&  
                  (secondBody.categoryBitMask & bulletcategory) != 0 {
                  if let alienNode = firstBody.node {
                        
                        if let bulletNode = secondBody.node {
                              
                              if contact.bodyA.node?.frame.size.height == SKSpriteNode(imageNamed: "alien2").size.height || contact.bodyB.node?.frame.size.height == SKSpriteNode(imageNamed: "alien2").size.height {
                                    
                                    collisionElement(bulletNODE: bulletNode as! SKSpriteNode, alienNode: alienNode as! SKSpriteNode)
                                    GameScene.score += 1
                                    
                              }
                              else {
                                    collisionElement(bulletNODE: bulletNode as! SKSpriteNode, alienNode: alienNode as! SKSpriteNode)
                              }
                              count += 1
                        }
                  }
                  
            }
            
            
            if (firstBody.categoryBitMask & spaceshipcategory) != 0 && (secondBody.categoryBitMask & aliencategory) != 0 {
                  
                  if let spaceshipNode = firstBody.node {
                        if let alienNode = secondBody.node {
                              stolknoveniye_Sp_i_Al(spaceshipNode: spaceshipNode as! SKSpriteNode, alienNode: alienNode as! SKSpriteNode)
                        }
                        
                  }
            }
            
            if (firstBody.categoryBitMask & spaceshipcategory) != 0 && (secondBody.categoryBitMask & alienbulletcategory) != 0 {
                  if let spaceshipNode = firstBody.node {
                        if let alienBulletNode = secondBody.node {
                              stolknoveniye_Sp_i_Al(spaceshipNode: spaceshipNode as! SKSpriteNode, alienNode: alienBulletNode as! SKSpriteNode)
                        }
                  }
            }
            
      }
      
      
      func collisionElement(bulletNODE: SKSpriteNode, alienNode: SKSpriteNode){
            let explosion = SKEmitterNode(fileNamed: "Vzriv")
            explosion?.position = alienNode.position
            explosion?.particleScale = 0.2
            self.addChild(explosion!)
            
            if UserDefaults.standard.bool(forKey: "soundN") == true {
                  self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
                  self.run(SKAction.changeMass(to: Float(0.5), duration: 0))
            }
            bulletNODE.removeFromParent()
            alienNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 0.7)){
                  explosion?.removeFromParent()
            }
            
            GameScene.score += 1
            
            
      }
      
      
      func stolknoveniye_Sp_i_Al(spaceshipNode: SKSpriteNode, alienNode: SKSpriteNode){
            
            let explosion = SKEmitterNode(fileNamed: "Vzriv")
            explosion?.position = alienNode.position
            explosion?.particleScale = 0.2
            self.addChild(explosion!)
            
            if UserDefaults.standard.bool(forKey: "soundN") == true {
                  self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
                  self.run(SKAction.changeMass(to: Float(0.5), duration: 0))
            }
            spaceshipNode.removeFromParent()
            alienNode.removeFromParent()
            
            self.run(SKAction.wait(forDuration: 0.7)){
                  explosion?.removeFromParent()
                  if alienNode.position.y <= CGFloat(spaceshipNode.position.y + 50) {
                        self.endGame()
                        
                  }
            } 
      }
      
      
      func endGame() {
            GameIsPaused = true
            starfield.isPaused = true
            physicsWorld.speed = 0
            alienlayer.isPaused = true
            moutionManager.stopAccelerometerUpdates()
            self.xposition = 0
            let nextScene = GameoverScene(fileNamed:"GameoverScene")
            let transition = SKTransition.fade(withDuration: 1.5)  
            nextScene?.scaleMode = .aspectFill
            self.view?.presentScene(nextScene!, transition: transition)
            
      }
      
      
      func prebuilt() {
            
            let bullet = SKSpriteNode(imageNamed: "torpedo")
            bullet.position = player.position
            bullet.position.y = bullet.position.y + 5
            
            bullet.physicsBody = SKPhysicsBody.init(circleOfRadius: bullet.size.width/2)
            bullet.physicsBody?.isDynamic = true
            
            bullet.alpha = 0.0
            
            self.addChild(bullet)
            
            let animationDuration:TimeInterval = 0.5
            
            var actions = [SKAction]()
            actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: CGFloat(-20) ), duration: animationDuration))
            actions.append(SKAction.removeFromParent())
            bullet.run(SKAction.sequence(actions))
            
      }
      
      
      func gameIspaused() {
            
            
            var Continue: SKSpriteNode!
            var MainMenu: SKSpriteNode!
            var NewGame: SKSpriteNode!
            var resumeLabel: SKLabelNode!
            var mainmenuLabel: SKLabelNode!
            var newgameLabel: SKLabelNode!

            pauselayer = SKNode()
            pauselayer.alpha = 1
            pauselayer.zPosition = 3
            self.addChild(pauselayer)
            
            Rectangle = SKSpriteNode(imageNamed: "rectangle")
            Rectangle.size = CGSize(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.7)
            Rectangle.position = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            Rectangle.alpha = 0
            pauselayer.addChild(Rectangle)
            
            Continue = SKSpriteNode(imageNamed: "bound")
            Continue.size = CGSize(width: Rectangle.size.width * 0.8, height: UIScreen.main.bounds.height/10)
            Continue.position = CGPoint(x: UIScreen.main.bounds.width/2, y: Rectangle.position.y + Rectangle.size.height * 0.15)
            Continue.zPosition = 1
            Continue.name = "resume"
            pauselayer.addChild(Continue)
            
            resumeLabel = SKLabelNode(text: "Resume")
            resumeLabel.position.x = Continue.position.x
            resumeLabel.position.y = Continue.position.y - 20
            resumeLabel.fontColor = GameScene.scorelabel.fontColor
            resumeLabel.fontSize = Continue.size.height * 2 / 3
            pauselayer.addChild(resumeLabel)
            
            MainMenu = SKSpriteNode(imageNamed: "bound")
            MainMenu.size = CGSize(width: Rectangle.size.width * 0.8, height: UIScreen.main.bounds.height/10)
            MainMenu.position = CGPoint(x: UIScreen.main.bounds.width/2, y: Rectangle.position.y)
            MainMenu.zPosition = 1
            MainMenu.name = "mainmenu"
            pauselayer.addChild(MainMenu)
            
            mainmenuLabel = SKLabelNode(text: "Main Menu")
            mainmenuLabel.position.x = MainMenu.position.x
            mainmenuLabel.position.y = MainMenu.position.y - 20
            mainmenuLabel.fontColor = GameScene.scorelabel.fontColor
            mainmenuLabel.fontSize = MainMenu.size.height * 5 / 9
            pauselayer.addChild(mainmenuLabel)
            
            NewGame = SKSpriteNode(imageNamed: "bound")
            NewGame.size = CGSize(width: Rectangle.size.width * 0.8, height: UIScreen.main.bounds.height/10)
            NewGame.position = CGPoint(x: UIScreen.main.bounds.width/2, y: Rectangle.position.y - Rectangle.size.height * 0.15)
            NewGame.zPosition = 1
            NewGame.name = "newgame"
            pauselayer.addChild(NewGame)
            
            newgameLabel = SKLabelNode(text: "New Game")
            newgameLabel.position.x = NewGame.position.x
            newgameLabel.position.y = NewGame.position.y - 15
            newgameLabel.fontColor = GameScene.scorelabel.fontColor
            newgameLabel.fontSize = NewGame.size.height * 4.7 / 9
            pauselayer.addChild(newgameLabel)
            
            MusicSimboll()
            SoundSimboll()
      }
      
      
      func MusicSimboll() {
            if UserDefaults.standard.bool(forKey: "musicN"){
                  MusicSimbol = SKSpriteNode(imageNamed: "musicOn")
            }
            if !UserDefaults.standard.bool(forKey: "musicN"){
                  MusicSimbol = SKSpriteNode(imageNamed: "musicOff")
            }
            MusicSimbol.position = CGPoint(x: UIScreen.main.bounds.width/10 * 6.5, y: Rectangle.position.y - Rectangle.size.height * 0.30)
            MusicSimbol.size = CGSize(width: UIScreen.main.bounds.size.width / 8, height: UIScreen.main.bounds.size.width / 8)
            MusicSimbol.alpha = 0.9
            MusicSimbol.name = "MusicSimbol"
            pauselayer.addChild(MusicSimbol)
      }
      

      func SoundSimboll(){
            if UserDefaults.standard.bool(forKey: "soundN"){
                  SoundSimbol = SKSpriteNode(imageNamed: "suondon")
            }
            if !UserDefaults.standard.bool(forKey: "soundN"){
                  SoundSimbol = SKSpriteNode(imageNamed: "suondoff")
            }
            SoundSimbol.position = CGPoint(x: UIScreen.main.bounds.width/10 * 3.5, y: Rectangle.position.y - Rectangle.size.height * 0.30)
            SoundSimbol.size = CGSize(width: UIScreen.main.bounds.size.width / 8, height: UIScreen.main.bounds.size.width / 8)
            SoundSimbol.alpha = 0.9
            SoundSimbol.name = "SoundSimbol"
            pauselayer.addChild(SoundSimbol)
      }
      
      
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            let touch = touches.first
            if let location = touch?.location(in: self){
                  let nodesArr = self.nodes(at: location)
                  if nodesArr.first?.name == "mainmenu"{
                        let transition = SKTransition.fade(withDuration: 0.9)
                        let mainMenuScene = MAIN_MENU(fileNamed: "MainMenu")
                        mainMenuScene?.scaleMode = .aspectFill
                        self.view?.presentScene(mainMenuScene!, transition: transition )
                        
                  }
                  if nodesArr.first?.name == "resume"{
                        resume()
                  } 
                  
                  if nodesArr.first?.name == "newgame"{
                        let gameScene:GameScene = GameScene(size: self.view!.bounds.size)
                        let transition = SKTransition.fade(withDuration: 0.9)
                        gameScene.scaleMode = SKSceneScaleMode.fill
                        self.view!.presentScene(gameScene, transition: transition)
                  }
                  if nodesArr.first?.name == "SoundSimbol"{
                        if UserDefaults.standard.bool(forKey: "soundN"){
                              UserDefaults.standard.set(false, forKey: "soundN")
                              SoundSimbol.texture = SKTexture(imageNamed: "suondoff")

                        } 
                        else {
                              UserDefaults.standard.set(true, forKey: "soundN")
                              SoundSimbol.texture = SKTexture(imageNamed: "suondon")

                        }
                  }
                  
                  if nodesArr.first?.name == "MusicSimbol"{
                        if UserDefaults.standard.bool(forKey: "musicN"){
                              UserDefaults.standard.set(false, forKey: "musicN")
                              MusicSimbol.texture = SKTexture(imageNamed: "musicOff")
                              stopMusic()
                        } 
                        else {
                              UserDefaults.standard.set(true, forKey: "musicN")
                              MusicSimbol.texture = SKTexture(imageNamed: "musicOn")
                              startMusic()
                        }
                  }
            }
            
      }
      
      
      override func update(_ currentTime: TimeInterval) {
            guard !GameIsPaused else {
                  starfield.isPaused = true
                  physicsWorld.speed = 0
                  alienlayer.isPaused = true
                  moutionManager.stopAccelerometerUpdates()
                  self.xposition = 0
                  return
            }
      }
      
      
      public func PauseTheGame() {
            
            GameIsPaused = true
            gameIspaused()
            starfield.isPaused = true
            physicsWorld.speed = 0
            alienlayer.isPaused = true
            moutionManager.stopAccelerometerUpdates()
            self.xposition = 0
      }
      
      
      func resume()  {
            GameIsPaused = false
            starfield.isPaused = false
            physicsWorld.speed = 1
            alienlayer.isPaused = false
            moutionManager.startAccelerometerUpdates()
            pauselayer.removeFromParent()
            moutionManager.accelerometerUpdateInterval = 0.2
            moutionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in 
                  if  let acselldata = data {
                        let acseleration = acselldata.acceleration
                        self.xposition = CGFloat(CGFloat(acseleration.x * 0.75) + CGFloat(self.xposition * 0.25))
                        
                  } 
            }
      }
      
      
      func startMusic() {
            if UserDefaults.standard.bool(forKey: "musicN") {
                  Music = SKAudioNode(fileNamed: "238726.mp3") as SKAudioNode
                  Music.autoplayLooped = true
                  self.addChild(Music)
            }
      }
      
      
      func stopMusic() {
                  Music.run(SKAction.stop())
      }
      
      
}
