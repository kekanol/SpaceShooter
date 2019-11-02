//
//  MAIN_MENU.swift
//  kakashka strelyat
//
//  Created by Константин Емельянов on 02/10/2019.
//  Copyright © 2019 Константин Емельянов. All rights reserved.
//

import SpriteKit
import GameplayKit


class MAIN_MENU: SKScene {
      
      var MusicIsOn: Bool = false
      var starfield: SKEmitterNode!
      var Music: SKAudioNode!
      var newGameBtnNode: SKSpriteNode!
      var levelBtnNode: SKLabelNode!
      public static var levelLabelNode: SKLabelNode!
      var musicLabel: SKLabelNode!
      var soundLabel: SKLabelNode!
      var mainLabel: SKLabelNode!
      var soundbutt: SKSpriteNode!
      var musicbutt: SKSpriteNode!
      var changebutt: SKSpriteNode!
      
      
      override func didMove(to view: SKView) {
            mainLabel = self.childNode(withName: "Space Shooter") as? SKLabelNode
            mainLabel.fontSize = (UIScreen.main.bounds.size.width - 50)/3.75
            mainLabel.position.x = 375            
            starfield = self.childNode(withName: "starfield") as? SKEmitterNode
            starfield.advanceSimulationTime(10)
            
            newGameBtnNode = self.childNode(withName: "NewGameButt") as? SKSpriteNode
            newGameBtnNode.texture = SKTexture(imageNamed: "bound")
            soundbutt = self.childNode(withName: "SOUNDbtn") as? SKSpriteNode
            soundbutt.texture = SKTexture(imageNamed: "bound")
            musicbutt = self.childNode(withName: "MUSICbtn") as? SKSpriteNode
            musicbutt.texture = SKTexture(imageNamed: "bound")
            changebutt = self.childNode(withName: "LEVELBtn") as? SKSpriteNode
            changebutt.texture = SKTexture(imageNamed: "bound")
            
                        
            MAIN_MENU.levelLabelNode = self.childNode(withName: "levelLabel") as? SKLabelNode
            
            musicLabel = self.childNode(withName: "musicLabel") as? SKLabelNode
            soundLabel = self.childNode(withName: "soundLabel") as? SKLabelNode
            levelBtnNode = self.childNode(withName: "LevelButt") as? SKLabelNode
            
            
            let userlvel = UserDefaults.standard
            
            if userlvel.bool(forKey: "hard") {
                  MAIN_MENU.levelLabelNode.text = "Hard"
            } else if userlvel.bool(forKey: "medium"){
                  MAIN_MENU.levelLabelNode.text = "Medium"
            } else if userlvel.bool(forKey: "easy"){
                  MAIN_MENU.levelLabelNode.text = "Easy"
            }
            
            let usersounds = UserDefaults.standard
            if usersounds.bool(forKey: "soundN") == true {
                  soundLabel.text = "Sound: On"
            } else if usersounds.bool(forKey: "soundN") == false {
                 soundLabel.text = "Sound: Off" 
            }
            
            if soundLabel.text == "Sound: On" {
                  UserDefaults.standard.set(true, forKey: "soundN")
            }
            if soundLabel.text == "Sound: Off" {
                  UserDefaults.standard.set(false, forKey: "soundN")
            }
            
            
            let usermusic = UserDefaults.standard
            if usermusic.bool(forKey: "musicN") == true {
                  musicLabel.text = "Music: On"
            } else if usermusic.bool(forKey: "musicN") == false {
                 musicLabel.text = "Music: Off" 
            }
            if musicLabel.text == "Music On" {
                  UserDefaults.standard.set(true, forKey: "musicN")
            }
            if musicLabel.text == "Music Off" {
                  UserDefaults.standard.set(false, forKey: "musicN")
            }
            
            startMusic()
      }
      
      
      func startMusic() {
            if UserDefaults.standard.bool(forKey: "musicN") && MusicIsOn == false {
                  Music = SKAudioNode(fileNamed: "146318.mp3") as SKAudioNode
                  Music.autoplayLooped = true
                  self.addChild(Music)
                  Music.run(SKAction.changeVolume(to: Float(0.3), duration: 0))
            }
      }
      
      func stopMusic() {
            if UserDefaults.standard.bool(forKey: "musicN") == false {
                  Music.run(SKAction.stop())
            }
      }
      
      
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            
            if let location =  touch?.location(in: self){
                  let nodesArr = self.nodes(at: location)
                  
                  if nodesArr.first?.name == "NewGameButt"{
                        let transition = SKTransition.fade(withDuration: 0.9)
                        let gamescene = GameScene(size: UIScreen.main.bounds.size)
                        self.view?.presentScene(gamescene, transition: transition )
                  } else if nodesArr.first?.name == "LEVELBtn" {
                        changeLevel() 
                  } else if nodesArr.first?.name == "MUSICbtn" {
                        ChangeMusic()
                  } else if nodesArr.first?.name == "SOUNDbtn" {
                        ChangeSounds()
                  }
                  
                  
            }
      }
      
      
      func changeLevel() {
            let userlevel = UserDefaults.standard
            
            if MAIN_MENU.levelLabelNode.text == "Easy" {
                  MAIN_MENU.levelLabelNode.text = "Medium"
                  userlevel.set(true, forKey: "medium")
                  userlevel.set(false, forKey: "easy")
                  
            } else if MAIN_MENU.levelLabelNode.text == "Medium"{
                  MAIN_MENU.levelLabelNode.text = "Hard"
                  userlevel.set(true, forKey: "hard")
                  userlevel.set(false, forKey: "medium")
            } else if MAIN_MENU.levelLabelNode.text == "Hard"{
                  MAIN_MENU.levelLabelNode.text = "Easy"
                  userlevel.set(true, forKey: "easy")
                  userlevel.set(false, forKey: "hard")
            } 
            
            userlevel.synchronize()
      }
      
      func ChangeMusic() {
            let userlevel = UserDefaults.standard
            
            if musicLabel.text == "Music: On" {
                  musicLabel.text = "Music: Off"
                  userlevel.set(false, forKey: "musicN")
                  stopMusic()
            } else if musicLabel.text == "Music: Off" {
                  musicLabel.text = "Music: On"
                  userlevel.set(true, forKey: "musicN")
                  startMusic()
            } 
            userlevel.synchronize()
      }
      
      func ChangeSounds(){
            let userlevel = UserDefaults.standard
            
            if soundLabel.text == "Sound: On" {
                  soundLabel.text = "Sound: Off"
                  userlevel.set(false, forKey: "soundN")
            } else if soundLabel.text == "Sound: Off" {
                  soundLabel.text = "Sound: On"
                  userlevel.set(true, forKey: "soundN")
            } 
            userlevel.synchronize()
      }
      
}
