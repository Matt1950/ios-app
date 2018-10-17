# iOS Mapper Applicaiton

To run the application 

Open terminal and type:
```
sudo gem install cocoapods
sudo gem install -n /usr/local/bin cocoapods
```
Navigate to the project route and execute
```
pod install
```

## Application structure
### Controllers
  
  The app depends on extentions of UIViewControllers 
  Delegates is implemented in sections marked
  ```
  // MARK: - <SuperClass> Delegates
  ```
  Application specific functions is added in sections marked
  ```
   // MARK: - Custom Functionality
  ```

  * These marks makes navigation in xcode easy    
### Models
#### * Entity models
  A model factory is used to convert the json responses from the Utils/networking class into entity models
#### * View models
  Mapping annotations are extended to provide an easy manner of showing custom attributes in the default apple mapkit 
### Utils
  Networking is delegated to the static networking class wich will manage request timeouts, 
  and abstraction of networking requests

