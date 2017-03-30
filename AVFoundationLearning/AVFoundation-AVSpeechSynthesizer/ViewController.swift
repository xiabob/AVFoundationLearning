//
//  ViewController.swift
//  AVFoundation-AVSpeechSynthesizer
//
//  Created by xiabob on 17/3/27.
//  Copyright © 2017年 xiabob. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    fileprivate lazy var synthesizer: AVSpeechSynthesizer = {
        let speech = AVSpeechSynthesizer()
        speech.delegate = self
        return speech
    }()
    
    fileprivate var voices = [AVSpeechSynthesisVoice?]()
    fileprivate var speechStrings = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //设置可以播放的语言
        voices = [AVSpeechSynthesisVoice(language: "zh-CN")]
        //设置播放的内容
        speechStrings = ["Core Animation基于一个假设，说屏幕上的任何东西都可以（或者可能）做动画。动画并不需要你在Core Animation中手动打开，相反需要明确地关闭，否则他会一直存在。",
                         "当你改变CALayer的一个可做动画的属性，它并不能立刻在屏幕上体现出来。相反，它是从先前的值平滑过渡到新的值。这一切都是默认的行为，你不需要做额外的操作。"]
        
        play()
        
    }
    
    fileprivate func play() {
        for speech in speechStrings {
            //创建AVSpeechUtterance 对象 用于播放的语音文字
            let utterance = AVSpeechUtterance(string: speech)
            
            //下面配置AVSpeechUtterance的参数
            //设置播放使用的语言，如果未设置，将使用默认值
            utterance.voice = voices.first!
            //设置播放的语速，值介于AVSpeechUtteranceMinimumSpeechRate和AVSpeechUtteranceMaximumSpeechRate之间
            utterance.rate = 0.5
            //设置音调，默认值是1，允许设置的范围是0.5(低音调)到2.0(高音调)之间
            utterance.pitchMultiplier = 1.5
            //设置声音大小，默认值是1，可设置的范围是0.0(静音)到1.0(最大声音)
            utterance.volume = 1
            //播放本段文字前的延迟，单位s，默认值是0
            utterance.preUtteranceDelay = 2
            //本段文字播放结束后的延迟，单位s，默认值0。两段语音之间播放的延迟至少是preUtteranceDelay、postUtteranceDelay的和
            utterance.postUtteranceDelay = 4
            
            //将utterance(语音)对象添加到队列中，按照入队顺序播放语音
            synthesizer.speak(utterance)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: AVSpeechSynthesizerDelegate {
    //对应speak(utterance)，开始
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("***********start:\(utterance)***********")
    }
    
    //对应pauseSpeaking(at: AVSpeechBoundary)方法的调用，暂停
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        
    }
    
    //pauseSpeaking之后continueSpeaking，继续
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        
    }
    
    //当stopSpeaking(at:)调用时触发，取消
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        
    }
    
    //utterance播放结束后调用，如果postUtteranceDelay大于0，那么还有一个延迟，结束
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("***********finish:\(utterance)***********")
    }
    
    //指出将要播放的内容，通常是一个字符(generally, a word),可以用来高亮要播放的文字
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let range = utterance.speechString.range(from: characterRange)
        print(utterance.speechString.substring(with: range!))
    }
}

extension String {
    //http://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index/26749314#26749314
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}

