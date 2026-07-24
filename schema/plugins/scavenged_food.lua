PLUGIN.name = "Scavenged Food"
PLUGIN.author = "You"
PLUGIN.description = "Bulk-registers curated food items from the Willard Food Pack, minus anything real-brand or wrong-universe."

local MODEL_PATH = "models/foodnhouseholditems/"

local function StandardHeal(itemTable)
	local client = itemTable.player
	client:SetHealth(math.min(client:Health() + 10, client:GetMaxHealth()))
	return true
end

local function LuxuryHeal(itemTable)
	local client = itemTable.player
	client:SetHealth(math.min(client:Health() + 15, client:GetMaxHealth()))
	client:RestoreStamina(50)
	return true
end

-- {uniqueID, display name, model filename}
local FOOD_ITEMS = {
	-- Produce
	{"apple", "Apple", "apple.mdl"}, {"apple1", "Apple", "apple1.mdl"}, {"apple2", "Apple", "apple2.mdl"},
	{"banana", "Banana", "bananna.mdl"}, {"banana_bunch", "Bunch of Bananas", "bananna_bunch.mdl"},
	{"cabbage1", "Cabbage", "cabbage1.mdl"}, {"cabbage2", "Cabbage", "cabbage2.mdl"}, {"cabbage3", "Cabbage", "cabbage3.mdl"},
	{"carrot", "Carrot", "carrot.mdl"}, {"coconut", "Coconut", "coconut.mdl"}, {"coconut_half", "Coconut", "coconut_half.mdl"},
	{"corn", "Corn", "corn.mdl"}, {"eggplant", "Eggplant", "eggplant.mdl"}, {"gourd", "Gourd", "gourd.mdl"},
	{"grapes1", "Grapes", "grapes1.mdl"}, {"grapes2", "Grapes", "grapes2.mdl"}, {"grapes3", "Grapes", "grapes3.mdl"},
	{"leek", "Leek", "leek.mdl"}, {"lettuce", "Lettuce", "lettuce.mdl"}, {"orange", "Orange", "orange.mdl"},
	{"pear", "Pear", "pear.mdl"}, {"pepper1", "Pepper", "pepper1.mdl"}, {"pepper2", "Pepper", "pepper2.mdl"},
	{"pepper3", "Pepper", "pepper3.mdl"}, {"pineapple", "Pineapple", "pineapple.mdl"}, {"potato", "Potato", "potato.mdl"},
	{"pumpkin", "Pumpkin", "pumpkin01.mdl"}, {"tomato", "Tomato", "tomato.mdl"},
	{"watermelon_half", "Watermelon", "watermelon_half.mdl"}, {"watermelon_slice", "Watermelon Slice", "watermelon_slice.mdl"},

	-- Bread & bakery
	{"bagel1", "Bagel", "bagel1.mdl"}, {"bagel2", "Bagel", "bagel2.mdl"}, {"bagel3", "Bagel", "bagel3.mdl"},
	{"baguette", "Baguette", "bagette.mdl"}, {"bread1", "Loaf of Bread", "bread-1.mdl"}, {"bread2", "Loaf of Bread", "bread-2.mdl"},
	{"bread3", "Loaf of Bread", "bread-3.mdl"}, {"bread4", "Loaf of Bread", "bread-4.mdl"},
	{"bread_half", "Half a Loaf", "bread_half.mdl"}, {"bread_loaf", "Loaf of Bread", "bread_loaf.mdl"},
	{"bread_slice", "Slice of Bread", "bread_slice.mdl"}, {"chocolatine", "Pain au Chocolat", "chocolatine.mdl"},
	{"croissant", "Croissant", "croissant.mdl"}, {"donut", "Donut", "donut.mdl"}, {"pancake", "Pancake", "pancake.mdl"},
	{"pancakes", "Stack of Pancakes", "pancakes.mdl"}, {"pretzel", "Pretzel", "pretzel.mdl"}, {"sweetroll", "Sweet Roll", "sweetroll.mdl"},
	{"toast", "Toast", "toast.mdl"}, {"cookies", "Cookies", "cookies.mdl"}, {"digestive1", "Biscuits", "digestive.mdl"},
	{"digestive2", "Biscuits", "digestive2.mdl"}, {"pie", "Pie", "pie.mdl"},
	{"cake1", "Cake", "cake.mdl"}, {"cake1a", "Cake", "cake1a.mdl"}, {"cake1b", "Cake", "cake1b.mdl"},
	{"cake2a", "Cake", "cake2a.mdl"}, {"cake2b", "Cake", "cake2b.mdl"}, {"cake3a", "Cake", "cake3a.mdl"},
	{"cake3b", "Cake", "cake3b.mdl"}, {"cake4a", "Cake", "cake4a.mdl"}, {"cake4b", "Cake", "cake4b.mdl"},
	{"cake5a", "Cake", "cake5a.mdl"}, {"cake5b", "Cake", "cake5b.mdl"}, {"cakeslice1", "Slice of Cake", "cakeslice1.mdl"},
	{"cakeslice2", "Slice of Cake", "cakeslice2.mdl"},

	-- Meat, protein & seafood
	{"bacon", "Bacon", "bacon.mdl"}, {"bacon2", "Bacon", "bacon_2.mdl"}, {"bacon_cooked", "Cooked Bacon", "baconcooked.mdl"},
	{"meat3", "Cut of Meat", "meat3.mdl"}, {"meat4", "Cut of Meat", "meat4.mdl"}, {"meat5", "Cut of Meat", "meat5.mdl"},
	{"meat6", "Cut of Meat", "meat6.mdl"}, {"meat7", "Cut of Meat", "meat7.mdl"}, {"meat8", "Cut of Meat", "meat8.mdl"},
	{"meat9", "Cut of Meat", "meat9.mdl"}, {"meat_ribs", "Ribs", "meat_ribs.mdl"},
	{"steak1", "Steak", "steak1.mdl"}, {"steak2", "Steak", "steak2.mdl"}, {"turkey", "Turkey", "turkey.mdl"},
	{"turkey2", "Turkey", "turkey2.mdl"}, {"turkeyleg", "Turkey Leg", "turkeyleg.mdl"},
	{"fish_bass", "Bass", "fishbass.mdl"}, {"fish_catfish", "Catfish", "fishcatfish.mdl"}, {"fish_steak", "Fish Steak", "fishsteak.mdl"},
	{"salmon", "Salmon", "salmon.mdl"}, {"lobster1", "Lobster", "lobster.mdl"}, {"lobster2", "Lobster", "lobster2.mdl"},
	{"egg", "Egg", "egg.mdl"}, {"egg1", "Egg", "egg1.mdl"}, {"egg2", "Egg", "egg2.mdl"},
	{"egg_box", "Box of Eggs", "egg_box1.mdl"}, {"hotdog", "Hot Dog", "hotdog.mdl"}, {"sandwich", "Sandwich", "sandwich.mdl"},
	{"chili", "Bowl of Chili", "chili.mdl"}, {"cheese1", "Wheel of Cheese", "cheesewheel1a.mdl"},
	{"cheese2", "Wheel of Cheese", "cheesewheel2a.mdl"}, {"milk", "Milk", "milk.mdl"}, {"milk2", "Milk", "milk2.mdl"},
	{"honey", "Jar of Honey", "honey_jar.mdl"}, {"peanut_butter", "Peanut Butter", "peanut_butter.mdl"}, {"ketchup", "Ketchup", "ketchup.mdl"},
	{"pizza", "Pizza", "pizza.mdl"}, {"pizza_slice", "Slice of Pizza", "pizzaslice.mdl"},

	-- Chips (unbranded only)
	{"chips1", "Bag of Chips", "chipsbag1.mdl"}, {"chips2", "Bag of Chips", "chipsbag2.mdl"},
	{"chips3", "Bag of Chips", "chipsbag3.mdl"}, {"chips_tropical", "Bag of Chips", "chipstropical.mdl"},

	-- Drinks (generic)
	{"juice1", "Juice", "juice.mdl"}, {"juice2", "Juice", "juice2.mdl"}, {"juice_small", "Small Juice", "juicesmall.mdl"},
	{"cola", "Cola", "cola.mdl"}, {"cola_big", "Large Cola", "colabig.mdl"},
	{"soda1", "Soda Can", "sodacan01.mdl"}, {"soda2", "Soda Can", "sodacan02.mdl"}, {"soda3", "Soda Can", "sodacan03.mdl"},
}

