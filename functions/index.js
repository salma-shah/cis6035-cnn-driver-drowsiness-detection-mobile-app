const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkIfPhoneNumberIsRegistered =
functions.https.onCall(async (request) => {
  try {
    console.log("DATA RECEIVED:", request);

    const phone =
      String(request.data.phone || "").trim();

    console.log("PHONE:", phone);

    if (!phone) {
      throw new Error(
          "Phone number is required",
      );
    }

    const snapshot =
      await admin.firestore()
          .collection("users")
          .where("phoneNumber", "==", phone)
          .get();

    return {
      exists: !snapshot.empty,
    };
  } catch (error) {
    console.error("FUNCTION ERROR:", error);

    throw new functions.Error(
        error.message || "Unknown error",
    );
  }
});
