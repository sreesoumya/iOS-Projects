			PARKING LOT MONITORING APP

Description:
This APP uses the capabilities of iPhone to monitor the usage of parking Lot. It uses GeoFencing to monitor 
regions (parking lots) for entry and exit conditions and combines this with the motion activity tracking to 
determine if the user is walking or driving while entering and exiting the lot. This data is then updated 
to a database server in the background from where any user can query to see what is the current 
status of the lot. Along with the status this App also provides navigation option to the selected parking lot.

The database created and used to store all the information is 
https://smy.iriscouch.com/_utils/database.html?parking

Algorithm to determine parking lot usage
Entered    DRIVING  exit WALKING    =>  Parking spot taken
Entered   WALKING exit  DRIVING     =>  Parking slot available
Entered    DRIVING  exit  DRIVING     =>  Parking lot is full
Entered UNKNOWN exit  DRIVING     =>  Parking spot available

Applied algorithms, its advantages and limitations (mainly limited due to iOS )
LOT_ENTRY_EXIT_COLLECT_IN_ARRAY_ALGO  - works well and is more robust than others but needs the 
app to be active to get the 10 activity updates on entry/exit. iOS restriction that activity updates 
cannot be delivered to a background app played spoil sport.However, if the app is active frequent updates
are received which can be affectively utilized.

LOT_ENTRY_EXIT_TIME_BASED_ALGO - collecting data on exit by querying history is the only way to process 
information keeping app in background. However, iOS does not update the historical data as frequently as the 
active updates mentioned above. It probably stores only filtered data and so it keeps only those activities which have
significant change associated with them. This poses a problem with collecting driving information as it takes some
significant driving before this activity is available in query. Hence the modification to collect 1 hr of data. 

LOT_ENTRY_EXIT_TWO_MINUTE_PRIOR_ALGO - This algorithm also works completely in background 
but suffers from the issue that many times a query for last two minutes does not return any activity
as there might not have been a significant change in activity. Hence this was modified to the above
algorithm.


Special Instructions to Run the App:
1. This App needs A7/A8 motion co-processor to be able to function properly.
2. I tested this app on iPhone 6+ (the provision file made for me did not load on the iPod but worked on iPhone6+)
3. The App needs special permission for background location monitoring and activity tracking which are requested at first run
    permissions needed for
		- background location monitoring set to "Always"
		- motion activity tracking permission granted for this application
         		- "Background App Refresh" switched on
4.Regions defined in the database are actual parking lot coordinates, entry/exit and updates are done only at those locations.
   I tested APP by setting PS1 parking lot coordinates in database as my home coordinates and driving in an out , parking etc.


Limitations and assumptions:
1. Regions are Circular and for now no overlapping or regions other than circular are considered.
2. User is expected to enter and exit the region for corresponding parking lot to get updated in database.
3. More than 1 user sharing a ride will update the database independently, this is not handled yet.
4. Parking lots under the office/classes where user does not exit the region are not handled correctly now.
5. Location and motion tracking accuracy are best effort estimates .
6. Not all users using the parking lot may use this app, this condition is partially handled using the above condition.
