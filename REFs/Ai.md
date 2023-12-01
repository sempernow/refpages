
# [Adobe Illustrator CC 2018 (Ai)](https://helpx.adobe.com/illustrator/user-guide.html "Ai User Guide")

## SVG @ `SVG` ([MD](SVG.html "@ browser"))   

## Bitmap to Vector 

1. Window > Workspace > Tracing (will be inactive; greyed-out)
1. Direct Selection Tool (_solid_ arrow icon)
    - Click on Artboard, and the Tracing window should become active
1. Tracing > Preview (checkbobx)
    - Select options
1. Uncheck Preview, and  click Trace (button)
1. Top Menu Bar > Expand 
1. Export 

## Fatten Path Outline 

- Effect > Path > Offset

## Convert Stroke to Outline 

- Object > Path > Outline Stroke
    - This is not reversible.

## Preserve Arboard, Groups, etc. on Save

- Must "Export" _not_ "Save":
    - File > Export > Export As > SVG 
        - Select checkbox: Use Artboards (@ 1st menu).
        - Unselect checkbox: Minify (@ 2nd menu).

See `SVG` ([MD](SVG.html "@ browser"))   

## Create PNG of SVG 

- File > Export > Export for Screens
    - All
    - Formats > Format: PNG

See `SVG` ([MD](SVG.html "@ browser"))   

### Delete inner object encircled by outer object (shapes)

1. __Direct Selection Tool__ > Select both objects.
1. Window (menu) > Pathfinder (toolbox/tab) > Pathfinder > Divide 
1. Window (menu) > Pathfinder (toolbox/tab) > Shape Modes > Minus Front 

### Combine objects (shapes)

1. __Direct Selection Tool__ > Select both objects.
1. Window (menu) > Pathfinder (toolbox/tab) > Shape Modes > Unite

### Slice an object 

1. __Erase Tool__ (RT-CLICK) > __Scissors Tool__
1. Click on the object's path at the desired slice-point(s).
    - Use __Selection Tool__ to manipulate the object(s) thereafter. 
        - First click anywhere away from the previously selected object to decouple what is now the two objects (sliced from one).

### Add point(s) to a path (line or curve)

1. __Pen Tool__ (RT-CLICK) > __Add Anchor Point Tool__ (select)
1. Click on path at point desired.

### Cut one object with another 

- Method 1 (Simple)
    1. __Direct Selection Tool__ > Select both objects.
    1. __Shape Builder Tool__ > ALT-CLICK on region(s) to DELETE. 
- Method 2 (More control)
    1. __Direct Selection Tool__ > Select target object.
        - Window (menu) > Pathfinder (toolbox/tab) > Shape Modes:
            - Unite (Leftmost), or other effect
    1. __Direct Selection Tool__ > Select both objects
        - Window (menu) > Pathfinder (toolbox/tab) > Pathfinders:
            - Trim (Second from left), or other effect

### &nbsp;
<!-- 
# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   
-->
