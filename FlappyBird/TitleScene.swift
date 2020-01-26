//
//  TtleScene.swift
//  FlappyBird
//
//  Created by 小野寺祥吾 on 2020/01/22.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene ,SKPhysicsContactDelegate{
    
    let background = SKSpriteNode(imageNamed: "background.jpg")
    let startBird = SKSpriteNode(imageNamed:"startBird.png")
    var scoreLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        //スコア
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.orange
        scoreLabelNode.fontSize = 30
        scoreLabelNode.position = CGPoint(x:self.frame.size.width / 2 ,y:self.frame.size.height - 300)
        scoreLabelNode.zPosition = 100 //一番手前に表示
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center //左詰め
        scoreLabelNode.text = "ことりをタップ！"
        self.addChild(scoreLabelNode)
        
        background.size = self.size
        background.position = CGPoint(x:frame.size.width / 2,y:frame.size.height / 2 )
        background.zPosition = 0
        addChild(background)
        
        
        startBird.position = CGPoint(x:frame.size.width / 2 + 20 ,y:frame.size.height / 2 )
        startBird.size = CGSize(width: startBird.size.width*5.5, height: startBird.size.height*5.5)
        startBird.zPosition = 10
        addChild(startBird)
        
        
        
    }
    
    //画面タッチ開始時の呼び出しメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch :AnyObject in touches {
            //タッチした位置を検出
            let pointOfTouch = touch.location(in :self)
            //タッチした位置がstartBirdの位置に含まれるかチェックする
            if startBird.contains(pointOfTouch){
                let scene = GameScene(size:self.size)
                view?.presentScene(scene)
            }
        }
        
    }
}
