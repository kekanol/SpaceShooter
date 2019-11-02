//
//  GameoverScene.swift
//  kakashka strelyat
//
//  Created by Константин Емельянов on 04/10/2019.
//  Copyright © 2019 Константин Емельянов. All rights reserved.
//

import SpriteKit

class GameoverScene: SKScene {
      
      var starfield: SKEmitterNode!
      
      var newGameBtnNode: SKSpriteNode!
      var MenuBtnNode: SKSpriteNode!
      static var scorelabel: SKLabelNode!
      
      var bestscoreLabel: SKLabelNode!
      var scorelabel: SKLabelNode!
      var levelLabel: SKLabelNode!
      var bestScore: Int = 0
      
      
      override func didMove(to view: SKView) {
            var dificulty: String = ""
            
            bestScore = CheckBestScore(Score: GameScene.score)
            
            if UserDefaults.standard.bool(forKey: "hard"){
                  dificulty = "HARD"
            }
            if UserDefaults.standard.bool(forKey: "medium"){
                  dificulty = "MEDIUM"
            }
            if UserDefaults.standard.bool(forKey: "easy"){
                  dificulty = "EASY"
            }
            starfield = self.childNode(withName: "starfield") as? SKEmitterNode
            starfield.advanceSimulationTime(10)
            starfield.zPosition = -1
            
            newGameBtnNode = (self.childNode(withName: "NewGameButt") as! SKSpriteNode)
            newGameBtnNode.texture = SKTexture(imageNamed: "bound")
            
            newGameBtnNode = (self.childNode(withName: "MainMenuButt") as! SKSpriteNode)
            newGameBtnNode.texture = SKTexture(imageNamed: "bound")
            
            scorelabel = self.childNode(withName: "ScoreLabel") as? SKLabelNode
            scorelabel.fontSize = (UIScreen.main.bounds.size.width - 50)/3.75
            scorelabel.text = "YOUR SCORE: \(GameScene.score)"
            if scorelabel.self.frame.width > UIScreen.main.bounds.width {
                  scorelabel.fontSize = scorelabel.fontSize * 0.8
            }
            
            levelLabel = self.childNode(withName: "LevelLabel") as? SKLabelNode
            levelLabel.fontSize = scorelabel.fontSize
            levelLabel.text = "AT \(dificulty)"
            
            
            bestscoreLabel = SKLabelNode(text: "Your Best: \(bestScore)")
            bestscoreLabel.fontName = MAIN_MENU.levelLabelNode.fontName
            bestscoreLabel.fontColor = MAIN_MENU.levelLabelNode.fontColor
            bestscoreLabel.position = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/4)
            bestscoreLabel.zRotation = 1/sqrt(2)
            bestscoreLabel.fontSize = (UIScreen.main.bounds.size.width - 150)/3.75
            self.addChild(bestscoreLabel)
                        
      }
      
      
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            
            if let location =  touch?.location(in: self){
                  let nodesArr = self.nodes(at: location)
                  
                  if nodesArr.first?.name == "NewGameButt"{
                        let transition = SKTransition.fade(withDuration: 0.9)
                        let gamescene = GameScene(size: UIScreen.main.bounds.size)
                        self.view?.presentScene(gamescene, transition: transition )
                  }
                  
                  if nodesArr.first?.name == "MainMenuButt"{
                        
                        let transition = SKTransition.fade(withDuration: 0.9)
                        let mainMenuScene = MAIN_MENU(fileNamed: "MainMenu")
                        mainMenuScene?.scaleMode = .aspectFill
                        self.view?.presentScene(mainMenuScene!, transition: transition )
                        
                  }
                  
            }
      }
      
      func CheckBestScore(Score: Int) -> Int {
            var result: Int = 0
            if UserDefaults.standard.bool(forKey: "easy"){
                  if UserDefaults.standard.integer(forKey: "EasyLevel") < Score {
                        UserDefaults.standard.set(Score, forKey: "EasyLevel")
                        UserDefaults.standard.synchronize()
                        result = UserDefaults.standard.integer(forKey: "EasyLevel")
                  } else {
                        result = UserDefaults.standard.integer(forKey: "EasyLevel")
                  }
            }
            if UserDefaults.standard.bool(forKey: "medium"){
                  if UserDefaults.standard.integer(forKey: "MedLevel") < Score {
                        UserDefaults.standard.set(Score, forKey: "MedLevel")
                        UserDefaults.standard.synchronize()
                        result = UserDefaults.standard.integer(forKey: "MedLevel")
                  } else {
                        result = UserDefaults.standard.integer(forKey: "MedLevel")
                  }
            }
            if UserDefaults.standard.bool(forKey: "hard"){
                  if UserDefaults.standard.integer(forKey: "HardLevel") < Score {
                        UserDefaults.standard.set(Score, forKey: "HardLevel")
                        UserDefaults.standard.synchronize()
                        result = UserDefaults.standard.integer(forKey: "HardLevel")
                  } else {
                        result = UserDefaults.standard.integer(forKey: "HardLevel")

                  }
            }
            return result
      }
      
      
}
