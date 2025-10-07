# Setup

1. Install `tuist`:
   - Follow the instructions at [tuist.io](https://tuist.io) to install `tuist` on your machine.

2. Generate the project:
   ```bash
   tuist generate
   ```

3. (Optional) Rename the project:
   - Update the `PRODUCT_NAME` in `Project.swift` with your desired project name.

4. Open the project:
   ```bash
   xed .
   ```

# Edit Tuist configulation
- Run `tuist edit`

# Run Individual Feature to increase fast development
- Run `tuist generate HomeFeatureApp --open` to create single app with following feature `HomeFeature`
## Create Instance App
- Add inside `targets : []`. Try to add under the feature you want
```
  //Existing feature
  .framework(
    name: "HomeFeature",
    dependencies: [
      .target(name: "Router")
    ]
  ),
  // new block of statements to add
  .featureDemoApp(
    "HomeFeature",
    deps: []
  ),
```
- Add scheme at the top of the file
```
  let homeDemoScheme = Scheme.scheme(
    name: "HomeFeatureApp",
    buildAction: .buildAction(targets: [.target("HomeFeatureApp")]),
    runAction: .runAction(configuration: .debug)
  )
```
- Add `homeDemoScheme` inside parenthesis `schemes: []`
- now you can run individual app instance 
  `tuist generate HomeFeatureApp --open`


# Router

The `Router` is the navigation graph that holds all view navigation implementations in `RouterLive`.  
The graph is self-explanatory, providing a clear overview of the navigation flow throughout the app. Reviewing it will give you a big-picture understanding of how views are navigated in the application.

# Modular At Ease

The project template is designed to keep things simple and minimal.  
You can adapt it to various architectural patterns like **MVVM**, **MVC**, or **Clean Architecture**. However, it is recommended to stick with a lightweight, vanilla approach similar to **React**.

For additional insights, check this [discussion on the Apple Developer forums](https://forums.developer.apple.com/forums/thread/699003?page=2).
