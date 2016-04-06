
Objectives

Keyboard - hiding and selecting
Dealing with text fields and buttons
Saving data
Using touch events to move objects on the screen.

Description:
The Application implements a iOS app that contains three text fields (inputText, x, y ) with labels, one button
(with label Update) and one other label, 

When the user clicks on the "Update" button with the value in the inputText field is copied to
the moving label. If the x and y text fields have values then the center of the moving label is
moved to that location (x, y). If either x or y text field do not have any text the moving label
does not change position when the user clicks on the "Update" button. Clicking on the "Update"
button hides the keyboard.
The application stores the values in the text fields. So when the user "kills" the application
and then restarts the app the values in the text fields are restored to the values they had
before the app was killed. Killing the app is different than just placing the app in the background.
If using Xcode 6 you should to turn off Auto Layout.

Allows the user to move the moving label by touching the screen with one finger. When the user
touches the screen the center of the moving label is placed under the finger. When the moving
label moves update the values in the text fields x and y.
