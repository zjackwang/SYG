# EatThat!

Scan a receipt, and EatThat! will save the items to your local storage. 
EatThat! will also match each item with its respective “eat-by” time interval and remind you to eat that item on the eat-by day listed. 
Swipe away the item when you've eaten it to remove the reminder! 
Happy eating!

## Beta 2.2. Features
1. New Eat-by time assignment process 
    1. Introduced Generic Items: 
        1. A common grocery item that can describe many different variations named on the receipt
        2. Ex. Generic item {“Peanut Butter”} describes “HEB Tx Peanut Butter” scanned from receipt
        3. Generic Items have these attributes:
            1. Name
            2. Category : {“Produce”, “Meat, poultry, seafood”, “Dairy”, “Drinks”, “Condiments”}
            3. Subcategory: <short description>
            4. DaysInFridge: Double i.e. decimal value
            5. DaysInFreezer: Double i.e. decimal value
            6. DaysOnShelf: Double i.e. decimal value
            7. IsCut: optional True/False
            8. IsCooked: optional True/False
            9. IsOpened: optional True/False
            10. Notes
            11. Links
    2. Introduced Matched Item Pairs:
        1. A unique pairing between an item name scanned from the receipt and its matched item 
        2. Ex. “HEB Tx Peanut Butter” : Generic Item {“Peanut Butter”} 
        3. Matched Items have these attributes
            1. ScannedItemName
            2. GenericItem 
    3. Eat-by time assignment now uses Matched Item Pairs and Generic Items:
        1. Given a scanned item name “scannedItemName”, the app first checks to see if it can be found in a Matched Item. 
        2. If a Matched Item Pair exists, the scanned item will be assigned the eat-by times of the corresponding Generic Item 
        3. Otherwise, the app will manually create a Matched Item Pair by comparing “scannedItemName” to the name of each Generic Item that exists currently in the EatThat! database. The app will set the best matched Generic Item in the Matched Item Pair if one exists, or if no match exists, the Matched Item Pair will have a ‘nil’ Generic Item.
        4. At the end of the eat-by time assignment process, the user will have an opportunity to correct the app-generated Matched Items, detailed in 5.
        5. After all corrections, if any, the app will assign to the scanned item the eat-by time of its matched Generic Item, like in 1.3.1.. If there was no Generic Item i.e. nil Generic Item, then the app will use the default eat-by time interval. 
    4. Removed Confirmation Screen 
2. Reading existing grocery item data and crowdsourcing new data
    1. Generic item look-up now available: 
        1. The user can now look up all current Generic Items used in the Eat-by time assignment process. 
        2. Users can search via Generic Item name and Generic Item category
        3. Users can tap on each Generic Item row to view its attributes
    2. Created a user suggestion process for new Generic items and updating existing Generic Items:
        1. The user can suggest new Generic Items to be used by the app in the future.* 
        2. The user can suggest changes to existing Generic Items to correct any inaccuracies found.*
    3. Created a user suggestion process for new Matched Item Pairs
        1. If the user desires, they can change the Generic Item matched to a particular scanned item 
        2. In doing so, the user will submit the new Matched Item Pair to be used by the app in the future.*
3. Misc.
    1. Changed instances of wording “expiration time” to “eat-by time” to avoid the connotation that the date of notification is a strict date for a given item and impress more of a suggestion to eat by then. 
    2. Allow settings to be editable 
        1. Default days item has to eat by (when there is no matched item)
        2. Days before red clock indicator shown
        3. Days before yellow clock indicator shown 
    3. Main View organized by categories
        1. Categories
            1. Produce
            2. Meats, Poultry, Seafood,
            3. Dairy,
            4. Drinks,
            5. Condiments,
            6. Cooked,
            7. Unknown
        2. Defined at receipt analysis step
        3. Can be edited by user 
    4. Flagging items that are not grocery items
        1. This will send a suggestion to the app for review so later scans will not include this


*All user suggestions do not take take effect immediately and undergo a review process before incorporation into the app. 

## Beta 2.0 Changes:
1. Manual Confirmation of scanned items
    1. Changes to remind dates are saved in the cloud to build an accurate “eat-by” date database. 
    2. Help me out!
    3. Swipe left on items 
2. Manual edits of confirmed items 
     1. This will NOT be saved in the public “eat-by” date database
     2. This will be saved in your private database
     3. This will change when the item's notification goes off.  
     4. Swipe left on items 
3. Changing purchase date: cannot be a date in the future
4. Changing “eat-by” date: cannot be a date in the past
5. Set item category in the confirmation page (this will also be saved in a database much like the above)
6. Added '!' to status clock to show expired items 
7. Sorting/filtering coming soon...

## Beta 1.0
Main Features
1. Onboarding with name  
2. Scanning of receipt with camera -> add items with eat-by day
3. Scanning of receipt in photo library -> add items with eat-by day
4. Get notification to eat item on day the eat-by says   
UI  
1. Onboarding 
- Next Button 
- Name Text Field 
- Finish Button -> Main view 
2. Main View "please scan to start..." 
- Scan button (plus icon) 
- Camera ("should ask for perm") 
- Photo library  
3. Settings: name, num items scanned, and yellow/red clock status days before 
4. Item list 
- Tap to get eat-by date  
- Swipe left to delete 
