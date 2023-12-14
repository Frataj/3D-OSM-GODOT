# 3D-OSM-GODOT
## Introduction
3D-OSM-GODOT is a 3D map builder built to visualize OpenStreetMap data in the Game Engine Godot.
The goal if this school Project was to build a foundation on which later projects can build on. The end goal will be to build a game in which the player can explore their home City or any place in the world and compare the Data from OpenStreetMap with Streetsview images from e.g. Mapillary and help to improve the Data by marking or changing wrong or outdated features.
## Data source
We use the Vector tiles, which are generated by the user StrandedKitty for their [streets-gl project](https://github.com/StrandedKitty/streets-gl/tree/dev?tab=readme-ov-file)
## Tile-Reader
To use the Vector tiles within the Godot Project, we use the [godot-geo-tile-loader](https://github.com/pka/godot-geo-tile-loader) which was provided by Pirmin Kalberer for this project. It provides a lot of useful functions related to extracting Data from the Vector tiles and might in the future get extended with even more functions like downloading the Tiles if they can not be found locally. 
## Usage
### Godot
To run this project, currently you need to install Godot locally. You can do this by following this link: https://godotengine.org/.
### Set your  starting location
Navigate to /code/main.gd and edit the lines `const START_X = x` and `const START_Y = y` to the coordinates of your choosing. To find the location you wish you can for example use the [Tool provided by Maptiler](https://www.maptiler.com/google-maps-coordinates-tile-bounds-projection/).
### Running the application
Open /code/project.godot with Godot and press `F5` to run the main scene. 
 ### Controls
 Movement uses the standard FPS control scheme, with `W`, `A`, `S` & `D` to move around and `shift` to "sprint". Currently the player is always flying, to ascend, press `Q`, to descend press `Y`.  
## Linter
This project used the linter from the GDScript Toolkit found here: https://github.com/Scony/godot-gdscript-toolkit
### Using the linter
<ol>
  <li>Follow the install instructions on the GDScript Toolkits GitHub Page</li>
  <li>Use <code>gdlint &ltpath-to-your-.gd-file&gt</code></li>
</ol> 
