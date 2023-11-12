const functions = require("firebase-functions");
const admin = require("firebase-admin");
const FieldPath = admin.firestore.FieldPath;
admin.initializeApp();

const db = admin.firestore();
exports.scheduledFunction = functions.pubsub.schedule('0 0 2 * *').timeZone('Europe/Istanbul').onRun((context) => {
  return db
    .collection('welfareUsers')
    .get()
    .then((querySnapshot) => {
      querySnapshot.forEach((doc) => {
        const myName = doc.get('myName');
        const myLoan = doc.get('myLoan');
        const loanGranted = doc.get('loanGranted');
        const loanDue = doc.get('loanDue');
        const loanPaid = doc.get('loanPaid');
        const loanInstallments = doc.get('loanInstallments');
        const loanRequested = doc.get('loanRequested');
        const monthlySavings = doc.get('monthlySavings');
        const mySavings = doc.get('mySavings');
        const guarantorBalance = doc.get('guarantorBalance');

        // Check if myName field exists
        if (myName !== undefined) {
          doc.ref.update({
            mySavings: mySavings + monthlySavings,
            guarantorBalance: guarantorBalance + monthlySavings
          });
        }
        if (myName !== undefined && myLoan !== 0 && loanDue > 0) {
          doc.ref.update({
            loanDue: loanDue - loanInstallments,
            loanPaid: loanPaid + loanInstallments
          });
        }
        return null;
      });
    });
});

exports.updateData = functions.firestore
  .document('welfareUsers/{userId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if ((afterData.acceptedGuarantorCounter === 3 || afterData.loanRequested <= afterData.mySavings) && afterData.myLoan != afterData.loanRequested && afterData.IDNumber !== undefined && afterData.loanGuarantorApproval === '' && afterData.loanAdminApproval === '') {
      return change.after.ref.update({
              loanGuarantorApproval: 'complete',
              loanAdminApproval: 'awaiting response'
            });
    }

});

exports.createData = functions.firestore
  .document('welfareUsers/{userId}')
  .onCreate(async (snapshot, context) => {
    const createdData = snapshot.data();

    let shouldUpdate = false;
    const updatedData = {};

    if (createdData.notificationRead === undefined && createdData.IDNumber === undefined) {
      // If the notificationRead field does not exist, set it to false
      updatedData.notificationRead = false;
      shouldUpdate = true;
    }

    if (createdData.guaranteeStatus === undefined && createdData.IDNumber === undefined) {
      // If the guaranteeStatus field does not exist, set it to null
      updatedData.guaranteeStatus = null;
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      await snapshot.ref.update(updatedData);
    }

});

