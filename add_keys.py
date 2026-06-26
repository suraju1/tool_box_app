import json

def add_keys(filepath, new_keys):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    data.update(new_keys)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

en_keys = {
  "unblockUserPrompt": "unblock {name}?",
  "@unblockUserPrompt": {"placeholders": {"name": {"type": "String"}}},
  "folderName": "Folder Name",
  "usagePostsUsed": "Usage: {count} posts used",
  "@usagePostsUsed": {"placeholders": {"count": {"type": "String"}}},
  "postVisibilityStatus": "Post Visibility: {status}",
  "@postVisibilityStatus": {"placeholders": {"status": {"type": "String"}}},
  "remainingDaysCount": "Remaining Days: {days}",
  "@remainingDaysCount": {"placeholders": {"days": {"type": "String"}}},
  "postPriceAmount": "Post Price: ₹{price}",
  "@postPriceAmount": {"placeholders": {"price": {"type": "String"}}},
  "totalAllocationCredits": "Total Allocation: {credits} Credits",
  "@totalAllocationCredits": {"placeholders": {"credits": {"type": "String"}}},
  "daysPlan": "{days} Days Plan",
  "@daysPlan": {"placeholders": {"days": {"type": "String"}}},
  "planText": "{name} Plan",
  "@planText": {"placeholders": {"name": {"type": "String"}}},
  "blockedOnDate": "Blocked on: {date}",
  "@blockedOnDate": {"placeholders": {"date": {"type": "String"}}},
  "youDontHaveAnyActiveSubscriptionPlan": "You don't have any active subscription plan.",
  "collectionCreatedSuccessfully": "Collection created successfully",
  "failedToCreateCollection": "Failed to create collection",
  "profileRemovedFromSaved": "Profile removed from saved",
  "failedToRemoveProfile": "Failed to remove profile"
}

hi_keys = {
  "unblockUserPrompt": "{name} को अनब्लॉक करें?",
  "folderName": "फ़ोल्डर का नाम",
  "usagePostsUsed": "उपयोग: {count} पोस्ट इस्तेमाल किए गए",
  "postVisibilityStatus": "पोस्ट दृश्यता: {status}",
  "remainingDaysCount": "शेष दिन: {days}",
  "postPriceAmount": "पोस्ट की कीमत: ₹{price}",
  "totalAllocationCredits": "कुल आवंटन: {credits} क्रेडिट",
  "daysPlan": "{days} दिन का प्लान",
  "planText": "{name} प्लान",
  "blockedOnDate": "इस तारीख को ब्लॉक किया गया: {date}",
  "youDontHaveAnyActiveSubscriptionPlan": "आपके पास कोई सक्रिय सदस्यता योजना नहीं है।",
  "collectionCreatedSuccessfully": "संग्रह सफलतापूर्वक बनाया गया",
  "failedToCreateCollection": "संग्रह बनाने में विफल",
  "profileRemovedFromSaved": "प्रोफ़ाइल सहेजे गए से हटा दी गई",
  "failedToRemoveProfile": "प्रोफ़ाइल हटाने में विफल"
}

mr_keys = {
  "unblockUserPrompt": "{name} ला अनब्लॉक करा?",
  "folderName": "फोल्डरचे नाव",
  "usagePostsUsed": "वापर: {count} पोस्ट्स वापरल्या",
  "postVisibilityStatus": "पोस्ट दृश्यमानता: {status}",
  "remainingDaysCount": "उर्वरित दिवस: {days}",
  "postPriceAmount": "पोस्टची किंमत: ₹{price}",
  "totalAllocationCredits": "एकूण वाटप: {credits} क्रेडिट्स",
  "daysPlan": "{days} दिवसांचा प्लॅन",
  "planText": "{name} प्लॅन",
  "blockedOnDate": "या तारखेला ब्लॉक केले: {date}",
  "youDontHaveAnyActiveSubscriptionPlan": "तुमच्याकडे कोणताही सक्रिय सबस्क्रिप्शन प्लॅन नाही.",
  "collectionCreatedSuccessfully": "संग्रह यशस्वीरित्या तयार केला",
  "failedToCreateCollection": "संग्रह तयार करण्यात अयशस्वी",
  "profileRemovedFromSaved": "प्रोफाइल सेव्हमधून काढले",
  "failedToRemoveProfile": "प्रोफाइल काढण्यात अयशस्वी"
}

add_keys('lib/l10n/app_en.arb', en_keys)
add_keys('lib/l10n/app_hi.arb', hi_keys)
add_keys('lib/l10n/app_mr.arb', mr_keys)
