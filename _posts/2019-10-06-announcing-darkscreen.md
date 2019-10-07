---
layout: post
title: Announcing Darkscreen - A Dark App
image_folder: 2019/announcing-darkscreen
---

{% assign testflight_link = "https://testflight.apple.com/join/s4Sa9sEJ" %}

I'm so excited to announce that my first iOS app, Darkscreen - A Dark App, has a [public beta on Testflight]({{ testflight_link }})! Ever since I was given my first iPod (all the way back in 7th grade!) I've dreamed of creating something that millions of people have the ability to enjoy, and I can't express how excited I am. Here's the official description:


> Darkscreen allows you to use other iPad apps in Split View without any distractions, no hassle.
>
> Darkscreen provides multiple themes, including:
>
> - Dark
> - Light
> - 80s
> - 90s
> - Outrun

Download using [Testflight]({{ testflight_link }}) today!

## Why Darkscreen?

I really love using [Apollo for Reddit](https://apps.apple.com/us/app/apollo-for-reddit/id979274575) by Christian Selig, but he hasn't gotten a chance to create a true iPad experience for his Reddit client yet. I use Darkscreen next to Apollo in Split View so that Apollo can be in an iPhone-sized container while keeping the rest of the screen black.

For example, posts shown in Apollo don't quite look right when in full horizontal mode on iPad:

![Apollo in full horizontal mode]({% include _functions/image_path.html name='1-just-apollo.png' %}){: .center}

Now with Darkscreen, I can browse Apollo in its intended view size without being distracted by other apps:

![Apollo in Split View with Darkscreen]({% include _functions/image_path.html name='2-split-view.png' %}){: .center}

Switching to a new theme in Darkscreen automatically updates the table view as well as the root view underneath:

![Darkscreen switching themes]({% include _functions/image_path.html name='3-theme-switch.gif' %}){: .center}

My next goal, of course, is for Darkscreen to respond to the system-wide [Dark Mode](https://developer.apple.com/documentation/xcode/supporting_dark_mode_in_your_interface) setting.

## Why Open Source?

I found it an interesting challenge to modify the appearance of all of all views in the app immediately after a user selects a theme in a `UITableView`, and I hope this brief example can help other developers implement their own theme system.

Even though iOS 13 introduces [system-wide Dark Mode](https://developer.apple.com/documentation/xcode/supporting_dark_mode_in_your_interface), this example app can be helpful to support any custom themes that go beyond the default dark and light styles.

## How to Update the Theme for a View

I've implemented the theme system using a [Settings Bundle](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html), so the `BaseViewController` can subscribe to settings (theme) changes:

```swift
func registerForSettingsChange() {
    NotificationCenter.default.addObserver(self,
                                            selector: #selector(BaseViewController.settingsChanged),
                                            name: UserDefaults.didChangeNotification,
                                            object: nil)
}
```

A `Theme` corresponds to UI styles and colors:

```swift
class Theme {

    // ...

    init(_ name: String, statusBar: UIStatusBarStyle, background: UIColor, primary: UIColor, secondary: UIColor) {
        self.name = name
        statusBarStyle = statusBar
        backgroundColor = background
        primaryColor = primary
        secondaryColor = secondary
    }
}
```

When a setting changes, `BaseViewController` updates its UI elements:

```swift
@objc func settingsChanged() {
    updateTheme()
}

func updateTheme() {
    // Status bar
    setNeedsStatusBarAppearanceUpdate()

    // Background color
    self.view.backgroundColor = Settings.shared.theme.backgroundColor

    // Navigation bar
    self.navigationController?.navigationBar.updateTheme()
}
```

And `UINavigationBar` is extended to support theme switching:

```swift
public extension UINavigationBar {
    func updateTheme() {
        // Background color
        barTintColor = Settings.shared.theme.backgroundColor

        // Bar item color
        tintColor = Settings.shared.theme.secondaryColor

        // Title text color
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: Settings.shared.theme.secondaryColor]

        // Status bar style
        barStyle = Settings.shared.theme.navbarStyle

        // Tell the system to update it
        setNeedsDisplay()
    }
}
```
