//
//  ViewController.swift
//  FlappyBird
//
//  Created by 小野寺祥吾 on 2020/01/18.
//  Copyright © 2020 syogo-user. All rights reserved.
//


import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //SKViewの型を変換する
        let skView = self.view as! SKView
        
        //FPSを表示する
        skView.showsFPS = true
        
        //ノードの数を表示する
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        //let scene = GameScene(size:skView.frame.size)
        let scene = TitleScene(size:skView.frame.size)
        //scene.scaleMode = .aspectFit    
        //ビューにシーンを表示する
        skView.presentScene(scene)

    

    }
    //ステータスバーを消す
    override var prefersStatusBarHidden : Bool{
        get {
            return true
        }
    }
}

