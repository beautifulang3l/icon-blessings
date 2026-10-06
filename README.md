# Icon Blessings

An AppleScript for arranging macOS desktop file and folder icons into a shape. It does not animate them.

## Use

Run the script with a shape name, an optional size percentage from `20` to `100` (default `80`), and an optional line-compensation mode (`none` or `horizontal`; default `none`). It arranges every file and folder currently on the Desktop; you do not need to select anything:

```sh
osascript "~/projects/angel/icon blessings/arrange-icons.applescript" plus 80 horizontal
```

Shapes: `heart`, `woman`, `womanicon`, `trans`, `plus`, `smiley`, `cube`, and `star`. 

The percentage scales the shape up to that portion of the largest size that fits within the desktop's usable width and height, preserving the shape's proportions. The script leaves a small edge margin and centers the shape on the desktop. `horizontal` moves alternating icons slightly up and down only along straight horizontal strokes; it does not affect curves or vertical/diagonal strokes. This can make horizontal strokes appear visually thicker despite varying icon-label heights. This uses Finder's desktop-specific icon positions, not the separate positions shown in a Finder window opened to the Desktop folder. With many desktop items, icons may overlap because Finder does not resize them. Set the Desktop's **View > Sort By > None** and turn off **Use Stacks** so Finder does not override individual icon positions. The script checks that Finder kept the requested positions and reports an error if it did not. On first use, macOS may ask for permission for the script runner to control Finder.
