---
layout: post
title: How to Change the Status Bar Style in iOS 12
image_folder: 2019/change-status-bar-ios
---

For some iOS apps, it may be helpful to change the color of the status bar at the top of the screen. For example, if I have a dark background, the default status bar style is hard to read:

![Dark iPhone app]({% include _functions/image_path.html name='dark-dark.png' %}){: width="50%"}{: .center}

To change the appearance of the status bar within a view controller, first add "View controller-based status bar appearance" as an item to your `Info.plist` with a value of `YES`:

![Info.plist]({% include _functions/image_path.html name='plist.png' %}){: .center}

Then in any view controller, you override the `preferredStatusBarStyle` property:

```swift
override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}
```

And if you ever need to update the status bar color, call `setNeedsStatusBarAppearanceUpdate()`. Now the full view controller looks like this:


```swift
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view,
        // typically from a nib.
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
```

Running this view controller, we get a light status bar!

![Dark iPhone app with light status bar]({% include _functions/image_path.html name='dark-white.png' %}){: width="50%"}{: .center}
