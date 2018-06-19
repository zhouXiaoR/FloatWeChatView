### 关键词
转场动画，手势监听，核心动画

### 运行效果
![运行效果](浮窗运行效果.gif)

### 使用简介
```
// []中存放需要悬浮的类，vcname指类名
FloatViewManager.manager.addFloatVcsClass(vcs: [vcname])
```
### 主要使用类目及功能
整体涉及以下几个主要的类，并注明其功能点
- `FloatViewManager`单例，用来管理悬浮窗信息以及在window上的视图。
- `TransitionPush / TransitionPop`自定义导航转场动画
- `FloatBallView`屏幕上圆形浮标，可拖动
- `BottomFloatView`底部绘制黑色或者红色视图

### 思路
- 1. 首先初始化项目时，为了监听手势移动变化，自定义转场，手势代理交由FloatViewManager来管理。 
```
currentNavtigationController()?.interactivePopGestureRecognizer?.delegate = self
        currentNavtigationController()?.delegate = self
```
- 2. 当进入可支持悬浮的控制器时，需要根据手势的偏移来计算底部黑色半透明框的移动，这里我们使用以下来做监听，注意这里一定要进行安全判断。

```
func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
// 当前导航控制器是否存在子集合
        guard  let vcs = currentNavtigationController()?.viewControllers else{
            return false
        }
        
// 如果是根控制器，不做处理
        guard vcs.count > 1 else {
            return false
        }
        
// 判断当前的控制器与开始数组中的支持悬浮的控制器是否一致，只有一致才执行下一步，并开启监听
        if  let currentVisiableVC = currentViewController() {
             let currentVCClassName = "\(currentVisiableVC.self)"
             if currentVCClassName.contains(floatVcClass.first!){
                startDisplayLink()
                edgeGesture = (gestureRecognizer as? UIScreenEdgePanGestureRecognizer) ?? nil
                tempCurrentFloatVC = currentVisiableVC
            }
        }
        return true
    }
}
```

- 3. 根据监听的结果更新底部的半透明视图，这里详细代码请参见源代码。
- 4. 在手势结束完之后，判断是否悬浮，若最终结束手势在底部黑色透明内，悬浮并展示圆形浮标，反之隐藏。

```
@objc func displayLinkLoop() {
        if edgeGesture?.state == UIGestureRecognizerState.changed{
            guard let startP = edgeGesture?.location(in:kWindow) else {
                return
            }
    
            let orx : CGFloat =  max(screenWidth - startP.x, kBvfMinX)
            let ory : CGFloat = max(screenHeight - startP.x, kBvMinY)
            bFloatView.frame = CGRect(x: orx, y: ory, width: kBottomViewFloatWidth, height: kBottomViewFloatHeight)

            // 将点转化到底部视图上，计算是否在黑色圆内
            guard  let transfomBottomP = kWindow?.convert(startP, to: bFloatView) else{
                return
            }
            
         //   print(transfomBottomP)
            if transfomBottomP.x > 0 && transfomBottomP.y > 0{
                let arcCenter = CGPoint(x: kBottomViewFloatWidth, y: kBottomViewFloatHeight)
                let distance = pow((transfomBottomP.x - arcCenter.x),2) + pow((transfomBottomP.y - arcCenter.y),2)
                let onArc = pow(arcCenter.x,2)
                if distance <= onArc{
                    if(!bFloatView.insideBottomSeleted){
                        bFloatView.insideBottomSeleted = true
                    }
                }else{
                    if(bFloatView.insideBottomSeleted){
                        bFloatView.insideBottomSeleted = false
                    }
                }
            }else{
                if(bFloatView.insideBottomSeleted){
                    bFloatView.insideBottomSeleted = false
                }
            }
        }else if(edgeGesture?.state == UIGestureRecognizerState.possible){
            
//结束的时候判断最终手指的位置即黑色透明视图是否是选中状态。若选中，存储当前控制器，并暂停掉定时器（这里一定要暂停，不然浪费资源）
            if(bFloatView.insideBottomSeleted){
                currentFloatVC = tempCurrentFloatVC
                tempCurrentFloatVC = nil
                ballView.show = true
                
                if let newDetailVC = currentFloatVC as? NewDetailController{
                    ballView.backgroundColor = newDetailVC.themeColor
                }
            }
            // 隐藏底部黑色透明视图
            UIView.animate(withDuration: animationConst().animationDuration, animations: { 
                  self.bFloatView.frame = CGRect(x: screenWidth, y: screenHeight, width: kBottomViewFloatWidth, height:kBottomViewFloatHeight)
            }) { (_) in
                
            }
            stopDisplayLink()
        }
    }
```
- 5. 圆形浮标支持拖动，并且提供点击，拖动手势代理方法供FloatViewManager使用更新相关视图，参见源代码
- 6. 当用户返回到其它界面，只要保证能找到最顶部导航，就可以再次打开悬浮窗控制器。这里主要是自定义转场动画push/pop。
- 7. 当用户手指手动悬浮窗取消悬浮时，将单例中保存所有的数据清空，保证再次可以正常使用。

### 缺陷
微信此功能，手指侧滑至大于0.5松开，也会执行pop的转场动画，但我一直没有找到合适的有效的解决方案，如有解决或者知晓方案的可以一起交流一下。

### 个人理解 
看到技术论坛有人仿写，于是自己也好奇尝试着用swift做了一下，主题功能不难，只是有点繁琐。

***swift最近一直有在看，源码有点乱，不要介意***

### 源码
[Git源码](https://github.com/zhouXiaoR/FloatWeChatView)

### 简书联系
[意见建议](https://www.jianshu.com/p/60494fd3935d)


### 感谢作者及其以下博客，如有问题欢迎私信批评指正

[Customizing the Transition Animations](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html)

[UINavigationController内的转场动画](https://www.jianshu.com/p/75216054469c)

[iOS浮窗](https://mp.weixin.qq.com/s/2jpkQVT9hE6QcADQYcHeKA)