-- Loyalist luxury tier - rare pre-war goods, better heal, thematically "collaborator" status symbols
local LUXURY_ITEMS = {
	{"champagne1", "Bottle of Champagne", "champagne2.mdl"}, {"champagne2", "Bottle of Champagne", "champagne3.mdl"},
	{"champagne_glass", "Glass of Champagne", "champglass.mdl"},
	{"wine_red1", "Bottle of Red Wine", "wine_red1.mdl"}, {"wine_red2", "Bottle of Red Wine", "wine_red2.mdl"},
	{"wine_rose", "Bottle of Rose", "wine_rose1.mdl"}, {"wine_white1", "Bottle of White Wine", "wine_white1.mdl"},
	{"wine_white2", "Bottle of White Wine", "wine_white2.mdl"},
	{"beer1", "Bottle of Beer", "beer_master.mdl"}, {"beer2", "Bottle of Beer", "beer_stoltz.mdl"},
	{"beer_can1", "Can of Beer", "beercan01.mdl"}, {"beer_can2", "Can of Beer", "beercan02.mdl"},
	{"coffee", "Jar of Coffee", "coffee_nescafe.mdl"}, {"chocolate1", "Bar of Chocolate", "toblerone.mdl"},
	{"chocolate2", "Box of Chocolates", "toffifee.mdl"}, {"chocolate_spread", "Jar of Chocolate Spread", "nutella.mdl"},
	{"icecream1", "Tub of Ice Cream", "icecream1.mdl"}, {"icecream2", "Tub of Ice Cream", "icecream2.mdl"},
	{"icecream3", "Tub of Ice Cream", "icecream3.mdl"},
}

local function RegisterFood(data, luxury)
	local uniqueID, name, model = data[1], data[2], data[3]
	local ITEM = ix.item.Register(uniqueID, nil, nil, nil, true)

	ITEM.name = name
	ITEM.model = Model(MODEL_PATH .. model)
	ITEM.width = 1
	ITEM.height = 1
	ITEM.category = "Consumables"
	ITEM.permit = "consumables"
	ITEM.description = luxury
		and ("A rare pre-war find - " .. name:lower() .. ". The kind of thing that buys favors.")
		or ("Some " .. name:lower() .. ".")

	ITEM.functions.Eat = {
		OnRun = luxury and LuxuryHeal or StandardHeal
	}
end

for _, data in ipairs(FOOD_ITEMS) do
	RegisterFood(data, false)
end

for _, data in ipairs(LUXURY_ITEMS) do
	RegisterFood(data, true)
end
