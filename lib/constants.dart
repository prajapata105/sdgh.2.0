const appCurrencySybmbol = "₹";

enum RequestingMethods { get, post, put, delete }

const List<String> kDummyProducts = [
  "Apple",
  "Banana",
  "Cherry",
  "Date",
  "Elderberry",
  "Fig",
  "Grape",
  "Honeydew",
  "Jackfruit",
  "Kiwi",
  "Lemon",
  "Mango",
  "Nectarine",
  "Orange",
  "Papaya",
  "Quince",
  "Raspberry",
  "Strawberry",
  "Tangerine",
  "Ugli fruit",
  "Vanilla bean",
  "Watermelon",
  "Xigua melon",
  "Yellow passion fruit",
  "Zucchini",
];

const introParagraph =
'''Welcome to “Sridungargarh City” (the “App”), a hyperlocal platform operated by sridungargarh one . These Terms and Conditions (“Terms”) constitute a legally binding agreement between you (“User” or “you”) and us.

The App provides a variety of services, including an e-commerce marketplace, a local business directory, and a news content portal (collectively, the “Services”). By accessing, browsing, or using the App or its Services, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree to these terms, you must not use this App.''';

List kDummyCoupons = [
  {
    "headline": "Get 10% off on your first order",
    "couponCode": "NEWUSER",
    "dataPoints": [
      "Get 10% off on your first order",
      "Minimum order value: ₹500",
      "Maximum discount: ₹100",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat ₹50 off on fruits",
    "couponCode": "FRUITS50",
    "dataPoints": [
      "Flat ₹50 off on fruits",
      "Minimum order value: ₹200",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Buy 1 get 1 free on vegetables",
    "couponCode": "VEGGIES",
    "dataPoints": [
      "Buy 1 get 1 free on vegetables",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "₹100 off on groceries",
    "couponCode": "GROCERY100",
    "dataPoints": [
      "₹100 off on groceries",
      "Minimum order value: ₹1000",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat 20% off on dairy products",
    "couponCode": "DAIRY20",
    "dataPoints": [
      "Flat 20% off on dairy products",
      "Minimum order value: ₹300",
      "Maximum discount: ₹50",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "₹75 off on personal care items",
    "couponCode": "CARE75",
    "dataPoints": [
      "₹75 off on personal care items",
      "Minimum order value: ₹500",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat 15% off on household products",
    "couponCode": "HOUSE15",
    "dataPoints": [
      "Flat 15% off on household products",
      "Minimum order value: ₹400",
      "Maximum discount: ₹100",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Buy 2 get 1 free on snacks",
    "couponCode": "SNACKS",
    "dataPoints": [
      "Buy 2 get 1 free on snacks",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat ₹30 off on beverages",
    "couponCode": "BEV30",
    "dataPoints": [
      "Flat ₹30 off on beverages",
      "Minimum order value: ₹200",
      "Valid till: 31st December 2021",
    ],
  }
];

const kCategoriesTitles = [
  "Paan Corner",
  "Dairy, Bread & Eggs",
  "Fruits & Vegetables",
  "Cold Drinks & Juices",
  "Snacks & Munchies",
  "Breakfast & Instandt Food",
  "Sweet Tooth",
  "Bakery & Biscuits",
  "Tea & Coffee",
  "Atta, Rice & Dal",
  "Masala & Oil",
  "Sauces & Spreads",
  "Chicken, Meat & Fish",
  "Organic & Healthy Living",
  "Baby Care",
  "Pharma & Wellness",
  "Cleaning Essentials",
  "Home & Office",
  "Personal Care",
  "Pet Care"
];

const kSvgIcons = [
  "https://img.icons8.com/ios/50/wallet--v1.png",
  "https://img.icons8.com/ios/50/filled-chat.png",
  "https://img.icons8.com/dotty/80/token-card-code.png"
];
