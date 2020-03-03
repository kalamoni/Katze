# Katze
### Katze - Your Fav Cat App

- The app architecture is MVC and follows Cocoa design patterns whenever fit.

- All networking are done via the singleton class of `NetworkManager`, which is a unified access point to make HTTP requests. And each type of request is done via a dedicated method. This class handles caching as well.

- Image fetched from http://thecatapi.com/

- Browsing images in an endless collection view.

- Easily manage a favorite list.

- All images are cached locally (this might not work in the simulator, as the absolute path on disk is always randomly generated for the "tmp" folder for the user)
