//
//  PresentMenuBarHeader.swift
//  MenuBarController
//
//  Created by lax on 2022/9/22.
//

import Foundation
import UIKit

let ScreenBounds                = UIScreen.main.bounds
let RealWidth                   = UIScreen.main.bounds.size.width
let RealHeight                  = UIScreen.main.bounds.size.height
let ScreenWidth                 = RealWidth < RealHeight ? RealWidth : RealHeight
let ScreenHeight                = RealWidth < RealHeight ? RealHeight : RealWidth
let ScaleWidth                  = ScreenWidth / 375.0
let ScaleHeight                 = ScreenHeight / 667.0
let ScaleSize                   = ScaleWidth > 1 ? ScaleWidth : 1

let StatusBarHeight             = UIApplication.shared.statusBarFrame.size.height >= 44 ? UIApplication.shared.statusBarFrame.size.height : 20
let NavigationBarHeight         = StatusBarHeight + 44
let TabBarHeight: CGFloat       = StatusBarHeight > 20 ? 83 : 49
let HomeBarHeight: CGFloat      = StatusBarHeight > 20 ? 34 : 0
let BottomPadding: CGFloat      = StatusBarHeight > 20 ? 44 : 16

let ISiPhoneX                   = StatusBarHeight > 20 ? true : false
let ISiPhoneSE                  = ScreenWidth < 375 ? true : false
