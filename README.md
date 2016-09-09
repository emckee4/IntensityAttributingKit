# IntensityAttributingKit (v3)
© 2016 by Evan McKee

IntensityAttributingKit is a swift framework which provides a means of creating, displaying, and converting text with "intensity" attributes by the user on an iOS device. Ideally the user would have a 3dTouch capable phone so that intensity of a character can be derived from the pressure applied to the key, but intensity can also be applied using touch duration, screen impact data derived from the accelerometer, or a manual control. 

This project is the base for the IntensityMessaging app intended for release shortly. Check for updates at [www.intensitymessaging.com](https://www.intensitymessaging.com). Until release you can see it in action via the included sample project.

With version 3 the editor and view were rewritten as subclasses of UIView rather than UITextView. Building directly on TextKit enabled more animation options and the removal of some hacky fixes that had been necessitated by Apple's use of private APIs within some of their own objects (like UITextView). 

The new IACompositeTextView/Editor classes (derivatives of the IACompositeBase abstract class) use 4 layers to render animations for the intensity rendering schemes that support it. On top is the selectionView which draws selection rects, the text insertion caret, and text marking. Below that is the imageLayerView which draws the thumbnails of any inserted attachments at the proper position which is determined by the layout/typesetting engine in the topTV, which itself will display empty rectangles where an attachment belongs. Beneath these top two views are the top and bottom ThinTextView's. The top ThinTextView is the one responsible for generating sizing information and is the drawer of text in the schemes which don't support animation. When animating, the bottomTV will be drawn with different attributes and some combination of changing opacities between the layers will result in the animation effect for the user. The layers are separated so that images can be properly displayed even when the text layers are animating their opacity. It also may (or may not, I've only eyeball measured this since this design decision was otherwise necessary) improve the performance text drawing in cases when an image needs to be moved around (e.g. when inserting text before an image or resizing textview) but doesn't need to be fully redrawn. Redrawing of images tends to be much more expensive in terms of processing overhead than are translational transforms of already drawn bitmaps. 

### Components classes:

**IACompositeBase** is the abstract parent class containing the common code for the IACompositeTextView and IACompositeTextEditor. It holds four visible subviews (IASelectionView, ImageViewLayer, top ThinTextView, bottom ThinTextView) stacked upon each other with a fifth view (the IAMagnifyingLoup) visible when needed. The IACompositeBase class also contains the animation code for animating opacity. For performance reasons, as much work as possible is pushed off of the CPU and onto the GPU. As a consequence of this and many other optimizations, the performance of the IAComposite derived classes is adequate even on older devices (iPhone 5) and in a few speicific cases superior to naively implemented UITextView.

**IACompositeTextView** is made for display only and doesn't support editing beyond simply setting an IAString. It's intended to allow more caching and other performance minded changes, though much hasn't been implemented.

**IACompositeTextEditor** conforms to UITextInput and is built to interact with the IAKeyboard and IAAccessory. It has custom gesture recognizers, more intricate copy/pasting and insertion capabilities.

**ThinTextView** is similar to UITextView in that it has an NSLayoutManager, an NSTextContainer (actually a subclass called IATextContainer), and an NSTextStorage. The major differences between it and a UITextView are that it doesn't conform to UITextInput, and it draws in its own layer rather than a private subview. Additionally it's more simple positionally (e.g. no insets and some aspects of autolayout have been simplified, since both of those are handled higher in the hierarchy) and the use of the IATextContainer lets an IATextAttachment return an empty image of a specified size if that's desired for the view.

In all cases it's intended that sizing for autosizing cells will be calculated after a preferedMaxLayoutWidth has been set (similar to UILabel). This is simpler to implement and more efficient that what is used in a UITextView since it lets us get away with fewer text layout passes when determining content size. sizeThatFits(targetSize) can be used to flexibly calculate how much space will be needed in either direction to fully contain the content.

The performance on older hardware (tested on the iphone 5) was better than expected due to a variety of optimizations, particularly with layout and image drawing. There are quite a few transparent layers on screen and animating at once along with typesetting and glyph drawing activities which are CPU intensive. This won't be a huge problem with only a few IA views on screen but with tableview full of them performance may suffer in more demanding situations like scrolling and resizing.


#### The IAKeyboard and IAAccessoryVC:
The **IAKeyboard** is the prefered method for creating intensity attributed IAStrings. The keyboard consists of a configurable grid of PressureKeys and ExpandingPressureKeys which can receive and (via the RawIntensity objects) interpret the touch events to yield text with intensity values. The IAKeyboard only has a Basic Latin keyboard at present with 2 pages of characters but more can easily be added to the Keysets.swift using KeysetComponents. The IAKeyboard can be swapped out in favor of the system keyboard using the swap key on the IAAccessory. The IAKeyboard also has a suggestions bar which is unfortuneately slightly wonky at present due to a bug in the publicly available version of Apple's UITextChecker. It has a nasty tendancy to return suggestions in alphabetic order rather than order of likelyhood, contrary to the documentation. This is a known issue.

The **IAAccessory** is the input accessory which will always be present when an IACompositeTextEditor is first responder. It provides access to keyboard swapping (to swap to the system keyboard), the image picker, an intensity readout (which can be used as a pressure key to set the intensity when using other keyboards), an intensity slider (when in landscape), expanding keys for choosing intensity smoothing and intensity render schemes, and the options button to launch into the IAKit preferences. Using the IAAccessory, intensity attributed text can be generated with any keyboard.



#### IAString:
The **IAString** data structure is the means for storing intensity attributed strings which can be converted to JSON, NSData, or NSAttributedStrings for display. The IAString contains several different data structures within and works to keep their indexes in sync as elements are inserted/modified/deleted. In addition to the swift String containing text, it also contains:
- An array of integers representing the intensities at each position in the string
- A CollapsingArray (a struct designed for holding long ranges of repeated values with an array like interface) of IABaseAttributes (a bitfield containing stuff like base size/bold/italic/underline)
- An array of URLs stored with associated ranges (in RangeValuePair structs)
- An IAAttachmentArray (which is a purpose built sparse array) containing IATextAttachments and their indexes
- IABaseOptions- The prefered display and rendering characteristics which cover the whole length of the IAString.

The class is broken up into several extension files, with each covering different purpose including conversion to NSAttributedStrings for display (using the IntensityTransformers), editing functions which keep the indeces of the internals in sync, and printing/logging functions.
The class is pure swift/non-objective c for performance and so relies on an IAStringArchive class as an NSCoding complient wrapper when archiving.

##### IAString rendering/conversion:
In order to display an IAString, it's necessary to convert from a set of text, intensities and abstract preferences into one or more well defined NSAttributedStrings. To do this we use classes which conform to **IntensityTransformingProtocol**. These contain a few functions which specify how many steps of intensity are used by the transformer (ie binning), how each bin is represented, and how each of those representations are affected by the base options. All intensity transformers must conform to this protocol which can yield a single NSAttributedString for non-animated display. To enable animation the transformer must addtionally conform to AnimatedIntensityTransforming which adds a function which can yield top and bottom NSAttributed strings, while also adding some animation parameters.

These protocols make it remarkably easy to add transformers to the IAKit. The one caveat is that for animated schemes the positions of individual glyphs need to be relatively invariant between the two layers even if the sizes of the glyphs vary.  


##### IAKitPreferences:
**IAKitPreferences** provides an interface for all of the persistant configurable user preferences. These are stored in the standard NSUserDefaults and cover preferences and overrides for the viewer and editor, as well as a means for setting the IAKitVisualPreferences which govern keyboard/accessory aesthetics. 



### Setup notes:
In order to support locating the user automatically in the LocationAttachmentPicker, the following should be added to the main app's info.plist:
```XML
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is used to show your position in the location picker.</string>
```
`


### Readme TODO:
* Add basics on setup and use.
* Explain a little version history and why things now work the way they do.




### Possible future improvements:
- Multiple keysets
- eventually make more/all keys potentially expanding if performance is sufficient

- Some of the data structures in the IAString may be less than optimal since they were in part excuses to learn and practice building data structures using swift generics. It probably doesn't matter enough to be a priority.

- Additional render scheme ideas:
- animated/pulsating sizing
- animated colored shadows
- variations on existing schemes



# IAKit SampleProject:
The IAKit SampleProject is a stripped down messaging interface for demonstrating the basic setup and use of the IAKit. Its code is derived from that used in the IntensityMessaging app but with CoreData, asynchrounous image loading, and much of the other unneccessary complications removed. The IAKit can be used in a simpler manner if desired, especially if you don't care about dynamic sizing, caching of sizing data, or reusability of the MessageThreadTableViewController without the MessageThreadVC. 

The sample project now includes a toggle for keyboard themes. I suggest HotdogStand.



