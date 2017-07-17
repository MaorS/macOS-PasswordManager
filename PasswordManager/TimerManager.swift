//
//  TimerManager.swift
//  Theranica
//
//  Created by Maor on 12/07/2017.
//  Copyright © 2017 MSApps. All rights reserved.
//

import Cocoa

class TimerManager : NSObject{
    
    static let manager = TimerManager()
    override private init() {}
    
    var timer = Timer()
    var delegate : TimerManagerDelegate?
    var isFirstCall = true
    
    /// Configure new timer with seconds
    func configNewTimer(timeInMinutes : Int){
        if timeInMinutes == 0{
            UserDefaults.standard.set(timeInMinutes, forKey: Constants.LOGOUT_TIMER)
            stopTimer()
            return
        }
        let timeInSeconds = timeInMinutes * 60
        UserDefaults.standard.set(timeInMinutes, forKey: Constants.LOGOUT_TIMER)
        setupCountdown(with: timeInSeconds)
    }
    
    /// Start timer if there is saved
    func fireExistTimer(){
        let savedTimer = UserDefaults.standard.integer(forKey: Constants.LOGOUT_TIMER)
        if savedTimer != 0{
            configNewTimer(timeInMinutes: savedTimer)
        }
    }
    
    /// fire timer with seconds
    private func setupCountdown(with time : Int){
        if timer.isValid{
            stopTimer()
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(time),
                                          target: self,
                                          selector: #selector(self.finish),
                                          userInfo: nil,
                                          repeats: true)
        self.timer.fire()
    }
    
    /// Timer did finish
    func finish(){
        // because the timer is called also on the fire, resolve this tith bool
        if !isFirstCall{
            self.delegate?.timerDidFinish()
        }else{
             isFirstCall = false
        }
    }
    
    /// Stop current working timer
    func stopTimer(){
        timer.invalidate()
        isFirstCall = true
    }
    
}
protocol TimerManagerDelegate {
    func timerDidFinish()
    
}



