
Objectives :
Sample some UI components.

App description
This app will use a number of UI elements 
Used a tab bar with a number of tabs. The view for each tab is described below.

Food tab
The view at this tab contains a custom picker view with two columns. The first column 
contains a list of countries. When the user has selected a country then the second column displays
a list of foods in that country. The list of countries and their foods are given below. The
view also has a slider. When the user selects the top (first) food item in the list. The slider
moves all the way to the left. When the user selects the bottom (last) food item in the list the
slider moves all the way to the right. When the user selects a food item between the first and
last the slider moves proportionally. So if Mexico is selected and the user selects the second
food item from the top then the slider moves 1/10 the way to the right. Conversely when the
user moves the slider the picker will move to the corresponding food item. A slider has many
possible positions. However the picker has much fewer positions. For example when Mexico is
selected there are only 11 food items. So the picker has only 11 positions. So when the user
moves the slider they may leaving in a position that does not correspond exactly to a food selection
in the picker. When that happens after the user is done ,it moves the slider to the closest
position corresponding to a food selection in the picker.

Country Food Items
India 
Avakaya, Pesarattu, Thukpa,
Thali, Litti Chokha, Maple,
Palak Paneer, Rajma-Shawl,
Vindaloo, Khaman, Handva,
Bisi bele bath, Pav Bhaji,
Eromba, Chungdi Jhola
USA
Hot Dog, Pizza, Hamburger,
Clam Chowder, Succotash,
Fried Chicken, Gumbo, Grits,
Chitterlings, Hushpuppies,
Cobbler
Mexico 
Taco, Quesadilla, Pambazo,
tamal, huarache, Alambre,
Enchilada, Panita, Gordita,
Tlayuda, Sincronizada

Web Tab
This view contains a text field and a web view. When the user enters a valid url in the text field
the web view displays the indicated web page.

Segment Tab
This view has a segmented control with three options: Progress, Text, Alert. When the user selects
the "Progress" option they see a switch and an inactive activity indicator. When they turn
the switch "on" or to the left the activity indicator spins. When they turn the switch off the activity
indicator stops spinning. When the user selects the "Text" option they see a Text View that
they can enter text. The text view should start with some text.
When they select the "Alert" option they will see a button. 
When they click on the button an alert will pop up asking the user "Do you like the iPhone".
