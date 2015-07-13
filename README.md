#inkbatch
Simple bash script to export inkscape layers to individual images (png, ps, eps, etc.) The generated images can be autocropped using ImageMagick.

##Requirements
`inkscape` - To export the images

`xmlstarlet` - To parse layer info for friendlier filenames (e.g eyes.png instead of layer13.png)

`convert` - To autocrop the resulting images

##Arguments
TODO

##Examples
Export layers into current working dir.

```sh
inkbatch file.svg
```
Export into a custom directory.

```sh
inkbatch -d outdir/ file.svg
```
Use a different format (png is the default)

```sh
inkbatch -f ps file.svg
```
Don't autocrop the resulting images.

```sh
inkbatch --no-autocrop file.svg
```
Pass custom opts to inkscape. In this case pass a flag to set higher dpi.

```sh
inkbatch --extra-opts "--export-dpi 300" -d high-dpi/ file.svg
```
