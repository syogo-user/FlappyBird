//
//  ResultScene.swift
//  FlappyBird
//
//  Created by 小野寺祥吾 on 2020/01/23.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import SpriteKit

class ResultScene: SKScene {
    let restartLabel = SKLabelNode(fontNamed: "Verdana")
    
    override func didMove(to view: SKView){
        let backgroundResult = SKSpriteNode(imageNamed: "watermark.jpg")
        backgroundResult.size = self.size
        backgroundResult.position = CGPoint(x:frame.size.width / 2,y:frame.size.height / 2 )
        backgroundResult.zPosition = 0
        addChild(backgroundResult)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Verdana")
        gameOverLabel.fontSize = 40
        gameOverLabel.text = "GAMEOVER"
        gameOverLabel.position = CGPoint(x:self.frame.size.width / 2,y:self.frame.size.height / 3 * 2 )
        gameOverLabel.zPosition = 100
        gameOverLabel.fontColor = SKColor.black
        self.addChild(gameOverLabel)

        //resultBird表示
        let resultBird = SKSpriteNode(imageNamed:"resultBird.png")
        resultBird.position = CGPoint(x:frame.size.width / 2  ,y:frame.size.height / 2 )
        resultBird.size = CGSize(width: resultBird.size.width*4.5, height: resultBird.size.height*4.5)
        resultBird.zPosition = 50
        addChild(resultBird)
        
        
        restartLabel.fontSize = 40
        restartLabel.text = "もう1回"
        restartLabel.position = CGPoint(x:frame.size.width / 2,y:frame.size.height / 4 * 1  )
        restartLabel.zPosition = 100
        restartLabel.fontColor = SKColor.black
        self.addChild(restartLabel)
        
    }
    
    //画面タッチ開始時の呼び出しメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch :AnyObject in touches {
            //タッチした位置を検出
            let pointOfTouch = touch.location(in :self)
            //タッチした位置がstartBirdの位置に含まれるかチェックする
            if restartLabel.contains(pointOfTouch){
                let scene = GameScene(size:self.size)
                view?.presentScene(scene)
            }
        }
    }
}
