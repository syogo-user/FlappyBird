//
//  GameScene.swift
//  FlappyBird
//
//  Created by 小野寺祥吾 on 2020/01/18.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene ,SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var orangeNode:SKNode!
    
    var audioPlayer :AVAudioPlayer!
    var audioPlayerBGM:AVAudioPlayer!
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0   //0...00001
    let groundCategory: UInt32 = 1 << 1 //0...00010
    let wallCategory:UInt32 = 1 << 2    //0...00100
    let scoreCategory:UInt32 = 1 << 3   //0...01000
    let orangeCategory:UInt32 = 1 << 4  //0...10000
    
    //スコア用
    var score = 0
    var item = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    var itemScoreLabelNode:SKLabelNode!

    var activityIndicator: UIActivityIndicatorView!
    //setupメソッドが呼び出されたかどうか(初期値は呼び出されていないfalse)
    var setupFlg :Bool = false
    
    //SKView上にシーンが表示される時に呼ばれるメソッド
    override func didMove(to view: SKView){
        //重力を設定
        physicsWorld.gravity = CGVector(dx:0,dy:-4)
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(red:0.15,green:0.75,blue:0.90,alpha:1)

        //サウンド
        let soundFilePath = Bundle.main.path(forResource: "orangeGet", ofType: "mp3")!
        let sound:URL = URL(fileURLWithPath: soundFilePath)
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: sound,fileTypeHint: nil)
        }catch {
            print("AVAudioPlayerインスタンス作成でエラー")
        }
     
        //再生準備
        audioPlayer.prepareToPlay()
        //BGM再生
        bgmStart()
        
        //スクロールスするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //オレンジノード
        orangeNode = SKNode()
        scrollNode.addChild(orangeNode)
        
        // ActivityIndicatorを作成＆中央に配置
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: self.size.width, height: 100)
        activityIndicator.center = view.center
        // クルクルをストップした時に非表示する
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .purple

        //Viewに追加
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        

        DispatchQueue.global(qos: .default).async {
            //非同期処理　1秒 BGMの読み込み時間を稼ぐため
            Thread.sleep(forTimeInterval:  1)


            DispatchQueue.main.async {
                //メインスレッド
                // アニメーション終了
                self.activityIndicator.stopAnimating()
                // 1秒後に実行したい処理
                //各種スプライトを生成する処理をメソッドに分割
                self.setupGround()
                self.setupClound()
                self.setupWall()
                self.setupBird()
                self.setupOrange()
                self.setupScoreLabel()

                self.setupFlg = true
            }

        }

    }
    

    func bgmStart(){
        let soundBGMFilePath = Bundle.main.path(forResource: "bgm_2", ofType: "mp3")!
        let soundBGM:URL = URL(fileURLWithPath: soundBGMFilePath)
        do{
            audioPlayerBGM = try AVAudioPlayer(contentsOf: soundBGM,fileTypeHint: nil)
        }catch {
            print("AVAudioPlayerBGMインスタンス作成でエラー")
        }
        //BGM再生
        audioPlayerBGM.prepareToPlay()
        audioPlayerBGM.numberOfLoops = -1//リピート設定
        audioPlayerBGM.play()
    }
    
    func setupScoreLabel() {
        score = 0
        item = 0
        
        //スコア
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x:10,y:self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 //一番手前に表示
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left //左詰め
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        //ベストスコア
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x:10,y:self.frame.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        //アイテム
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x:10,y:self.frame.height - 120)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "ITEM:\(item)"
        self.addChild(itemScoreLabelNode)
        
    }
    
    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if setupFlg {
            //setup完了後
            if scrollNode.speed > 0 {
                //鳥の速度をゼロにする
                bird.physicsBody?.velocity = CGVector.zero
                //鳥に縦方向の力を与える
                bird.physicsBody?.applyImpulse(CGVector(dx:0,dy:15))

            } else if bird.speed == 0 {
                //restart()
                //フェードアウト
                let transition = SKTransition.fade(withDuration: 2.0)
                //Result画面に遷移する
                let result = ResultScene(size:self.size)
                self.view?.presentScene(result,transition: transition)
            }
        }
    }
    
    //アイテム
    func setupOrange(){
        //オレンジ画像を読み込む
        let orangeTexture = SKTexture(imageNamed:"orange")
        orangeTexture.filteringMode = .linear
        

        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + orangeTexture.size().width + 100)
        //画面外まで移動するアクションを作成
        let moveOrange = SKAction.moveBy(x:-movingDistance ,y:0,duration: 5)
        //自身を取り除くアクションを作成
        let removeOrange = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するアクションを作成
        let orangeAnimation = SKAction.sequence([moveOrange,removeOrange])
        

        
        
        //オレンジを生成するアクションを生成
        let createOrangeAnimation = SKAction.run({
            //ノードを作成
            let orange = SKNode()
            orange.position = CGPoint(x:self.frame.size.width + orangeTexture.size().width / 2 + 100,y:0)
            orange.zPosition = 100
            
             //スプライトを作成
            let orangeSprite = SKSpriteNode(texture: orangeTexture)
            let random_y = CGFloat.random(in:200..<self.frame.size.height - 200)
            //let random_x = CGFloat.random(in:100..<self.frame.size.width - 30)
            
            orangeSprite.position = CGPoint(x:0,y:random_y)
            orangeSprite.zPosition = 100
            //物理演算を設定
            orangeSprite.physicsBody = SKPhysicsBody(circleOfRadius: orangeSprite.size.height / 2)
            //衝突の時に動かないように設定する
            orangeSprite.physicsBody?.isDynamic = false
            
            //衝突のカテゴリー設定
            orangeSprite.physicsBody?.categoryBitMask = self.orangeCategory
            
            orange.addChild(orangeSprite)
            orange.run(orangeAnimation)
            
            self.orangeNode.addChild(orange)
        })
     
        //次のオレンジ作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //オレンジを作成->時間待ち->オレンジを作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createOrangeAnimation,waitAnimation]))
        
        orangeNode.run(repeatForeverAnimation)   
        
    }

    func setupGround() {
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        // スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x:-groundTexture.size().width,y:0,duration:5)

        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x:groundTexture.size().width,y:0,duration:0)

        //左にスクロール->元の位置->左にスクロール　と無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))


        //groundのスプライトを配置する
        
        for i in 0..<needNumber {
            //テクスチャを指定してスプライトを作成する
            let sprite = SKSpriteNode(texture: groundTexture)

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)

            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupClound() {
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed:"cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x:-cloudTexture.size().width,y:0,duration: 20)
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x:cloudTexture.size().width,y:0,duration: 0)
        
        //左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
        
        
        //スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            
            sprite.zPosition = -100 //一番後ろになるように
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(x:cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),y:self.size.height - cloudTexture.size().height / 2 )
            //スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
        
    }
    
    func setupWall(){
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x:-movingDistance,y:0,duration: 4)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成
        let wallAnimatio = SKAction.sequence([moveWall,removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の長さを鳥のサイズの３倍とする
        let slit_length = birdSize.height * 3 + 50
        
        //隙間位置の條辺の振れ幅を鳥のサイズの３倍とする
        let random_y_range = birdSize.height * 3
        
        //下の壁のY軸下限位置（中央から下方向の最大振れ幅で下の壁を表示する位置）を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            //壁関連のノードを乗せるノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x:self.frame.size.width + wallTexture.size().width / 2,y:0)
            wall.zPosition = -50 //雲より手前、地面より奥
            
            //0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //Y軸の下限にランダムな値を足して、下の壁のY軸座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下限の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x:0,y:under_wall_y)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上側の壁を作成
            let upper  = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x:0,y:under_wall_y + wallTexture.size().height + slit_length)
            
               
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            

                       
            //スコア用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x:upper.size.width + birdSize.width / 2,y:self.frame.height / 2 )
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:upper.size.width,height:self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            wall.addChild(scoreNode)
            
            wall.run(wallAnimatio)
            
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間待ち->壁を作成 を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setupBird(){
        //鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //２種類のテスクチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with:[birdTextureA,birdTextureB],timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x:self.frame.size.width * 0.2 ,y:self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2 -  1.5  )//微調整で1.5引いてる
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | orangeCategory
        
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)


    }
    //SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory ||
            (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "BEST Score:\(bestScore)"
                userDefaults.set(bestScore,forKey: "BEST")
                userDefaults.synchronize()
            }
        } else if (contact.bodyA.categoryBitMask & orangeCategory) != orangeCategory &&
        (contact.bodyB.categoryBitMask & orangeCategory) != orangeCategory {
            //壁か地面と衝突した
            print("GameOver")
            
            //スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll,completion:{
                self.bird.speed = 0
            })
            
            //BGMを停止
            audioPlayerBGM.stop()
        }
        if (contact.bodyA.categoryBitMask & orangeCategory) == orangeCategory ||
            (contact.bodyB.categoryBitMask & orangeCategory) == orangeCategory{
            //オレンジと衝突した
            print("オレンジと衝突")
            //パーティクルを作成する
            let particle = SKEmitterNode(fileNamed: "ParticleScene.sks")
            particle?.zPosition = 10

            
            //オレンジを消す
            if (contact.bodyA.categoryBitMask & orangeCategory) == orangeCategory {
                
               contact.bodyA.node?.removeFromParent()
                //接触座標にパーティクルを出す
                particle!.position = CGPoint(x:contact.contactPoint.x,y:contact.contactPoint.y)

            }else if (contact.bodyB.categoryBitMask & orangeCategory) == orangeCategory {
                
                contact.bodyB.node?.removeFromParent()
                //接触座標にパーティクルを出す
                particle!.position = CGPoint(x:contact.contactPoint.x,y:contact.contactPoint.y)
            }
            //0.2秒後に消える
            let action1 = SKAction.wait(forDuration: 0.2)
            let action2 = SKAction.removeFromParent()
            let actionAll = SKAction.sequence([action1,action2])
            
            //パーティクルをシーンに追加する
            self.addChild(particle!)
            //パーティクルを消す
            particle!.run(actionAll)
            
            //衝突した音を出す
            audioPlayer.currentTime = 0
            audioPlayer.play()
            
            //アイテムを一つ増やす
            item += 1
            itemScoreLabelNode.text = "ITEM:\(item)"
        }
    }
    
    
    
    func restart() {
        score = 0
        item = 0
        scoreLabelNode.text = "Score:\(score)"
        itemScoreLabelNode.text = "ITEM:\(item)"
        
        
        bird.position = CGPoint(x:self.frame.size.width * 0.2 ,y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
        
        audioPlayerBGM.play()
    }
}

